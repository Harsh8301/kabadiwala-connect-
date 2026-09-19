import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config/api_config.dart';
import '../models/detection_result.dart';

class DetectionService {
  DetectionService({
    http.Client? client,
    String? endpoint,
    String? baseUrl,
    this.timeout = const Duration(seconds: 18),
  })  : _client = client ?? http.Client(),
        endpoint = endpoint ??
            (baseUrl == null
                ? ApiConfig.scrapDetectionUrl
                : _endpointFor(baseUrl));

  static String _endpointFor(String baseUrl) =>
      '${baseUrl.replaceFirst(RegExp(r'/+$'), '')}/api/detection/scrap';

  final http.Client _client;
  final String endpoint;
  final Duration timeout;

  Future<DetectionResult> detect(Uint8List imageBytes) async {
    if (imageBytes.isEmpty) {
      return DetectionResult.error('INVALID_IMAGE', 'No image was selected.');
    }
    final mimeType = _imageMimeType(imageBytes);
    if (mimeType == null) {
      return DetectionResult.error(
        'INVALID_FILE_TYPE',
        'Choose a JPEG, PNG, or WebP image.',
      );
    }
    if (imageBytes.length > 8 * 1024 * 1024) {
      return DetectionResult.error(
        'FILE_TOO_LARGE',
        'Choose an image smaller than 8 MB.',
      );
    }

    final uri = Uri.tryParse(endpoint);
    if (uri == null || !uri.hasScheme) {
      return DetectionResult.error(
        'INVALID_ENDPOINT',
        'Detection endpoint is not configured correctly.',
      );
    }

    try {
      final request = http.MultipartRequest('POST', uri)
        ..files.add(http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename:
              'scrap.${mimeType.subtype == 'jpeg' ? 'jpg' : mimeType.subtype}',
          contentType: mimeType,
        ));
      final streamed = await _client.send(request).timeout(timeout);
      final response = await http.Response.fromStream(streamed);
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return DetectionResult.error(
          'INVALID_RESPONSE',
          'Detection service returned an unreadable response.',
        );
      }
      final result = DetectionResult.fromJson(decoded);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return result;
      }
      return DetectionResult.error(
        result.code ?? 'DETECTION_UNAVAILABLE',
        result.message ?? 'Detection service is unavailable.',
      );
    } on TimeoutException {
      return DetectionResult.error(
        'DETECTION_TIMEOUT',
        'Detection took too long. Select the material manually or retry.',
      );
    } on FormatException {
      return DetectionResult.error(
        'INVALID_RESPONSE',
        'Detection service returned an unreadable response.',
      );
    } catch (_) {
      return DetectionResult.error(
        'DETECTION_UNAVAILABLE',
        'Detection service is unavailable. Select the material manually.',
      );
    }
  }
}

MediaType? _imageMimeType(Uint8List bytes) {
  if (bytes.length >= 3 &&
      bytes[0] == 0xff &&
      bytes[1] == 0xd8 &&
      bytes[2] == 0xff) {
    return MediaType('image', 'jpeg');
  }
  if (bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4e &&
      bytes[3] == 0x47) {
    return MediaType('image', 'png');
  }
  if (bytes.length >= 12 &&
      String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
      String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP') {
    return MediaType('image', 'webp');
  }
  return null;
}
