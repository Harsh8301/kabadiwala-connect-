import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/data/ministry_data.dart';
import 'package:kabadiwala_connect/ministry_controller.dart';
import 'package:kabadiwala_connect/models/workflow_models.dart';
import 'package:kabadiwala_connect/repositories/workflow_repositories.dart';
import 'package:kabadiwala_connect/services/workflow_services.dart';

class MemoryLocalRepository implements LocalRepository {
  CollectorProfile? profile;
  List<DigitalLot> lots = [];
  DateTime? lastSync;

  @override
  Future<void> clearProfile() async => profile = null;
  @override
  Future<DateTime?> loadLastSync() async => lastSync;
  @override
  Future<List<DigitalLot>> loadLots() async => [...lots];
  @override
  Future<CollectorProfile?> loadProfile() async => profile;
  @override
  Future<void> saveLastSync(DateTime value) async => lastSync = value;
  @override
  Future<void> saveLots(List<DigitalLot> value) async => lots = [...value];
  @override
  Future<void> saveProfile(CollectorProfile value) async => profile = value;
}

class CountingRemoteRepository implements RemoteRepository {
  int uploads = 0;
  bool fail = false;

  @override
  Future<void> uploadLot(DigitalLot lot) async {
    uploads++;
    if (fail) throw StateError('offline');
  }
}

DigitalLot sampleLot({SyncState syncState = SyncState.pending}) => DigitalLot(
      lotId: 'KBC-2026-000123',
      handoverReference: 'HO-000123',
      collectorId: 'COL-1',
      createdAt: DateTime(2026, 9, 17),
      materials: const [
        LotMaterial(
          materialId: 'pcb',
          quantity: 5,
          weightKg: 3.5,
          condition: 'mixed',
          sourceType: 'manual',
          confidence: 1,
          imageIds: [],
          estimatedValue: 1470,
          quotedRate: 420,
        ),
      ],
      imageBase64: const [],
      handoverImageBase64: null,
      collectionLocation: const LocationRecord(
          latitude: 18.52, longitude: 73.85, label: 'Pune'),
      handoverLocation: const LocationRecord(label: 'Pending'),
      status: LotStatus.lotCreated,
      paymentMethod: PaymentMethod.cash,
      paymentStatus: PaymentStatus.pending,
      syncState: syncState,
      selectedRecyclerId: '',
      selectedRecyclerName: '',
      totalEstimatedValue: 1470,
      finalWeightKg: null,
      finalSaleValue: null,
      recyclerConfirmed: false,
      statusHistory: [
        StatusEvent(status: LotStatus.lotCreated, at: DateTime(2026, 9, 17)),
      ],
    );

