import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/app_data.dart';
import 'models/lot_record.dart';
import 'models/material_item.dart';
import 'models/detection_result.dart';
import 'services/detection_service.dart';

enum AppScreen {
  welcome,
  capture,
  confirm,
  price,
  lot,
  recyclerMatch,
  payment,
  ledger,
  recyclerView,
}

class AppController extends ChangeNotifier {
  static const _ledgerKey = 'kwc_ledger_flutter';

  final ImagePicker _picker = ImagePicker();
  final FlutterTts? _tts;
  final DetectionService _detectionService;
  final List<AppScreen> _history = [];

  AppController({DetectionService? detectionService, bool enableTts = true})
      : _tts = enableTts ? FlutterTts() : null,
        _detectionService = detectionService ?? DetectionService();

  AppScreen screen = AppScreen.welcome;
  String language = 'mr';
  String collectorId = '';
  String detectedCategory = 'pcb';
  String confirmedCategory = 'pcb';
  String detectionStatus = 'idle';
  String detectionClassName = '';
  String detectionError = '';
  String detectionSource = '';
  double detectionConfidence = 0;
  List<DetectionBox> detectionPredictions = [];
  double detectionImageWidth = 0;
  double detectionImageHeight = 0;
  int _detectionRequestId = 0;
  double weightKg = 0;
  String paymentMethod = 'cash';
  bool safetyAcknowledged = false;
  bool isScanning = false;
  bool isLocating = false;
  double? collectionLat;
  double? collectionLng;
  String locationStatus = 'not requested';
  String selectedRecyclerId = '';
  Uint8List? capturedImage;
  bool sampleScrapImage = false;
  Uint8List? witnessImage;
  bool sampleWitness = false;
  String lotId = '';
  List<LotRecord> ledger = [];

