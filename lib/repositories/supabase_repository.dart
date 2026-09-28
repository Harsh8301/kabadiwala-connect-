import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/workflow_models.dart';
import 'workflow_repositories.dart';

class AuthOutcome {
  const AuthOutcome({
    required this.success,
    this.message = '',
    this.userId,
    this.needsEmailConfirmation = false,
  });
  final bool success;
  // Raw error text from the auth backend (e.g. "Invalid login credentials").
  // Not translated — it comes from Supabase, not app copy.
  final String message;
  final String? userId;
  final bool needsEmailConfirmation;
}

final _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

/// Real, authenticated, cross-device backend on Supabase. Implements the
/// existing `RemoteRepository` contract (so it's a drop-in replacement for
/// `DemoRemoteRepository`) and additionally exposes auth and lot-fetch
/// methods that only make sense against a real backend.
///
/// Scope note: this syncs lot metadata (materials, weights, prices, status,
/// location, payment state) but not photos yet — `image_url`/
/// `handover_image_url` are left null. `buyer_id` is only set when
/// `selectedRecyclerId` is already a real Supabase profile UUID (i.e. once
/// recycler matching is rebuilt against real recycler accounts); until then
/// it stays null and lots only sync back to their own seller across devices.
class SupabaseRemoteRepository implements RemoteRepository {
  SupabaseRemoteRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String? get currentUserId => _client.auth.currentUser?.id;

  Stream<bool> get authStateChanges =>
      _client.auth.onAuthStateChange.map((state) => state.session != null);