void main() {
  group('structured workflow services', () {
    test('valuation calculates weight times reference rate', () {
      const service = ValuationService();
      expect(service.estimate('pcb', 3.5), 1470);
      expect(service.estimate('cables', 0), 0);
    });

    test('rule-based recycler matching explains and sorts recommendations', () {
      const service = RecyclerRecommendationService();
      final matches = service.recommend(
        materials: sampleLot().materials,
        location: sampleLot().collectionLocation,
      );
      expect(matches, isNotEmpty);
      expect(matches.first.score, greaterThanOrEqualTo(matches.last.score));
      expect(matches.first.reasons, isNotEmpty);
      expect(matches.first.recycler.authorizationStatus,
          contains('verification required'));
    });

    test('rule-based anomaly check flags implausibly low sale value', () {
      const service = AnomalyDetectionService();
      final result = service.check(
        finalValue: 75,
        finalWeightKg: 3.5,
        materials: sampleLot().materials,
      );
      expect(result.unusual, isTrue);
      expect(result.message, contains('Unusual transaction value'));
    });

    test('sync queue uploads each pending lot once', () async {
      final local = MemoryLocalRepository();
      final remote = CountingRemoteRepository();
      final service = SyncService(local: local, remote: remote);
      final first = await service.sync([sampleLot()]);
      final second = await service.sync(first);
      expect(remote.uploads, 1);
      expect(second.single.syncState, SyncState.synced);
      expect(local.lastSync, isNotNull);
    });

    test('failed sync remains retryable', () async {
      final local = MemoryLocalRepository();
      final remote = CountingRemoteRepository()..fail = true;
      final service = SyncService(local: local, remote: remote);
      final failed = await service.sync([sampleLot()]);
      expect(failed.single.syncState, SyncState.failed);
      remote.fail = false;
      final retried = await service.sync(failed);
      expect(retried.single.syncState, SyncState.synced);
      expect(remote.uploads, 2);
    });
  });

  group('batch and transaction controller', () {
    late MemoryLocalRepository local;
    late MinistryController controller;

    setUp(() {
      local = MemoryLocalRepository();
      controller = MinistryController(
        localRepository: local,
        remoteRepository: CountingRemoteRepository(),
        enableTts: false,
        initialOnline: false,
        monitorConnectivity: false,
      );
    });

    tearDown(() => controller.dispose());

    test('batch creates one consolidated persistent lot', () async {
      await controller.saveProfile('9876543210', 'Pune');
      controller.startCollection(CollectionMode.batch);
      controller.addManualMaterial('pcb');
      controller.addManualMaterial('pcb');
      controller.addManualMaterial('cables');
      controller.updateMaterial(0, weightKg: 3.5, quantity: 5);
      controller.updateMaterial(1, weightKg: 4.2, quantity: 3);
      controller.useDemoLocation();
      final lot = await controller.createLot();
      expect(lot, isNotNull);
      expect(lot!.materials, hasLength(2));
      expect(lot.totalWeightKg, closeTo(7.7, .001));
      expect(lot.lotId, startsWith('KBC-'));
      expect(lot.status, LotStatus.pendingSync);
      expect(local.lots, hasLength(1));
    });

    test('zero material weight prevents lot creation', () async {
      await controller.saveProfile('9876543210', 'Pune');
      controller.startCollection(CollectionMode.batch);
      controller.addManualMaterial('battery');
      expect(await controller.createLot(), isNull);
      expect(controller.lastError, contains('weight'));
    });

    test('receipt requires recycler and blocks duplicate confirmation',
        () async {
      await controller.saveProfile('9876543210', 'Pune');
      controller.startCollection(CollectionMode.batch);
      controller.addManualMaterial('pcb');
      controller.updateMaterial(0, weightKg: 3.5);
      controller.useDemoLocation();
      await controller.createLot();
      final recycler = controller.recyclerMatches().first.recycler;
      await controller.chooseRecycler(recycler);
      expect(await controller.confirmReceipt(3.4, 1450), isTrue);
      expect(await controller.confirmReceipt(3.4, 1450), isFalse);
      expect(controller.selectedLot!.recyclerConfirmed, isTrue);
      expect(controller.selectedLot!.status, LotStatus.received);
    });

    test('paid handover updates ledger totals and completed status', () async {
      await controller.saveProfile('9876543210', 'Pune');
      controller.startCollection(CollectionMode.single);
      controller.addManualMaterial('motor');
      controller.updateMaterial(0, weightKg: 2);
      controller.useDemoLocation();
      await controller.createLot();
      await controller
          .chooseRecycler(controller.recyclerMatches().first.recycler);
      await controller.confirmReceipt(2, 380);
      await controller.finishPayment(PaymentMethod.cash, PaymentStatus.paid);
      expect(controller.selectedLot!.status, LotStatus.completed);
      expect(controller.totalEarnings, 380);
      expect(controller.pendingEarnings, 0);
    });
  });

  test('critical workflow translations exist in all supported languages', () {
    const keys = [
      'home',
      'batch',
      'reviewMaterials',
      'priceBoard',
      'createLot',
      'findRecycler',
      'handover',
      'payment',
      'sync',
      'safety',
    ];
    for (final language in ['en', 'hi', 'mr']) {
      for (final key in keys) {
        expect(mt(language, key), isNot(key));
      }
    }
  });

  test('digital lot JSON round trip preserves traceability fields', () {
    final original = sampleLot();
    final restored = DigitalLot.fromJson(original.toJson());
    expect(restored.lotId, original.lotId);
    expect(restored.materials.single.weightKg, 3.5);
    expect(restored.collectionLocation.latitude, 18.52);
    expect(restored.statusHistory, hasLength(1));
    expect(restored.toQrJson(), contains('handoverReference'));
  });
}
