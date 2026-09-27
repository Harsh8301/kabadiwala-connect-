import 'dart:convert';
import 'dart:io';

import 'package:kabadiwala_connect/services/detection_service.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.isEmpty || arguments.length > 2) {
    stderr.writeln(
      'Usage: dart run tool/live_detection_smoke.dart IMAGE_PATH [EXPECTED_CATEGORY]',
    );
    exitCode = 2;
    return;
  }

  final image = File(arguments[0]);
  if (!await image.exists()) {
    stderr.writeln('Image file does not exist.');
    exitCode = 2;
    return;
  }

  final result = await DetectionService().detect(await image.readAsBytes());
  stdout.writeln(jsonEncode({
    'success': result.success,
    'status': result.status,
    'categoryId': result.categoryId,
    'className': result.className,
    'confidence': result.confidence,
    'code': result.code,
    'predictions': result.predictions
        .map((prediction) => {
              'className': prediction.className,
              'categoryId': prediction.categoryId,
              'confidence': prediction.confidence,
            })
        .toList(),
  }));

  if (!result.success ||
      (arguments.length == 2 && result.categoryId != arguments[1])) {
    exitCode = 1;
  }
}