  Future<void> load() async {
    lotId = _generateLotId();
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_ledgerKey);
    if (saved != null && saved.isNotEmpty) {
      try {
        ledger = LotRecord.decodeList(saved);
      } catch (_) {
        ledger = [];
      }
    }
    await _tts?.setSpeechRate(0.46);
    await _tts?.setPitch(1.0);
  }

  String t(String key) => textFor(language, key);
  MaterialItem get material =>
      materials[confirmedCategory] ?? materials['pcb']!;
  int get formalEstimate => (weightKg * material.formalRate).round();
  int get informalEstimate => (weightKg * material.informalRate).round();
  int get potentialExtra => max(0, formalEstimate - informalEstimate);
  int get step => switch (screen) {
        AppScreen.capture => 1,
        AppScreen.confirm => 2,
        AppScreen.price => 3,
        AppScreen.lot => 4,
        AppScreen.recyclerMatch || AppScreen.payment => 5,
        AppScreen.welcome || AppScreen.ledger || AppScreen.recyclerView => 0,
      };
  String get currencyFormal => formatCurrency(formalEstimate);
  bool get canContinueCapture =>
      (capturedImage != null || sampleScrapImage) && weightKg > 0;
  bool get canContinueConfirm => confirmedCategory.isNotEmpty;
  RecyclerProfile? get selectedRecycler => recyclers
      .where((recycler) => recycler.recyclerId == selectedRecyclerId)
      .firstOrNull;

  String get collectionLocationLabel {
    if (collectionLat == null || collectionLng == null) {
      return locationStatus == 'unavailable'
          ? 'Location unavailable'
          : 'Location pending';
    }
    return '${collectionLat!.toStringAsFixed(5)}, ${collectionLng!.toStringAsFixed(5)}';
  }

  String formatCurrency(num amount) {
    final value = amount.round();
    final negative = value < 0;
    final digits = value.abs().toString();
    if (digits.length <= 3) return '₹${negative ? '-' : ''}$digits';
    final tail = digits.substring(digits.length - 3);
    var head = digits.substring(0, digits.length - 3);
    final groups = <String>[];
    while (head.length > 2) {
      groups.insert(0, head.substring(head.length - 2));
      head = head.substring(0, head.length - 2);
    }
    if (head.isNotEmpty) groups.insert(0, head);
    return '₹${negative ? '-' : ''}${groups.join(',')},$tail';
  }

  void setLanguage(String value) {
    language = value;
    notifyListeners();
  }

  void setCollectorId(String value) {
    collectorId = value.trim();
    notifyListeners();
  }

  void startPickup() {
    if (collectorId.isEmpty) return;
    resetCurrentPickup();
    goTo(AppScreen.capture);
  }

  void goTo(AppScreen next, {bool remember = true}) {
    if (next == screen) return;
    stopSpeech();
    if (remember) _history.add(screen);
    screen = next;
    notifyListeners();
  }

  void goBack() {
    stopSpeech();
    screen = _history.isEmpty ? AppScreen.welcome : _history.removeLast();
    notifyListeners();
  }

  Future<bool> chooseImage(ImageSource source, {bool witness = false}) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1600,
      );
      if (file == null) return false;
      final bytes = await file.readAsBytes();
      if (witness) {
        witnessImage = bytes;
        sampleWitness = false;
        notifyListeners();
      } else {
        capturedImage = bytes;
        sampleScrapImage = false;
        _resetDetection(keepCategory: false);
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> selectSample(
    String category, {
    bool useGeneratedPreview = true,
  }) async {
    detectedCategory = category;
    confirmedCategory = category;
    safetyAcknowledged = false;
    detectionStatus = 'demo';
    detectionClassName = materials[category]?.nameFor('en') ?? category;
    detectionConfidence = 1;
    detectionSource = 'demo';
    detectionError = '';
    detectionPredictions = [];
    detectionImageWidth = 0;
    detectionImageHeight = 0;
    sampleScrapImage = useGeneratedPreview;
    if (useGeneratedPreview) capturedImage = null;
    isScanning = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    isScanning = false;
    goTo(AppScreen.confirm);
  }

  Future<void> classifyCapturedImage() async {
    if (capturedImage == null && !sampleScrapImage) return;
    if (sampleScrapImage) {
      goTo(AppScreen.confirm);
      return;
    }

    final requestId = ++_detectionRequestId;
    _resetDetection(keepCategory: false, cancelRequests: false);
    safetyAcknowledged = false;
    detectionStatus = 'scanning';
    detectionSource = 'roboflow';
    isScanning = true;
    notifyListeners();

    final started = DateTime.now();
    final result = await _detectionService.detect(capturedImage!);
    final elapsed = DateTime.now().difference(started);
    if (elapsed < const Duration(milliseconds: 450)) {
      await Future<void>.delayed(const Duration(milliseconds: 450) - elapsed);
    }
    if (requestId != _detectionRequestId) return;

    isScanning = false;
    detectionStatus = result.success ? result.status : 'error';
    detectionError =
        result.success ? '' : (result.message ?? t('detectionUnavailable'));
    detectionClassName = result.className ?? '';
    detectionConfidence = result.confidence;
    detectionPredictions = result.predictions;
    detectionImageWidth = result.imageWidth;
    detectionImageHeight = result.imageHeight;

    if (result.hasSuggestion && materials.containsKey(result.categoryId)) {
      detectedCategory = result.categoryId!;
      confirmedCategory = result.categoryId!;
    } else {
      detectedCategory = '';
      confirmedCategory = '';
      if (detectionStatus != 'error') detectionStatus = 'uncertain';
    }
    goTo(AppScreen.confirm);
  }

  void setCategory(String category) {
    confirmedCategory = category;
    safetyAcknowledged = false;
    notifyListeners();
  }

  Future<void> retryDetection() async {
    if (capturedImage == null || isScanning) return;
    await classifyCapturedImage();
  }

  void setWeight(double value) {
    weightKg = (value.clamp(0, 100) * 10).round() / 10;
    notifyListeners();
  }

  Future<void> prepareLotRecord() async {
    lotId = lotId.isEmpty ? _generateLotId() : lotId;
    await requestLocation();
  }

  Future<void> requestLocation() async {
    isLocating = true;
    locationStatus = 'requesting';
    notifyListeners();
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        locationStatus = 'unavailable';
        collectionLat = null;
        collectionLng = null;
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      collectionLat = position.latitude;
      collectionLng = position.longitude;
      locationStatus = 'available';
    } catch (_) {
      locationStatus = 'unavailable';
      collectionLat = null;
      collectionLng = null;
    } finally {
      isLocating = false;
      notifyListeners();
    }
  }

  List<RecyclerProfile> recyclerMatches() {
    final matches = recyclers
        .where((recycler) =>
            recycler.materialsAccepted.contains(confirmedCategory))
        .toList();
    matches
        .sort((a, b) => distanceToRecycler(a).compareTo(distanceToRecycler(b)));
    return matches.take(3).toList();
  }

  double distanceToRecycler(RecyclerProfile recycler) {
    final lat = collectionLat ?? 19.076;
    final lng = collectionLng ?? 72.8777;
    return Geolocator.distanceBetween(
          lat,
          lng,
          recycler.location.lat,
          recycler.location.lng,
        ) /
        1000;
  }

  void chooseRecycler(String recyclerId) {
    selectedRecyclerId = recyclerId;
    notifyListeners();
  }

  void setPayment(String method) {
    paymentMethod = method;
    notifyListeners();
  }

  void useSampleWitness() {
    witnessImage = null;
    sampleWitness = true;
    notifyListeners();
  }

  void acknowledgeSafety() {
    safetyAcknowledged = true;
    stopSpeech();
    notifyListeners();
  }

  Future<void> speak(String message) async {
    final locale = switch (language) {
      'mr' => 'mr-IN',
      'hi' => 'hi-IN',
      _ => 'en-IN',
    };
    final tts = _tts;
    if (tts == null) return;
    await tts.stop();
    await tts.setLanguage(locale);
    await tts.speak(message);
  }

  Future<void> stopSpeech() async {
    await _tts?.stop();
  }

  String priceSpeech() {
    final name = material.nameFor(language);
    return switch (language) {
      'mr' =>
        '$name, वजन $weightKg किलो. अधिकृत संदर्भ अंदाज: $formalEstimate रुपये. स्थानिक अनौपचारिक भाव: $informalEstimate रुपये. अधिकृत केंद्रात अंदाजे $potentialExtra रुपये अतिरिक्त नफा मिळू शकतो.',
      'hi' =>
        '$name, वजन $weightKg किलो. अधिकृत संदर्भ अनुमान: $formalEstimate रुपये. स्थानीय भाव: $informalEstimate रुपये. अधिकृत केंद्र पर लगभग $potentialExtra रुपये अतिरिक्त लाभ मिल सकता है।',
      _ =>
        '$name, weight $weightKg kilograms. Formal reference estimate: $formalEstimate rupees. Typical informal price: $informalEstimate rupees. Potential additional value: $potentialExtra rupees.',
    };
  }

  Map<String, dynamic> get lotPayload => {
        'lot': lotId,
        'cat': confirmedCategory,
        'kg': weightKg,
        'formalPrice': formalEstimate,
        'gps': collectionLocationLabel,
        'recycler': selectedRecyclerId,
        'ts': DateTime.now().toIso8601String(),
        'org': 'JNARDDC_SIH26',
      };

  String get lotPayloadJson => jsonEncode(lotPayload);

  Future<void> completeHandover() async {
    final recycler = selectedRecycler;
    ledger = [
      ...ledger,
      LotRecord(
        lotId: lotId,
        category: confirmedCategory,
        weightKg: weightKg,
        formalPrice: formalEstimate,
        informalPrice: informalEstimate,
        potentialExtra: potentialExtra,
        paymentMethod: paymentMethod,
        paymentStatus: paymentMethod == 'cash' ? 'Paid' : 'Pending',
        transactionStatus: 'pending confirmation',
        recyclerConfirmation: false,
        recyclerId: recycler?.recyclerId ?? '',
        recyclerName: recycler?.name ?? 'Recycler not selected',
        collectionLocationLabel: collectionLocationLabel,
        handoverLocationLabel:
            recycler?.location.address ?? 'Handover location unavailable',
        hasWitnessImage: witnessImage != null || sampleWitness,
        scrapImageBase64:
            capturedImage == null ? null : base64Encode(capturedImage!),
        witnessImageBase64: witnessImage == null
            ? (sampleWitness ? 'sample' : null)
            : base64Encode(witnessImage!),
        timestamp: DateTime.now(),
      ),
    ];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ledgerKey, LotRecord.encodeList(ledger));
    goTo(AppScreen.ledger);
  }

  Future<void> confirmRecyclerReceipt(String lotId) async {
    ledger = [
      for (final record in ledger)
        if (record.lotId == lotId)
          LotRecord(
            lotId: record.lotId,
            category: record.category,
            weightKg: record.weightKg,
            formalPrice: record.formalPrice,
            informalPrice: record.informalPrice,
            potentialExtra: record.potentialExtra,
            paymentMethod: record.paymentMethod,
            paymentStatus: 'Paid',
            transactionStatus: 'completed',
            recyclerConfirmation: true,
            recyclerId: record.recyclerId,
            recyclerName: record.recyclerName,
            collectionLocationLabel: record.collectionLocationLabel,
            handoverLocationLabel: record.handoverLocationLabel,
            hasWitnessImage: record.hasWitnessImage,
            scrapImageBase64: record.scrapImageBase64,
            witnessImageBase64: record.witnessImageBase64,
            timestamp: record.timestamp,
          )
        else
          record,
    ];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ledgerKey, LotRecord.encodeList(ledger));
    notifyListeners();
  }

  Future<void> resetDemo() async {
    ledger = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ledgerKey);
    resetCurrentPickup();
    _history.clear();
    screen = AppScreen.welcome;
    notifyListeners();
  }

  void resetCurrentPickup() {
    capturedImage = null;
    sampleScrapImage = false;
    witnessImage = null;
    sampleWitness = false;
    detectedCategory = 'pcb';
    confirmedCategory = 'pcb';
    _resetDetection(keepCategory: false);
    weightKg = 0;
    paymentMethod = 'cash';
    safetyAcknowledged = false;
    collectionLat = null;
    collectionLng = null;
    locationStatus = 'not requested';
    selectedRecyclerId = '';
    lotId = _generateLotId();
  }

  void _resetDetection({
    required bool keepCategory,
    bool cancelRequests = true,
  }) {
    if (cancelRequests) _detectionRequestId += 1;
    if (!keepCategory) {
      detectedCategory = '';
      confirmedCategory = '';
    }
    detectionStatus = 'idle';
    detectionClassName = '';
    detectionError = '';
    detectionSource = '';
    detectionConfidence = 0;
    detectionPredictions = [];
    detectionImageWidth = 0;
    detectionImageHeight = 0;
    isScanning = false;
  }

  void startAnother() {
    resetCurrentPickup();
    goTo(AppScreen.capture);
  }

  String impactFor(LotRecord record) {
    final weight = record.weightKg;
    final values = switch (record.category) {
      'cables' => <String>[
          'अंदाजे ~${(weight * 650).round()} ग्रॅम तांबे पुनर्प्राप्ती क्षमता',
          'लगभग ~${(weight * 650).round()} ग्राम तांबा पुनर्प्राप्ति क्षमता',
          'Estimated ~${(weight * 650).round()}g Recoverable Pure Copper',
        ],
      'pcb' => <String>[
          'अंदाजे ~${(weight * .2).toStringAsFixed(2)} ग्रॅम सोने-समतुल्य व ~${(weight * 100).round()} ग्रॅम तांबे',
          'लगभग ~${(weight * .2).toStringAsFixed(2)} ग्राम सोना-समकक्ष व ~${(weight * 100).round()} ग्राम तांबा',
          'Estimated ~${(weight * .2).toStringAsFixed(2)}g Gold-equivalent & ~${(weight * 100).round()}g Copper',
        ],
      'battery' => <String>[
          'अंदाजे ~${(weight * 50).round()} ग्रॅम कोबाल्ट/लिथियम सुरक्षित विल्हेवाट',
          'लगभग ~${(weight * 50).round()} ग्राम कोबाल्ट/लिथियम सुरक्षित निपटान',
          'Estimated ~${(weight * 50).round()}g Cobalt/Lithium safely contained',
        ],
      'motor' => <String>[
          'अंदाजे ~${(weight * 300).round()} ग्रॅम कॉइल तांबे पुनर्प्राप्ती क्षमता',
          'लगभग ~${(weight * 300).round()} ग्राम कॉइल तांबा पुनर्प्राप्ति क्षमता',
          'Estimated ~${(weight * 300).round()}g Winding Copper Recovery',
        ],
      'crt' => <String>[
          'अंदाजे ~${(weight * 150).round()} ग्रॅम विषारी शिसे सुरक्षित नियंत्रण',
          'लगभग ~${(weight * 150).round()} ग्राम जहरीला लेड सुरक्षित निस्तारण',
          'Estimated ~${(weight * 150).round()}g Toxic Lead kept out of soil',
        ],
      _ => <String>[
          'अंदाजे ~${(weight * 100).round()} ग्रॅम पुनर्वापरयोग्य धातू क्षमता',
          'लगभग ~${(weight * 100).round()} ग्राम रीसाइक्लेबल धातु क्षमता',
          'Estimated ~${(weight * 100).round()}g Recoverable Mixed Metals',
        ],
    };
    return values[language == 'mr'
        ? 0
        : language == 'hi'
            ? 1
            : 2];
  }

  String _generateLotId() =>
      'KC-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

  @override
  void dispose() {
    _tts?.stop();
    super.dispose();
  }
}