  Future<AuthOutcome> signUp({
    required String email,
    required String password,
    required UserRole role,
    String phone = '',
    String language = 'en',
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'role': role.name, 'phone': phone, 'language': language},
      );
      if (response.user == null) {
        return const AuthOutcome(success: false);
      }
      if (response.session == null) {
        return AuthOutcome(
          success: true,
          userId: response.user!.id,
          needsEmailConfirmation: true,
        );
      }
      return AuthOutcome(success: true, userId: response.user!.id);
    } on AuthException catch (error) {
      return AuthOutcome(success: false, message: error.message);
    } catch (error) {
      return AuthOutcome(success: false, message: error.toString());
    }
  }

  Future<AuthOutcome> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth
          .signInWithPassword(email: email, password: password);
      if (response.user == null) {
        return const AuthOutcome(success: false);
      }
      return AuthOutcome(success: true, userId: response.user!.id);
    } on AuthException catch (error) {
      return AuthOutcome(success: false, message: error.message);
    } catch (error) {
      return AuthOutcome(success: false, message: error.toString());
    }
  }

  Future<void> signOut() => _client.auth.signOut();

  /// Starts the Google OAuth flow. On web this redirects the whole page to
  /// Google and back; the returned Future resolves once that redirect has
  /// been launched, not once sign-in completes — completion is observed via
  /// [authStateChanges] instead. Requires the Google provider to be enabled
  /// in the Supabase dashboard (Authentication → Providers → Google) with a
  /// Google Cloud OAuth client configured, and the app's origin listed under
  /// Authentication → URL Configuration → Redirect URLs.
  Future<void> signInWithGoogle() => _client.auth.signInWithOAuth(
        OAuthProvider.google,
        authScreenLaunchMode: LaunchMode.platformDefault,
      );

  @override
  Future<void> uploadLot(DigitalLot lot) async {
    final userId = currentUserId;
    if (userId == null) {
      throw StateError('Not signed in: cannot upload a lot without a session.');
    }

    final buyerId = _uuidPattern.hasMatch(lot.selectedRecyclerId)
        ? lot.selectedRecyclerId
        : null;

    final rows = await _client.from('lots').upsert({
      'lot_code': lot.lotId,
      'seller_id': userId,
      'buyer_id': buyerId,
      'status': lot.status.name,
      'collection_lat': lot.collectionLocation.latitude,
      'collection_lng': lot.collectionLocation.longitude,
      'collection_label': lot.collectionLocation.label,
      'handover_lat': lot.handoverLocation.latitude,
      'handover_lng': lot.handoverLocation.longitude,
      'handover_label': lot.handoverLocation.label,
      'total_estimated_value': lot.totalEstimatedValue,
      'final_weight_kg': lot.finalWeightKg,
      'final_sale_value': lot.finalSaleValue,
      'payment_method': lot.paymentMethod.name,
      'payment_status': lot.paymentStatus.name,
      'seller_confirmed': true,
      'buyer_confirmed': lot.recyclerConfirmed,
      'handover_reference': lot.handoverReference,
    }, onConflict: 'lot_code').select('id');

    final lotUuid = (rows as List).first['id'] as String;

    await _client.from('lot_materials').delete().eq('lot_id', lotUuid);
    if (lot.materials.isNotEmpty) {
      await _client.from('lot_materials').insert(lot.materials
          .map((item) => {
                'lot_id': lotUuid,
                'material_id': item.materialId,
                'quantity': item.quantity,
                'weight_kg': item.weightKg,
                'condition': item.condition,
                'source_type': item.sourceType,
                'estimated_value': item.estimatedValue,
                'quoted_rate': item.quotedRate,
              })
          .toList());
    }

    await _client.from('lot_status_history').delete().eq('lot_id', lotUuid);
    if (lot.statusHistory.isNotEmpty) {
      await _client.from('lot_status_history').insert(lot.statusHistory
          .map((event) => {
                'lot_id': lotUuid,
                'status': event.status.name,
                'note': event.note,
                'actor_id': userId,
                'at': event.at.toIso8601String(),
              })
          .toList());
    }
  }

  /// Lots where the signed-in user is the seller or the assigned buyer —
  /// this is what makes a lot created on one phone visible on another
  /// device once both sign in with the same account.
  Future<List<DigitalLot>> fetchLotsForCurrentUser() async {
    final userId = currentUserId;
    if (userId == null) return const [];

    final rows = await _client
        .from('lots')
        .select('*, lot_materials(*)')
        .or('seller_id.eq.$userId,buyer_id.eq.$userId');

    return (rows as List)
        .map((row) => _lotFromRow(row as Map<String, dynamic>))
        .toList();
  }

  DigitalLot _lotFromRow(Map<String, dynamic> row) {
    final materialRows = (row['lot_materials'] as List? ?? const [])
        .cast<Map<String, dynamic>>();
    return DigitalLot(
      lotId: row['lot_code'] as String,
      handoverReference: row['handover_reference']?.toString() ?? '',
      collectorId: row['seller_id']?.toString() ?? '',
      createdAt: DateTime.parse(row['created_at'] as String),
      materials: materialRows
          .map((item) => LotMaterial(
                materialId: item['material_id']?.toString() ?? 'mixed_plastics',
                quantity: (item['quantity'] as num?)?.round() ?? 1,
                weightKg: (item['weight_kg'] as num?)?.toDouble() ?? 0,
                condition: item['condition']?.toString() ?? '',
                sourceType: item['source_type']?.toString() ?? '',
                confidence: 0,
                imageIds: const [],
                estimatedValue: (item['estimated_value'] as num?)?.toDouble() ?? 0,
                quotedRate: (item['quoted_rate'] as num?)?.toDouble() ?? 0,
              ))
          .toList(),
      imageBase64: const [],
      handoverImageBase64: null,
      collectionLocation: LocationRecord(
        latitude: (row['collection_lat'] as num?)?.toDouble(),
        longitude: (row['collection_lng'] as num?)?.toDouble(),
        label: row['collection_label']?.toString() ?? 'Location unavailable',
      ),
      handoverLocation: LocationRecord(
        latitude: (row['handover_lat'] as num?)?.toDouble(),
        longitude: (row['handover_lng'] as num?)?.toDouble(),
        label: row['handover_label']?.toString() ?? 'Location unavailable',
      ),
      status: enumByName(LotStatus.values, row['status'], LotStatus.lotCreated),
      paymentMethod: enumByName(
          PaymentMethod.values, row['payment_method'], PaymentMethod.cash),
      paymentStatus: enumByName(
          PaymentStatus.values, row['payment_status'], PaymentStatus.pending),
      syncState: SyncState.synced,
      selectedRecyclerId: row['buyer_id']?.toString() ?? '',
      selectedRecyclerName: '',
      totalEstimatedValue: (row['total_estimated_value'] as num?)?.toDouble() ?? 0,
      finalWeightKg: (row['final_weight_kg'] as num?)?.toDouble(),
      finalSaleValue: (row['final_sale_value'] as num?)?.toDouble(),
      recyclerConfirmed: row['buyer_confirmed'] == true,
      statusHistory: const [],
    );
  }
}
