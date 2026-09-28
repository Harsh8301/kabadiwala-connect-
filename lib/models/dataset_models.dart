// Material Dataset
// One row per material occurrence captured in a lot (not the static catalog),
// so it doubles as ML training input: category, subcategory, description,
// image, approximate weight, condition, source type, and estimated value.
class MaterialDatasetRecord {
  const MaterialDatasetRecord({
    required this.materialId,
    required this.lotId,
    required this.category,
    required this.subCategory,
    required this.description,
    required this.imageRef,
    required this.weightKg,
    required this.condition,
    required this.source,
    required this.estimatedValue,
    required this.capturedAt,
  });

  final String materialId;
  final String lotId;
  final String category;
  final String subCategory;
  final String description;
  final String? imageRef;
  final double weightKg;
  final String condition;
  final String source;
  final double estimatedValue;
  final DateTime capturedAt;

  Map<String, dynamic> toJson() => {
        'materialId': materialId,
        'lotId': lotId,
        'category': category,
        'subCategory': subCategory,
        'description': description,
        'imageRef': imageRef,
        'weightKg': weightKg,
        'condition': condition,
        'source': source,
        'estimatedValue': estimatedValue,
        'capturedAt': capturedAt.toIso8601String(),
      };
}

// Price Dataset
class PriceDatasetRecord {
  const PriceDatasetRecord({
    required this.materialId,
    required this.location,
    required this.date,
    required this.buyingPrice,
    required this.quotedPrice,
    required this.unit,
    required this.marketRangeLow,
    required this.marketRangeHigh,
    required this.recyclerId,
    required this.history,
  });

  final String materialId;
  final String location;
  final DateTime date;
  final double buyingPrice;
  final double quotedPrice;
  final String unit;
  final double marketRangeLow;
  final double marketRangeHigh;
  final String recyclerId;
  final List<Map<String, dynamic>> history;

  Map<String, dynamic> toJson() => {
        'materialId': materialId,
        'location': location,
        'date': date.toIso8601String(),
        'buyingPrice': buyingPrice,
        'quotedPrice': quotedPrice,
        'unit': unit,
        'marketRangeLow': marketRangeLow,
        'marketRangeHigh': marketRangeHigh,
        'recyclerId': recyclerId,
        'history': history,
      };
}

// Recycler Dataset
class RecyclerDatasetRecord {
  const RecyclerDatasetRecord({
    required this.recyclerId,
    required this.name,
    required this.location,
    required this.acceptedMaterials,
    required this.authorizationStatus,
    required this.contact,
    required this.offeredRates,
    required this.pickupAvailable,
    required this.serviceArea,
  });

  final String recyclerId;
  final String name;
  final String location;
  final List<String> acceptedMaterials;
  final String authorizationStatus;
  final String contact;
  final Map<String, double> offeredRates;
  final bool pickupAvailable;
  final String serviceArea;

  Map<String, dynamic> toJson() => {
        'recyclerId': recyclerId,
        'name': name,
        'location': location,
        'acceptedMaterials': acceptedMaterials,
        'authorizationStatus': authorizationStatus,
        'contact': contact,
        'offeredRates': offeredRates,
        'pickupAvailable': pickupAvailable,
        'serviceArea': serviceArea,
      };
}

// Transaction Dataset
class TransactionDatasetRecord {
  const TransactionDatasetRecord({
    required this.lotId,
    required this.collectorId, // will be anonymized
    required this.materialIds,
    required this.totalWeightKg,
    required this.quotedPrice,
    required this.finalPrice,
    required this.recyclerId,
    required this.collectionLocation,
    required this.handoverLocation,
    required this.timestamp,
    required this.paymentStatus,
    required this.transactionStatus,
  });

  final String lotId;
  final String collectorId;
  final List<String> materialIds;
  final double totalWeightKg;
  final double quotedPrice;
  final double? finalPrice;
  final String recyclerId;
  final String collectionLocation;
  final String handoverLocation;
  final DateTime timestamp;
  final String paymentStatus;
  final String transactionStatus;

