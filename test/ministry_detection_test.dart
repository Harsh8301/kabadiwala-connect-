import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:kabadiwala_connect/data/ministry_data.dart';
import 'package:kabadiwala_connect/ministry_controller.dart';
import 'package:kabadiwala_connect/models/detection_result.dart';
import 'package:kabadiwala_connect/models/workflow_models.dart';
import 'package:kabadiwala_connect/repositories/workflow_repositories.dart';
import 'package:kabadiwala_connect/screens/dashboard_reference.dart';
import 'package:kabadiwala_connect/services/detection_service.dart';

class MemoryRepository implements LocalRepository {
  CollectorProfile? profile;
  List<DigitalLot> lots = [];

  @override
  Future<void> clearProfile() async => profile = null;
  @override
  Future<DateTime?> loadLastSync() async => null;
  @override
  Future<List<DigitalLot>> loadLots() async => lots;
  @override
  Future<CollectorProfile?> loadProfile() async => profile;
  @override
  Future<void> saveLastSync(DateTime value) async {}
  @override
  Future<void> saveLots(List<DigitalLot> value) async => lots = [...value];
  @override
  Future<void> saveProfile(CollectorProfile value) async => profile = value;
}

class NoopRemote implements RemoteRepository {
  @override
  Future<void> uploadLot(DigitalLot lot) async {}
}

class SequenceDetectionService extends DetectionService {
  SequenceDetectionService(this.results);
  final List<DetectionResult> results;
  int calls = 0;

  @override
  Future<DetectionResult> detect(Uint8List imageBytes) async =>
      results[calls++ % results.length];
}

class DeferredDetectionService extends DetectionService {
  final completer = Completer<DetectionResult>();

  @override
  Future<DetectionResult> detect(Uint8List imageBytes) => completer.future;
}

DetectionResult detected(String category, double confidence) =>
    DetectionResult.fromJson({
      'success': true,
      'status': confidence >= .7 ? 'detected' : 'possible',
      'categoryId': category,
      'className': category,
      'confidence': confidence,
      'predictions': [
        {
          'categoryId': category,
          'className': category,
          'confidence': confidence,
          'x': 50,
          'y': 50,
          'width': 40,
          'height': 40,
        }
      ],
      'image': {'width': 100, 'height': 100},
    });

