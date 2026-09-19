import 'dart:math';

import 'package:geolocator/geolocator.dart';

import '../data/ministry_data.dart';
import '../models/workflow_models.dart';
import '../repositories/workflow_repositories.dart';

class ValuationService {
  const ValuationService();

  PriceRecord priceFor(String materialId) =>
      demoPrices.firstWhere((price) => price.materialId == materialId,
          orElse: () => demoPrices.last);

  double estimate(String materialId, double weightKg) =>
      priceFor(materialId).buyingPrice * max(0, weightKg);
}

class RecyclerMatch {
  const RecyclerMatch({
    required this.recycler,
    required this.score,
    required this.distanceKm,
    required this.reasons,
    required this.offeredValue,
  });

  final RecyclerRecord recycler;
  final int score;
  final double distanceKm;
  final List<String> reasons;
  final double offeredValue;
}

class RecyclerRecommendationService {
  const RecyclerRecommendationService();

  List<RecyclerMatch> recommend({
    required List<LotMaterial> materials,
    required LocationRecord location,
  }) {
    final ids = materials.map((item) => item.materialId).toSet();
    final matches = <RecyclerMatch>[];
    for (final recycler in demoRecyclers) {
      final accepted = ids.intersection(recycler.materialsAccepted.toSet());
      if (accepted.isEmpty) continue;
      final compatibility = accepted.length / ids.length;
      final distance = location.available
          ? Geolocator.distanceBetween(location.latitude!, location.longitude!,
                  recycler.latitude, recycler.longitude) /
              1000
          : 999.0;
      final offered = materials.fold<double>(
          0,
          (sum, item) =>
              sum +
              item.weightKg *
                  (recycler.offeredRates[item.materialId] ?? item.quotedRate));
      var score = (compatibility * 55).round();
      score += recycler.pickupAvailability ? 15 : 4;
      score += distance < 10 ? 20 : (distance < 30 ? 12 : 4);
      score += 8;
      final reasons = <String>[
        'Accepts ${accepted.length}/${ids.length} material groups',
        recycler.authorizationStatus,
        if (location.available)
          '${distance.toStringAsFixed(1)} km away'
        else
          'Distance unavailable',
        recycler.pickupAvailability ? 'Pickup available' : 'Drop-off only',
      ];
      matches.add(RecyclerMatch(
        recycler: recycler,
        score: score.clamp(0, 100),
        distanceKm: distance,
        reasons: reasons,
        offeredValue: offered,
      ));
    }
    matches.sort((a, b) => b.score.compareTo(a.score));
    return matches;
  }
}

class AnomalyResult {
  const AnomalyResult({required this.unusual, required this.message});
  final bool unusual;
  final String message;
}

class AnomalyDetectionService {
  const AnomalyDetectionService();

  AnomalyResult check({
    required double finalValue,
    required double finalWeightKg,
    required List<LotMaterial> materials,
  }) {
    if (finalWeightKg <= 0) {
      return const AnomalyResult(
          unusual: true, message: 'Final weight must be greater than zero.');
    }
    final weightedMin = materials.fold<double>(0, (sum, item) {
      final price =
          demoPrices.firstWhere((p) => p.materialId == item.materialId);
      return sum + price.marketMin * item.weightKg;
    });
    final weightedMax = materials.fold<double>(0, (sum, item) {
      final price =
          demoPrices.firstWhere((p) => p.materialId == item.materialId);
      return sum + price.marketMax * item.weightKg;
    });
    if (finalValue < weightedMin * .55 || finalValue > weightedMax * 1.45) {
      return AnomalyResult(
        unusual: true,
        message:
            'Unusual transaction value. Demo expected range: ₹${weightedMin.round()}-₹${weightedMax.round()}. Please verify.',
      );
    }
    return const AnomalyResult(
        unusual: false, message: 'Value is within the demo reference range.');
  }
}

class SyncService {
  SyncService({required this.local, required this.remote});
  final LocalRepository local;
  final RemoteRepository remote;
  bool _running = false;

  Future<List<DigitalLot>> sync(List<DigitalLot> source) async {
    if (_running) return source;
    _running = true;
    var lots = [...source];
    try {
      for (var index = 0; index < lots.length; index++) {
        final lot = lots[index];
        if (lot.syncState != SyncState.pending &&
            lot.syncState != SyncState.failed) {
          continue;
        }
        try {
          await remote.uploadLot(lot);
          lots[index] =
              lot.copyWith(syncState: SyncState.synced, lastSyncError: '');
        } catch (error) {
          lots[index] = lot.copyWith(
              syncState: SyncState.failed, lastSyncError: error.toString());
        }
      }
      await local.saveLots(lots);
      if (lots.every((lot) =>
          lot.syncState != SyncState.pending &&
          lot.syncState != SyncState.failed)) {
        await local.saveLastSync(DateTime.now());
      }
      return lots;
    } finally {
      _running = false;
    }
  }
}
