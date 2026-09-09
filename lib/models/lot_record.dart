import 'dart:convert';

class LotRecord {
  const LotRecord({
    required this.lotId,
    required this.category,
    required this.weightKg,
    required this.formalPrice,
    required this.informalPrice,
    required this.potentialExtra,
    required this.paymentMethod,
    required this.hasWitnessImage,
    this.witnessImageBase64,
    required this.timestamp,
  });

  final String lotId;
  final String category;
  final double weightKg;
  final int formalPrice;
  final int informalPrice;
  final int potentialExtra;
  final String paymentMethod;
  final bool hasWitnessImage;
  final String? witnessImageBase64;
  final DateTime timestamp;

  String get timeLabel {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Map<String, dynamic> toJson() => {
        'lotId': lotId,
        'category': category,
        'weightKg': weightKg,
        'formalPrice': formalPrice,
        'informalPrice': informalPrice,
        'potentialExtra': potentialExtra,
        'paymentMethod': paymentMethod,
        'hasWitnessImage': hasWitnessImage,
        'witnessImageBase64': witnessImageBase64,
        'timestamp': timestamp.toIso8601String(),
      };

  factory LotRecord.fromJson(Map<String, dynamic> json) => LotRecord(
        lotId: json['lotId'] as String,
        category: json['category'] as String,
        weightKg: (json['weightKg'] as num).toDouble(),
        formalPrice: (json['formalPrice'] as num).round(),
        informalPrice: (json['informalPrice'] as num).round(),
        potentialExtra: (json['potentialExtra'] as num).round(),
        paymentMethod: json['paymentMethod'] as String? ?? 'cash',
        hasWitnessImage: json['hasWitnessImage'] as bool? ?? false,
        witnessImageBase64: json['witnessImageBase64'] as String?,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  static String encodeList(List<LotRecord> records) =>
      jsonEncode(records.map((record) => record.toJson()).toList());

  static List<LotRecord> decodeList(String raw) =>
      (jsonDecode(raw) as List<dynamic>)
          .map((item) => LotRecord.fromJson(item as Map<String, dynamic>))
          .toList();
}