MinistryController controllerWith(DetectionService service) =>
    MinistryController(
      localRepository: MemoryRepository(),
      remoteRepository: NoopRemote(),
      detectionService: service,
      enableTts: false,
      initialOnline: true,
      monitorConnectivity: false,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('collector number formatter rejects invalid and overlong input', () {
    final formatter = StrictCollectorNumberFormatter(onRejected: () {});
    const empty = TextEditingValue();
    expect(
      formatter.formatEditUpdate(
          empty, const TextEditingValue(text: '98765 43210')),
      empty,
    );
    expect(
      formatter.formatEditUpdate(
          empty, const TextEditingValue(text: '98765432101')),
      empty,
    );
    expect(
      formatter.formatEditUpdate(
          empty, const TextEditingValue(text: '9876543210')),
      const TextEditingValue(text: '9876543210'),
    );
  });

  test('profile validation accepts five to ten digits', () async {
    final controller =
        controllerWith(SequenceDetectionService([detected('pcb', .9)]));
    addTearDown(controller.dispose);

    for (final invalid in [
      '1234',
      '12345678901',
      '123 4567890',
      'abcdefghij'
    ]) {
      await controller.saveProfile(invalid, 'Pune');
      expect(controller.profile, isNull);
      expect(controller.lastError, mt('mr', 'phoneError'));
    }
    await controller.saveProfile('55555', 'Pune');
    expect(controller.profile?.collectorId, '55555');
  });

  test('successful AI suggestion remains separate after manual correction',
      () async {
    final controller =
        controllerWith(SequenceDetectionService([detected('battery', .91)]));
    addTearDown(controller.dispose);
    final image = DraftImage(id: 'one', bytes: Uint8List(1), source: 'test');
    controller.draftImages.add(image);

    await controller.detectImages([image]);
    expect(controller.draftMaterials.single.detectedMaterialId, 'battery');
    expect(controller.draftMaterials.single.materialId, 'battery');
    controller.replaceMaterial(0, 'motor');
    expect(controller.draftMaterials.single.detectedMaterialId, 'battery');
    expect(controller.draftMaterials.single.materialId, 'motor');
    expect(controller.draftMaterials.single.sourceType, 'manual_correction');
  });

  test('uncertain and failed detection preserve manual fallback', () async {
    final controller = controllerWith(SequenceDetectionService([
      DetectionResult.fromJson({
        'success': true,
        'status': 'uncertain',
        'confidence': 0,
        'predictions': <Object>[],
        'image': {'width': 100, 'height': 100},
      }),
      DetectionResult.error('INFERENCE_UNAVAILABLE', 'Offline'),
    ]));
    addTearDown(controller.dispose);
    final first = DraftImage(id: 'one', bytes: Uint8List(1), source: 'test');
    final second = DraftImage(id: 'two', bytes: Uint8List(1), source: 'test');
    await controller.detectImages([first]);
    await controller.detectImages([second]);
    expect(controller.draftMaterials, isEmpty);
    controller.addManualMaterial('motor');
    expect(controller.draftMaterials.single.materialId, 'motor');
  });

  test('loading state is visible and a newer request supersedes the old one',
      () async {
    final service = DeferredDetectionService();
    final controller = controllerWith(service);
    addTearDown(controller.dispose);
    final image = DraftImage(id: 'one', bytes: Uint8List(1), source: 'test');
    final pending = controller.detectImages([image]);
    expect(controller.detecting, isTrue);
    expect(controller.detectionMessage, mt('mr', 'identifying'));
    final replacement = controller.detectImages([image]);
    service.completer.complete(detected('pcb', .8));
    await Future.wait([pending, replacement]);
    expect(controller.detecting, isFalse);
  });

  test('Battery and CRT require acknowledgement and category changes reset it',
      () async {
    final controller =
        controllerWith(SequenceDetectionService([detected('battery', .9)]));
    addTearDown(controller.dispose);
    await controller.saveProfile('9876543210', 'Pune');
    controller.addManualMaterial('battery');
    controller.updateMaterial(0, weightKg: 1);
    expect(controller.canCreateLot, isFalse);
    controller.acknowledgeSafety('battery');
    expect(controller.canCreateLot, isTrue);
    controller.replaceMaterial(0, 'crt');
    expect(controller.safetyAcknowledged('battery'), isFalse);
    expect(controller.safetyAcknowledged('crt'), isFalse);
    expect(controller.canCreateLot, isFalse);
    controller.acknowledgeSafety('crt');
    expect(controller.canCreateLot, isTrue);
  });

  test('retry replaces a failed result with a successful suggestion', () async {
    final service = SequenceDetectionService([
      DetectionResult.error('INFERENCE_UNAVAILABLE', 'Offline'),
      detected('motor', .88),
    ]);
    final controller = controllerWith(service);
    addTearDown(controller.dispose);
    final image = DraftImage(id: 'one', bytes: Uint8List(1), source: 'test');
    controller.draftImages.add(image);
    await controller.detectImages([image]);
    expect(controller.draftMaterials, isEmpty);
    await controller.retryDetection('one');
    expect(service.calls, 2);
    expect(controller.draftMaterials.single.materialId, 'motor');
  });

  test('all safety copy changes with English Hindi and Marathi', () {
    for (final language in ['en', 'hi', 'mr']) {
      for (final key in [
        'safetyTitle',
        'batteryWarningTitle',
        'batteryWarningBody',
        'batteryWarningSteps',
        'crtWarningTitle',
        'crtWarningBody',
        'crtWarningSteps',
        'acknowledgeSafety',
        'speakSafety',
      ]) {
        expect(mt(language, key), isNot(key));
      }
    }
    expect(mt('hi', 'batteryWarningTitle'),
        isNot(mt('en', 'batteryWarningTitle')));
    expect(mt('mr', 'crtWarningTitle'), isNot(mt('en', 'crtWarningTitle')));
  });
}
