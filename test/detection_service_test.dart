import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kabadiwala_connect/app_controller.dart';
import 'package:kabadiwala_connect/models/detection_result.dart';
import 'package:kabadiwala_connect/services/detection_service.dart';

class FakeDetectionService extends DetectionService {
  FakeDetectionService(this.result);
  final DetectionResult result;

  @override
  Future<DetectionResult> detect(Uint8List imageBytes) async => result;
}

void main() {
  test('DetectionService parses normalized Roboflow response', () async {
    late http.Request receivedRequest;
    final service = DetectionService(
      endpoint: 'http://example.test/api/detect',
      client: MockClient((request) async {
        receivedRequest = request;
        return http.Response(
          jsonEncode({
            'success': true,
            'status': 'detected',
            'categoryId': 'battery',
            'className': 'battery-cell',
            'confidence': .91,
            'predictions': [
              {
                'categoryId': 'battery',
                'className': 'battery-cell',
                'confidence': .91,
                'x': 100,
                'y': 80,
                'width': 40,
                'height': 30,
              }
            ],
            'image': {'width': 320, 'height': 240},
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final result = await service.detect(
      Uint8List.fromList([0xff, 0xd8, 0xff, 0x00]),
    );
    expect(result.success, isTrue);
    expect(receivedRequest.method, 'POST');
    expect(receivedRequest.headers['content-type'],
        startsWith('multipart/form-data'));
    expect(latin1.decode(receivedRequest.bodyBytes), contains('name="image"'));
    expect(result.categoryId, 'battery');
    expect(result.confidence, .91);
    expect(result.predictions.single.hasBox, isTrue);
  });

  test('DetectionService maps web cable id to Flutter cables id', () async {
    final result = DetectionResult.fromJson({
      'success': true,
      'status': 'detected',
      'categoryId': 'cable',
      'confidence': .8,
      'predictions': [
        {'categoryId': 'cable', 'confidence': .8}
      ],
      'image': {'width': 100, 'height': 100},
    });

    expect(result.categoryId, 'cables');
    expect(result.predictions.single.categoryId, 'cables');
  });

  test('controller uses AI suggestion instead of defaulting every image to PCB',
      () async {
    final controller = AppController(
      enableTts: false,
      detectionService: FakeDetectionService(
        DetectionResult.fromJson({
          'success': true,
          'status': 'detected',
          'categoryId': 'battery',
          'className': 'battery-cell',
          'confidence': .91,
          'predictions': [],
          'image': {'width': 100, 'height': 100},
        }),
      ),
    );

    controller.setCollectorId('+919999999999');
    controller.startPickup();
    controller.setWeight(1);
    controller.capturedImage = Uint8List.fromList([1, 2, 3]);

    await controller.classifyCapturedImage();

    expect(controller.screen, AppScreen.confirm);
    expect(controller.detectedCategory, 'battery');
    expect(controller.confirmedCategory, 'battery');
    expect(controller.detectionConfidence, .91);
  });

  test('controller keeps manual fallback when detection fails', () async {
    final controller = AppController(
      enableTts: false,
      detectionService: FakeDetectionService(
        DetectionResult.error('INFERENCE_UNAVAILABLE', 'Offline'),
      ),
    );

    controller.setCollectorId('+919999999999');
    controller.startPickup();
    controller.setWeight(1);
    controller.capturedImage = Uint8List.fromList([1, 2, 3]);

    await controller.classifyCapturedImage();

    expect(controller.screen, AppScreen.confirm);
    expect(controller.detectedCategory, isEmpty);
    expect(controller.confirmedCategory, isEmpty);
    expect(controller.canContinueConfirm, isFalse);

    controller.setCategory('motor');
    expect(controller.confirmedCategory, 'motor');
    expect(controller.canContinueConfirm, isTrue);
  });
}