  Map<String, dynamic> toJson() => {
        'lotId': lotId,
        'collectorId': collectorId,
        'materialIds': materialIds,
        'totalWeightKg': totalWeightKg,
        'quotedPrice': quotedPrice,
        'finalPrice': finalPrice,
        'recyclerId': recyclerId,
        'collectionLocation': collectionLocation,
        'handoverLocation': handoverLocation,
        'timestamp': timestamp.toIso8601String(),
        'paymentStatus': paymentStatus,
        'transactionStatus': transactionStatus,
      };
}

// Traceability Dataset
class TraceabilityDatasetRecord {
  const TraceabilityDatasetRecord({
    required this.lotId,
    required this.photos,
    required this.weightKg,
    required this.timestamp,
    required this.gpsCoords,
    required this.handoverReference,
    required this.recyclerConfirmed,
    required this.statusHistory,
  });

  final String lotId;
  final List<String> photos; // URIs
  final double weightKg;
  final DateTime timestamp;
  final String gpsCoords;
  final String handoverReference;
  final bool recyclerConfirmed;
  final List<String> statusHistory;

  Map<String, dynamic> toJson() => {
        'lotId': lotId,
        'photos': photos,
        'weightKg': weightKg,
        'timestamp': timestamp.toIso8601String(),
        'gpsCoords': gpsCoords,
        'handoverReference': handoverReference,
        'recyclerConfirmed': recyclerConfirmed,
        'statusHistory': statusHistory,
      };
}

// Collector Dataset (Anonymized)
class CollectorDatasetRecord {
  const CollectorDatasetRecord({
    required this.collectorId,
    required this.language,
    required this.generalArea,
    required this.transactionCount,
    required this.totalEarnings,
  });

  final String collectorId; // Anonymized hash
  final String language;
  final String generalArea;
  final int transactionCount;
  final double totalEarnings;

  Map<String, dynamic> toJson() => {
        'collectorId': collectorId,
        'language': language,
        'generalArea': generalArea,
        'transactionCount': transactionCount,
        'totalEarnings': totalEarnings,
      };
}

// AI/ML Training Dataset
// One row per labelled material image: material, weight, price, location and
// the transaction it came from, so a model can be trained/validated on real
// field captures rather than a synthetic set.
class AiMlDatasetRecord {
  const AiMlDatasetRecord({
    required this.recordId,
    required this.imageRef,
    required this.materialCategory,
    required this.weightKg,
    required this.price,
    required this.location,
    required this.transactionId,
    required this.capturedAt,
  });

  final String recordId;
  final String imageRef;
  final String materialCategory;
  final double weightKg;
  final double price;
  final String location;
  final String transactionId;
  final DateTime capturedAt;

  Map<String, dynamic> toJson() => {
        'recordId': recordId,
        'imageRef': imageRef,
        'materialCategory': materialCategory,
        'weightKg': weightKg,
        'price': price,
        'location': location,
        'transactionId': transactionId,
        'capturedAt': capturedAt.toIso8601String(),
      };
}

/// Source, quality and limitations of the AI/ML dataset, as the PS requires
/// for any dataset backing proposed AI/ML functionality.
class AiMlDatasetProvenance {
  static const source =
      'Collector-captured lot photos labelled by Roboflow inference or manual '
      'correction during handover, paired with the weight, price and location '
      'recorded for that same transaction.';
  static const quality =
      'Labels are collector- or model-assigned and not independently audited; '
      'images vary in lighting, angle, background and compression; weights are '
      'collector-reported rather than calibrated-scale readings.';
  static const limitations =
      'Demo-scale, single-region (Maharashtra) volume covering only the seven '
      'seeded categories; no negative or background-clutter examples; not '
      'sized or balanced enough for production model training without a '
      'dedicated field-collection expansion.';

  static Map<String, dynamic> describe(int recordCount) => {
        'source': source,
        'size': '$recordCount labelled records',
        'quality': quality,
        'limitations': limitations,
      };
}
