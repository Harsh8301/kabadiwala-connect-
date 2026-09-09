import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/app_data.dart';
import 'models/lot_record.dart';
import 'models/material_item.dart';

enum AppScreen { welcome, capture, confirm, price, lot, ledger }

class AppController extends ChangeNotifier {
  static const _ledgerKey = 'kwc_ledger_flutter';

  final ImagePicker _picker = ImagePicker();
  final FlutterTts _tts = FlutterTts();
  final List<AppScreen> _history = [];

  AppScreen screen = AppScreen.welcome;
  String language = 'mr';
  String detectedCategory = 'pcb';
  String confirmedCategory = 'pcb';
  double weightKg = 1.5;
  String paymentMethod = 'cash';
  bool safetyAcknowledged = false;
  bool isScanning = false;
  Uint8List? capturedImage;
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
    await _tts.setSpeechRate(0.46);
    await _tts.setPitch(1.0);
  }

  String t(String key) => textFor(language, key);
  MaterialItem get material => materials[confirmedCategory] ?? materials['pcb']!;
  int get formalEstimate => (weightKg * material.formalRate).round();
  int get informalEstimate => (weightKg * material.informalRate).round();
  int get potentialExtra => max(0, formalEstimate - informalEstimate);
  int get step => screen.index;
  String get currencyFormal => formatCurrency(formalEstimate);
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
        await selectSample('pcb', useGeneratedPreview: false);
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
    if (useGeneratedPreview) capturedImage = null;
    isScanning = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    isScanning = false;
    goTo(AppScreen.confirm);
  }

  void setCategory(String category) {
    confirmedCategory = category;
    safetyAcknowledged = false;
    notifyListeners();
  }

  void setWeight(double value) {
    weightKg = (value.clamp(0.1, 100) * 10).round() / 10;
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
    await _tts.stop();
    await _tts.setLanguage(locale);
    await _tts.speak(message);
  }

  Future<void> stopSpeech() async {
    await _tts.stop();
  }

  String priceSpeech() {
    final name = material.nameFor(language);
    return switch (language) {
      'mr' => '$name, वजन $weightKg किलो. अधिकृत संदर्भ अंदाज: $formalEstimate रुपये. स्थानिक अनौपचारिक भाव: $informalEstimate रुपये. अधिकृत केंद्रात अंदाजे $potentialExtra रुपये अतिरिक्त नफा मिळू शकतो.',
      'hi' => '$name, वजन $weightKg किलो. अधिकृत संदर्भ अनुमान: $formalEstimate रुपये. स्थानीय भाव: $informalEstimate रुपये. अधिकृत केंद्र पर लगभग $potentialExtra रुपये अतिरिक्त लाभ मिल सकता है।',
      _ => '$name, weight $weightKg kilograms. Formal reference estimate: $formalEstimate rupees. Typical informal price: $informalEstimate rupees. Potential additional value: $potentialExtra rupees.',
    };
  }

  Map<String, dynamic> get lotPayload => {
        'lot': lotId,
        'cat': confirmedCategory,
        'kg': weightKg,
        'formalPrice': formalEstimate,
        'ts': DateTime.now().toIso8601String(),
        'org': 'JNARDDC_SIH26',
      };

  String get lotPayloadJson => jsonEncode(lotPayload);

  Future<void> completeHandover() async {
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
        hasWitnessImage: witnessImage != null || sampleWitness,
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
    witnessImage = null;
    sampleWitness = false;
    detectedCategory = 'pcb';
    confirmedCategory = 'pcb';
    weightKg = 1.5;
    paymentMethod = 'cash';
    safetyAcknowledged = false;
    lotId = _generateLotId();
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
    return values[language == 'mr' ? 0 : language == 'hi' ? 1 : 2];
  }

  String _generateLotId() =>
      'KWC-2026-${1000 + Random().nextInt(9000)}';

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
