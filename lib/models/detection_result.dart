class DetectionBox {
  const DetectionBox({
    required this.categoryId,
    required this.className,
    required this.confidence,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory DetectionBox.fromJson(Map<String, dynamic> json) => DetectionBox(
        categoryId: _appCategory(json['categoryId']?.toString() ?? 'other'),
        className: json['className']?.toString() ?? '',
        confidence: _num(json['confidence']),
        x: _num(json['x']),
        y: _num(json['y']),
        width: _num(json['width']),
        height: _num(json['height']),
      );

  final String categoryId;
  final String className;
  final double confidence;
  final double x;
  final double y;
  final double width;
  final double height;

  bool get hasBox => width > 0 && height > 0;
}

class DetectionResult {
  const DetectionResult({
    required this.success,
    required this.status,
    required this.categoryId,
    required this.className,
    required this.confidence,
    required this.predictions,
    required this.imageWidth,
    required this.imageHeight,
    this.code,
    this.message,
  });

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    final image = json['image'] is Map<String, dynamic>
        ? json['image'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final predictions = json['predictions'] is List
        ? (json['predictions'] as List)
            .whereType<Map<String, dynamic>>()
            .map(DetectionBox.fromJson)
            .toList()
        : <DetectionBox>[];

    return DetectionResult(
      success: json['success'] == true,
      status: json['status']?.toString() ?? 'error',
      categoryId: _nullableAppCategory(json['categoryId']?.toString()),
      className: json['className']?.toString(),
      confidence: _num(json['confidence']),
      predictions: predictions,
      imageWidth: _num(image['width']),
      imageHeight: _num(image['height']),
      code: json['code']?.toString(),
      message: json['message']?.toString(),
    );
  }

  factory DetectionResult.error(String code, String message) => DetectionResult(
        success: false,
        status: 'error',
        categoryId: null,
        className: null,
        confidence: 0,
        predictions: const [],
        imageWidth: 0,
        imageHeight: 0,
        code: code,
        message: message,
      );

  final bool success;
  final String status;
  final String? categoryId;
  final String? className;
  final double confidence;
  final List<DetectionBox> predictions;
  final double imageWidth;
  final double imageHeight;
  final String? code;
  final String? message;

  bool get hasSuggestion =>
      success && categoryId != null && categoryId!.isNotEmpty;
}

double _num(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _appCategory(String value) => value == 'cable' ? 'cables' : value;

String? _nullableAppCategory(String? value) {
  if (value == null || value.isEmpty) return null;
  return _appCategory(value);
}
