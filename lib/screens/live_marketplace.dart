import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../ministry_controller.dart';
import '../models/workflow_models.dart';
import '../data/ministry_data.dart';
import '../services/marketplace_api.dart';
import 'account_strings.dart';

const _strings = <String, Map<String, String>>{
  'en': {'signIn':'Sign in','register':'Create account','email':'Email','password':'Password (12+ characters)','name':'Name','location':'Operating area','role':'Role','market':'Marketplace','refresh':'Refresh','lots':'Lots','offers':'Offers','handovers':'Handovers','ledger':'Ledger','scan':'Scan and create lot','offer':'Make offer','rate':'Rate per kg','validity':'Valid for days','pickup':'Pickup available','accept':'Accept','reject':'Reject','cancel':'Cancel','submit':'Submit handover','measure':'Confirm measured weight','weight':'Weight (kg)','finalRate':'Final rate per kg','approve':'Accept final amount','dispute':'Raise dispute','reason':'Dispute reason','batch':'Consolidate selected lots','error':'Request failed. Check connection and try again.','empty':'No records yet','pending':'Pending','received':'Sales received','cost':'Purchase cost','margin':'Gross margin','receivables':'Pending receivables','payables':'Pending payables'},
  'hi': {'signIn':'साइन इन','register':'खाता बनाएँ','email':'ईमेल','password':'पासवर्ड (12+ अक्षर)','name':'नाम','location':'कार्य क्षेत्र','role':'भूमिका','market':'बाज़ार','refresh':'ताज़ा करें','lots':'लॉट','offers':'प्रस्ताव','handovers':'हस्तांतरण','ledger':'खाता','scan':'स्कैन करें और लॉट बनाएँ','offer':'प्रस्ताव दें','rate':'प्रति किलो दर','validity':'मान्य दिन','pickup':'पिकअप उपलब्ध','accept':'स्वीकारें','reject':'अस्वीकारें','cancel':'रद्द करें','submit':'हस्तांतरण जमा करें','measure':'मापा गया वज़न पुष्टि करें','weight':'वज़न (किलो)','finalRate':'अंतिम प्रति किलो दर','approve':'अंतिम राशि स्वीकारें','dispute':'विवाद दर्ज करें','reason':'विवाद का कारण','batch':'चयनित लॉट मिलाएँ','error':'अनुरोध विफल। कनेक्शन जाँचें और फिर प्रयास करें।','empty':'अभी कोई रिकॉर्ड नहीं','pending':'लंबित','received':'प्राप्त बिक्री','cost':'खरीद लागत','margin':'सकल मार्जिन','receivables':'लंबित प्राप्तियाँ','payables':'लंबित भुगतान'},
  'mr': {'signIn':'साइन इन','register':'खाते तयार करा','email':'ईमेल','password':'पासवर्ड (12+ अक्षरे)','name':'नाव','location':'कार्य क्षेत्र','role':'भूमिका','market':'बाजारपेठ','refresh':'ताजे करा','lots':'लॉट','offers':'ऑफर','handovers':'हस्तांतरण','ledger':'खाते','scan':'स्कॅन करून लॉट तयार करा','offer':'ऑफर द्या','rate':'प्रति किलो दर','validity':'वैध दिवस','pickup':'पिकअप उपलब्ध','accept':'स्वीकारा','reject':'नाकारा','cancel':'रद्द करा','submit':'हस्तांतरण सादर करा','measure':'मोजलेले वजन निश्चित करा','weight':'वजन (किलो)','finalRate':'अंतिम प्रति किलो दर','approve':'अंतिम रक्कम स्वीकारा','dispute':'वाद नोंदवा','reason':'वादाचे कारण','batch':'निवडलेले लॉट एकत्र करा','error':'विनंती अयशस्वी. कनेक्शन तपासा आणि पुन्हा प्रयत्न करा.','empty':'अद्याप नोंदी नाहीत','pending':'प्रलंबित','received':'मिळालेली विक्री','cost':'खरेदी खर्च','margin':'एकूण नफा','receivables':'येणे बाकी','payables':'देणे बाकी'},
  'kn': {'signIn':'ಸೈನ್ ಇನ್','register':'ಖಾತೆ ರಚಿಸಿ','email':'ಇಮೇಲ್','password':'ಪಾಸ್‌ವರ್ಡ್ (12+ ಅಕ್ಷರಗಳು)','name':'ಹೆಸರು','location':'ಕಾರ್ಯ ಪ್ರದೇಶ','role':'ಪಾತ್ರ','market':'ಮಾರುಕಟ್ಟೆ','refresh':'ನವೀಕರಿಸಿ','lots':'ಲಾಟ್‌ಗಳು','offers':'ಆಫರ್‌ಗಳು','handovers':'ಹಸ್ತಾಂತರಗಳು','ledger':'ಲೆಡ್ಜರ್','scan':'ಸ್ಕ್ಯಾನ್ ಮಾಡಿ ಲಾಟ್ ರಚಿಸಿ','offer':'ಆಫರ್ ನೀಡಿ','rate':'ಪ್ರತಿ ಕೆಜಿ ದರ','validity':'ಮಾನ್ಯ ದಿನಗಳು','pickup':'ಪಿಕಪ್ ಲಭ್ಯ','accept':'ಸ್ವೀಕರಿಸಿ','reject':'ತಿರಸ್ಕರಿಸಿ','cancel':'ರದ್ದುಮಾಡಿ','submit':'ಹಸ್ತಾಂತರ ಸಲ್ಲಿಸಿ','measure':'ಅಳತೆಯ ತೂಕ ದೃಢೀಕರಿಸಿ','weight':'ತೂಕ (ಕೆಜಿ)','finalRate':'ಅಂತಿಮ ಪ್ರತಿ ಕೆಜಿ ದರ','approve':'ಅಂತಿಮ ಮೊತ್ತ ಸ್ವೀಕರಿಸಿ','dispute':'ವಿವಾದ ದಾಖಲಿಸಿ','reason':'ವಿವಾದದ ಕಾರಣ','batch':'ಆಯ್ಕೆ ಮಾಡಿದ ಲಾಟ್‌ಗಳನ್ನು ಸೇರಿಸಿ','error':'ವಿನಂತಿ ವಿಫಲವಾಗಿದೆ. ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.','empty':'ಇನ್ನೂ ದಾಖಲೆಗಳಿಲ್ಲ','pending':'ಬಾಕಿ','received':'ಪಡೆದ ಮಾರಾಟ','cost':'ಖರೀದಿ ವೆಚ್ಚ','margin':'ಒಟ್ಟು ಮಾರ್ಜಿನ್','receivables':'ಪಡೆಯಬೇಕಾದ ಬಾಕಿ','payables':'ಪಾವತಿಸಬೇಕಾದ ಬಾಕಿ'},
  'te': {'signIn':'సైన్ ఇన్','register':'ఖాతా సృష్టించండి','email':'ఇమెయిల్','password':'పాస్‌వర్డ్ (12+ అక్షరాలు)','name':'పేరు','location':'పని ప్రాంతం','role':'పాత్ర','market':'మార్కెట్','refresh':'రిఫ్రెష్','lots':'లాట్లు','offers':'ఆఫర్లు','handovers':'అప్పగింతలు','ledger':'లెడ్జర్','scan':'స్కాన్ చేసి లాట్ సృష్టించండి','offer':'ఆఫర్ ఇవ్వండి','rate':'కిలోకు ధర','validity':'చెల్లుబాటు రోజులు','pickup':'పికప్ అందుబాటులో ఉంది','accept':'అంగీకరించు','reject':'తిరస్కరించు','cancel':'రద్దు','submit':'అప్పగింత సమర్పించు','measure':'కొలిచిన బరువును నిర్ధారించు','weight':'బరువు (కిలోలు)','finalRate':'చివరి కిలో ధర','approve':'చివరి మొత్తాన్ని అంగీకరించు','dispute':'వివాదం నమోదు చేయు','reason':'వివాద కారణం','batch':'ఎంచుకున్న లాట్లను కలుపు','error':'అభ్యర్థన విఫలమైంది. కనెక్షన్ తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.','empty':'ఇంకా రికార్డులు లేవు','pending':'పెండింగ్','received':'అందిన అమ్మకాలు','cost':'కొనుగోలు ఖర్చు','margin':'స్థూల మార్జిన్','receivables':'రావలసిన బాకీ','payables':'చెల్లించాల్సిన బాకీ'},
  'bn': {'signIn':'সাইন ইন','register':'অ্যাকাউন্ট তৈরি করুন','email':'ইমেল','password':'পাসওয়ার্ড (১২+ অক্ষর)','name':'নাম','location':'কাজের এলাকা','role':'ভূমিকা','market':'বাজার','refresh':'হালনাগাদ','lots':'লট','offers':'প্রস্তাব','handovers':'হস্তান্তর','ledger':'হিসাব','scan':'স্ক্যান করে লট তৈরি করুন','offer':'প্রস্তাব দিন','rate':'প্রতি কেজি দর','validity':'মেয়াদ দিন','pickup':'পিকআপ উপলব্ধ','accept':'গ্রহণ','reject':'প্রত্যাখ্যান','cancel':'বাতিল','submit':'হস্তান্তর জমা দিন','measure':'মাপা ওজন নিশ্চিত করুন','weight':'ওজন (কেজি)','finalRate':'চূড়ান্ত প্রতি কেজি দর','approve':'চূড়ান্ত অর্থ গ্রহণ','dispute':'বিরোধ জানান','reason':'বিরোধের কারণ','batch':'নির্বাচিত লট একত্র করুন','error':'অনুরোধ ব্যর্থ। সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।','empty':'এখনও রেকর্ড নেই','pending':'বাকি','received':'প্রাপ্ত বিক্রয়','cost':'ক্রয় খরচ','margin':'মোট মার্জিন','receivables':'পাওনা বাকি','payables':'দেনা বাকি'}
};

const _revenueLabels = {'en':'Sales revenue','hi':'बिक्री राजस्व','mr':'विक्री महसूल',
  'kn':'ಮಾರಾಟ ಆದಾಯ','te':'అమ్మకాల ఆదాయం','bn':'বিক্রয় আয়'};
const _recycleLabels = {'en':'Recycling','hi':'पुनर्चक्रण','mr':'पुनर्वापर',
  'kn':'ಮರುಬಳಕೆ','te':'రీసైక్లింగ్','bn':'পুনর্ব্যবহার'};
const _certificateLabels = {'en':'Certificate ID','hi':'प्रमाणपत्र आईडी','mr':'प्रमाणपत्र क्रमांक',
  'kn':'ಪ್ರಮಾಣಪತ್ರ ಸಂಖ್ಯೆ','te':'ధృవపత్ర సంఖ్య','bn':'সনদ নম্বর'};
const _acceptedMaterialsLabels = {'en':'Accepted materials (comma separated)','hi':'स्वीकृत सामग्री (अल्पविराम से अलग)',
  'mr':'स्वीकारलेले साहित्य (स्वल्पविरामाने वेगळे)','kn':'ಸ್ವೀಕರಿಸುವ ವಸ್ತುಗಳು (ಅಲ್ಪವಿರಾಮದಿಂದ ಬೇರ್ಪಡಿಸಿ)',
  'te':'అంగీకరించే పదార్థాలు (కామాతో వేరు చేయండి)','bn':'গৃহীত উপাদান (কমা দিয়ে আলাদা করুন)'};
const _offeredRatesLabels = {'en':'Rates (material:rate)','hi':'दर (सामग्री:दर)',
  'mr':'दर (साहित्य:दर)','kn':'ದರಗಳು (ವಸ್ತು:ದರ)','te':'ధరలు (పదార్థం:ధర)','bn':'দর (উপাদান:দর)'};
const _inventoryLabels = {'en':'Inventory cost','hi':'भंडार लागत','mr':'साठा खर्च',
  'kn':'ದಾಸ್ತಾನು ವೆಚ್ಚ','te':'నిల్వ ఖర్చు','bn':'মজুদ খরচ'};
const _responseLabels = {'en':'Buyer response','hi':'खरीदार का जवाब','mr':'खरेदीदाराचे उत्तर',
  'kn':'ಖರೀದಿದಾರರ ಪ್ರತಿಕ್ರಿಯೆ','te':'కొనుగోలుదారు స్పందన','bn':'ক্রেতার জবাব'};
const _imageLabels = {'en':'Lot image','hi':'लॉट की तस्वीर','mr':'लॉटचे छायाचित्र',
  'kn':'ಲಾಟ್ ಚಿತ್ರ','te':'లాట్ చిత్రం','bn':'লটের ছবি'};
const _pickupTermsLabels = {'en':'Pickup terms','hi':'पिकअप की शर्तें','mr':'पिकअप अटी',
  'kn':'ಪಿಕಪ್ ನಿಯಮಗಳು','te':'పికప్ నిబంధనలు','bn':'পিকআপের শর্ত'};
const _paymentTermsLabels = {'en':'Payment terms','hi':'भुगतान की शर्तें','mr':'पेमेंट अटी',
  'kn':'ಪಾವತಿ ನಿಯಮಗಳು','te':'చెల్లింపు నిబంధనలు','bn':'অর্থপ্রদানের শর্ত'};
const _notesLabels = {'en':'Notes','hi':'टिप्पणियाँ','mr':'नोंदी',
  'kn':'ಟಿಪ್ಪಣಿಗಳು','te':'గమనికలు','bn':'মন্তব্য'};
const _counterLabels = {'en':'Counteroffer','hi':'जवाबी प्रस्ताव','mr':'प्रतिऑफर',
  'kn':'ಪ್ರತಿಆಫರ್','te':'ప్రతిపాదన','bn':'পাল্টা প্রস্তাব'};
const _paymentLabels = {'en':'Payments','hi':'भुगतान','mr':'देयके',
  'kn':'ಪಾವತಿಗಳು','te':'చెల్లింపులు','bn':'পেমেন্ট'};
const _markPaidLabels = {'en':'Mark paid','hi':'भुगतान पूर्ण करें','mr':'पैसे दिले म्हणून नोंदवा',
  'kn':'ಪಾವತಿಸಲಾಗಿದೆ ಎಂದು ಗುರುತಿಸಿ','te':'చెల్లించినట్లు గుర్తించు','bn':'পরিশোধিত চিহ্নিত করুন'};
const _stateLabels = <String,List<String>>{
  'AVAILABLE':['Available','उपलब्ध','उपलब्ध','ಲಭ್ಯ','అందుబాటులో','উপলব্ধ'],
  'CONSOLIDATED':['Consolidated','एकत्रित','एकत्रित','ಒಗ್ಗೂಡಿಸಲಾಗಿದೆ','ఏకీకృతం','একত্রিত'],
  'IN_HANDOVER':['In handover','हस्तांतरण में','हस्तांतरणात','ಹಸ್ತಾಂತರದಲ್ಲಿ','అప్పగింతలో','হস্তান্তরে'],
  'PENDING':['Pending','लंबित','प्रलंबित','ಬಾಕಿ','పెండింగ్','অপেক্ষমাণ'],
  'ACCEPTED':['Accepted','स्वीकृत','स्वीकारले','ಸ್ವೀಕರಿಸಲಾಗಿದೆ','అంగీకరించబడింది','গৃহীত'],
  'REJECTED':['Rejected','अस्वीकृत','नाकारले','ತಿರಸ್ಕರಿಸಲಾಗಿದೆ','తిరస్కరించబడింది','প্রত্যাখ্যাত'],
  'EXPIRED':['Expired','समाप्त','मुदत संपली','ಅವಧಿ ಮುಗಿದಿದೆ','గడువు ముగిసింది','মেয়াদোত্তীর্ণ'],
  'CANCELLED':['Cancelled','रद्द','रद्द','ರದ್ದಾಗಿದೆ','రద్దయింది','বাতিল'],
  'COUNTERED':['Countered','जवाबी प्रस्ताव','प्रतिऑफर','ಪ್ರತಿಆಫರ್','ప్రతిపాదన','পাল্টা প্রস্তাব'],
  'PENDING_HANDOVER':['Handover pending','हस्तांतरण लंबित','हस्तांतरण प्रलंबित','ಹಸ್ತಾಂತರ ಬಾಕಿ','అప్పగింత పెండింగ్','হস্তান্তর বাকি'],
  'SUBMITTED_BY_SELLER':['Seller submitted','विक्रेता ने जमा किया','विक्रेत्याने सादर केले','ಮಾರಾಟಗಾರ ಸಲ್ಲಿಸಿದ್ದಾರೆ','విక్రేత సమర్పించారు','বিক্রেতা জমা দিয়েছেন'],
  'AWAITING_SELLER_APPROVAL':['Seller approval pending','विक्रेता की मंज़ूरी बाकी','विक्रेत्याची मंजुरी बाकी','ಮಾರಾಟಗಾರರ ಅನುಮೋದನೆ ಬಾಕಿ','విక్రేత ఆమోదం పెండింగ్','বিক্রেতার অনুমোদন বাকি'],
  'COMPLETED':['Completed','पूर्ण','पूर्ण','ಪೂರ್ಣಗೊಂಡಿದೆ','పూర్తయింది','সম্পন্ন'],
  'DISPUTED':['Disputed','विवादित','वादग्रस्त','ವಿವಾದಿತ','వివాదంలో','বিতর্কিত'],
  'RESOLVED':['Resolved','समाधान हुआ','निराकरण झाले','ಪರಿಹರಿಸಲಾಗಿದೆ','పరిష్కరించబడింది','নিষ্পত্তি হয়েছে'],
  'RECEIVED':['Received','प्राप्त','प्राप्त','ಸ್ವೀಕರಿಸಲಾಗಿದೆ','స్వీకరించబడింది','প্রাপ্ত'],
  'SORTED':['Sorted','छाँटा गया','वर्गीकृत','ವಿಂಗಡಿಸಲಾಗಿದೆ','వేరు చేయబడింది','বাছাই হয়েছে'],
  'PROCESSING':['Processing','प्रक्रिया में','प्रक्रियेत','ಸಂಸ್ಕರಣೆಯಲ್ಲಿ','ప్రక్రియలో','প্রক্রিয়াধীন'],
  'RECYCLED':['Recycled','पुनर्चक्रित','पुनर्वापर झाले','ಮರುಬಳಕೆಯಾಗಿದೆ','రీసైకిల్ అయింది','পুনর্ব্যবহৃত'],
  'COLLECTOR':['Collector','संग्रहकर्ता','संकलक','ಸಂಗ್ರಾಹಕ','సేకరణకర్త','সংগ্রাহক'],
  'AGGREGATOR':['Aggregator','संग्रह केंद्र','संकलनकर्ता','ಒಗ್ಗೂಡಿಸುವವರು','సమీకర్త','সমষ্টিকারী'],
  'MIDDLEMAN':['Middleman','मध्यस्थ','मध्यस्थ','ಮಧ್ಯವರ್ತಿ','మధ్యవర్తి','মধ্যস্থতাকারী'],
  'RECYCLER':['Recycler','रीसायक्लर','पुनर्वापरकर्ता','ಮರುಬಳಕೆದಾರ','రీసైక్లర్','পুনর্ব্যবহারকারী'],
  'VERIFIED':['Verified','सत्यापित','पडताळलेले','ಪರಿಶೀಲಿಸಲಾಗಿದೆ','ధృవీకరించబడింది','যাচাইকৃত'],
  'UNVERIFIED':['Unverified','असत्यापित','अपडताळलेले','ಪರಿಶೀಲಿಸಿಲ್ಲ','ధృవీకరించబడలేదు','যাচাই হয়নি'],
  'PAID':['Paid','भुगतान हुआ','पैसे दिले','ಪಾವತಿಸಲಾಗಿದೆ','చెల్లించబడింది','পরিশোধিত'],
  'FAILED':['Failed','विफल','अयशस्वी','ವಿಫಲ','విఫలమైంది','ব্যর্থ'],
};
String liveState(String language,Object? code){const languages=['en','hi','mr','kn','te','bn'];
  final index=languages.indexOf(language);return _stateLabels[code]?.elementAt(index<0?0:index)??code.toString();}
String liveText(String language, String key) => key == 'revenue'
    ? (_revenueLabels[language] ?? _revenueLabels['en']!)
    : key == 'recycling' ? (_recycleLabels[language] ?? _recycleLabels['en']!)
    : key == 'certificate' ? (_certificateLabels[language] ?? _certificateLabels['en']!)
    : key == 'acceptedMaterials' ? (_acceptedMaterialsLabels[language] ?? _acceptedMaterialsLabels['en']!)
    : key == 'offeredRates' ? (_offeredRatesLabels[language] ?? _offeredRatesLabels['en']!)
    : key == 'inventory' ? (_inventoryLabels[language] ?? _inventoryLabels['en']!)
    : key == 'response' ? (_responseLabels[language] ?? _responseLabels['en']!)
    : key == 'image' ? (_imageLabels[language] ?? _imageLabels['en']!)
    : key == 'pickupTerms' ? (_pickupTermsLabels[language] ?? _pickupTermsLabels['en']!)
    : key == 'paymentTerms' ? (_paymentTermsLabels[language] ?? _paymentTermsLabels['en']!)
    : key == 'notes' ? (_notesLabels[language] ?? _notesLabels['en']!)
    : key == 'counter' ? (_counterLabels[language] ?? _counterLabels['en']!)
    : key == 'payment' ? (_paymentLabels[language] ?? _paymentLabels['en']!)
    : key == 'markPaid' ? (_markPaidLabels[language] ?? _markPaidLabels['en']!)
    : (_strings[language]?[key] ?? _strings['en']![key]!);

class LiveAccountScreen extends StatefulWidget {
  const LiveAccountScreen({required this.controller, super.key});
  final MinistryController controller;
  @override State<LiveAccountScreen> createState() => _LiveAccountScreenState();
}
class _LiveAccountScreenState extends State<LiveAccountScreen> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController(), password = TextEditingController(),
      name = TextEditingController(), location = TextEditingController();
  UserRole? role;
  bool registering = false, busy = false, showPassword = false;
  String? errorKey;
  String a(String key) => accountText(widget.controller.language, key);

  @override
  void dispose() {
    email.dispose(); password.dispose(); name.dispose(); location.dispose();
    super.dispose();
  }

  String? requiredValue(String? value) =>
      value == null || value.trim().isEmpty ? a('required') : null;

  Future<void> submit() async {
    if (busy || !formKey.currentState!.validate()) return;
    setState(() { busy = true; errorKey = null; });
    try {
      if (registering) {
        await widget.controller.register(email.text, password.text, name.text,
            role!, widget.controller.language, location.text.trim());
      } else {
        await widget.controller.signIn(email.text.trim().toLowerCase(), password.text);
      }
    } on MarketplaceException catch (error) {
      if (!mounted) return;
      setState(() {
        errorKey = switch (error.statusCode) {
          0 when error.message == 'Request timed out' => 'timeout',
          0 => 'network',
          409 => 'duplicate',
          400 || 422 => error.message.contains('Password') ? 'shortPassword' : 'invalid',
          401 || 403 => 'unauthorized',
          503 => 'unavailable',
          _ => 'server',
        };
      });
    } catch (_) {
      if (mounted) setState(() => errorKey = 'server');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  InputDecoration decoration(String label, IconData icon, {String? helper}) =>
      InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 20),
          helperText: helper, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14));

  @override
  Widget build(BuildContext context) {
    const languageLabels = {'en':'English','hi':'हिन्दी','mr':'मराठी',
      'kn':'ಕನ್ನಡ','te':'తెలుగు','bn':'বাংলা'};
    final color = Theme.of(context).colorScheme;
    return SafeArea(child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(22, 24, 22, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440),
        child: Form(key: formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(child: Image.asset('assets/branding/kabadiwala_connect_logo.png',
              width: 112, height: 88, fit: BoxFit.contain)),
          const SizedBox(height: 14),
          Text(registering ? a('title') : liveText(widget.controller.language, 'signIn'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          if (registering) ...[const SizedBox(height: 6), Text(a('subtitle'),
              style: TextStyle(color: color.onSurfaceVariant))],
          const SizedBox(height: 24),
          if (registering) ...[
            TextFormField(controller: name, textCapitalization: TextCapitalization.words,
                decoration: decoration(a('name'), Icons.person_outline), validator: requiredValue),
            const SizedBox(height: 15),
          ],
          TextFormField(controller: email, keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: decoration(a('email'), Icons.mail_outline),
              validator: (value) => requiredValue(value) ??
                  (RegExp(r'^\S+@\S+\.\S+$').hasMatch(value!.trim()) ? null : a('invalidEmail'))),
          const SizedBox(height: 15),
          TextFormField(controller: password, obscureText: !showPassword,
              autofillHints: [registering ? AutofillHints.newPassword : AutofillHints.password],
              decoration: decoration(a('password'), Icons.lock_outline,
                  helper: registering ? a('passwordHelp') : null).copyWith(
                suffixIcon: IconButton(
                    tooltip: a(showPassword ? 'hidePassword' : 'showPassword'),
                    onPressed: () => setState(() => showPassword = !showPassword),
                    icon: Icon(showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined))),
              validator: (value) => requiredValue(value) ??
                  (registering && value!.length < 12 ? a('shortPassword') : null)),
          if (registering) ...[
            const SizedBox(height: 15),
            TextFormField(controller: location, decoration: decoration(a('area'), Icons.place_outlined),
                validator: requiredValue),
            const SizedBox(height: 15),
            DropdownButtonFormField<UserRole>(initialValue: role,
                isExpanded: true, decoration: decoration(a('role'), Icons.work_outline),
                items: UserRole.values.where((value) => value != UserRole.admin)
                    .map((value) => DropdownMenuItem(value: value,
                        child: Text(a(value.name)))).toList(),
                onChanged: (value) => setState(() => role = value),
                validator: (value) => value == null ? a('required') : null),
            const SizedBox(height: 22),
            Text(a('language'), style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 6, children: [
              for (final code in languageLabels.keys)
                ChoiceChip(label: Text(languageLabels[code]!),
                    selected: widget.controller.language == code,
                    onSelected: busy ? null : (_) => widget.controller.setLanguage(code)),
            ]),
          ],
          if (errorKey != null) ...[
            const SizedBox(height: 18),
            Container(padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.errorContainer,
                    borderRadius: BorderRadius.circular(12)),
                child: Text(a(errorKey!), style: TextStyle(color: color.onErrorContainer))),
          ],
          const SizedBox(height: 24),
          SizedBox(height: 54, child: FilledButton(onPressed: busy ? null : submit,
              child: busy ? Row(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(width: 18, height: 18, child: CircularProgressIndicator(
                    strokeWidth: 2, color: color.onPrimary)),
                const SizedBox(width: 10), Text(registering ? a('creating') : liveText(widget.controller.language, 'signIn')),
              ]) : Text(registering ? a('create') : liveText(widget.controller.language, 'signIn')))),
          const SizedBox(height: 10),
          TextButton(onPressed: busy ? null : () => setState(() {
            registering = !registering; errorKey = null; formKey.currentState?.reset();
          }), child: Text(registering ? a('haveAccount') : a('newAccount'))),
          if (!registering) Wrap(alignment: WrapAlignment.center, spacing: 8,
            children: [for (final code in languageLabels.keys)
              ChoiceChip(label: Text(languageLabels[code]!),
                  selected: widget.controller.language == code,
                  onSelected: (_) => widget.controller.setLanguage(code))]),
        ]))))));
  }
}

class LiveMarketplaceScreen extends StatefulWidget {
  const LiveMarketplaceScreen({required this.controller,super.key});
  final MinistryController controller;
  @override State<LiveMarketplaceScreen> createState()=>_LiveMarketplaceScreenState();
}
class _LiveMarketplaceScreenState extends State<LiveMarketplaceScreen> {
  List<Map<String,dynamic>> lots=[],offers=[],handovers=[],batches=[],recycling=[],prices=[],disputes=[],payments=[];
  Map<String,dynamic> ledger={}; bool loading=true;
  Map<String,dynamic> account={};
  final selected=<String>{};
  String t(String key)=>liveText(widget.controller.language,key);
  String materialName(Object? id) => materialCatalog[id?.toString()]?.name(widget.controller.language) ?? id.toString();
  @override void initState(){super.initState();refresh();}
  Future<void> refresh() async {setState(()=>loading=true);try{
    final api=widget.controller.api;
    final responses=await Future.wait([api.list('lots'),api.list('offers'),api.list('handovers'),api.list('batches'),api.list('price-board'),api.list('disputes'),api.list('payments'),
      if(widget.controller.userRole==UserRole.recycler)api.list('recycling')]);
    final totals=await api.ledger();
    final me=(await api.request('me'))['data'] as Map<String,dynamic>;
    if(mounted)widget.controller.setLivePrices(responses[4]);
    if(mounted)setState((){lots=responses[0];offers=responses[1];handovers=responses[2];batches=responses[3];prices=responses[4];disputes=responses[5];payments=responses[6];recycling=responses.length>7?responses[7]:[];ledger=totals;account=me;});
  }catch(_){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(t('error'))));}
  if(mounted)setState(()=>loading=false);}
  Future<void> run(String resource,String method,Map<String,dynamic> body) async {try{
    await widget.controller.api.request(resource,method:method,body:body);await refresh();
  }catch(_){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(t('error'))));}}
  Future<void> showImage(String lotId) async {try{
    final data=(await widget.controller.api.request('image',query:{'lotId':lotId}))['data'] as Map<String,dynamic>;
    if(!mounted)return;
    await showDialog<void>(context:context,builder:(context)=>AlertDialog(title:Text(t('image')),
      content:Image.memory(base64Decode(data['base64'] as String)),
      actions:[TextButton(onPressed:()=>Navigator.pop(context),child:Text(t('cancel')))]));
  }catch(_){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(t('error'))));}}
  Future<void> editProfile() async {try{
    final me=(await widget.controller.api.request('me'))['data'] as Map<String,dynamic>;
    if(!mounted)return;
    final facility=TextEditingController(text:me['facilityName']?.toString()??'');
    final authorization=TextEditingController(text:me['authorizationNumber']?.toString()??'');
    final materials=TextEditingController(text:(me['materialsAccepted'] as List? ?? []).join(', '));
    final rates=TextEditingController(text:(me['offeredRates'] as Map? ?? {}).entries.map((entry)=>'${entry.key}:${entry.value}').join(', '));
    final area=TextEditingController(text:me['serviceArea']?.toString()??'');
    var pickup=me['pickupAvailable']==true;
    final accepted=await showDialog<bool>(context:context,builder:(context)=>StatefulBuilder(builder:(context,setDialogState)=>AlertDialog(
      title:Text(widget.controller.t('profile')),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
        TextField(controller:facility,decoration:InputDecoration(labelText:widget.controller.t('facilityName'))),
        TextField(controller:authorization,decoration:InputDecoration(labelText:widget.controller.t('authNumber'))),
        TextField(controller:materials,decoration:InputDecoration(labelText:t('acceptedMaterials'))),
        TextField(controller:rates,decoration:InputDecoration(labelText:t('offeredRates'))),
        TextField(controller:area,decoration:InputDecoration(labelText:t('location'))),
        CheckboxListTile(title:Text(t('pickup')),value:pickup,onChanged:(value)=>setDialogState(()=>pickup=value??false)),
      ])),actions:[TextButton(onPressed:()=>Navigator.pop(context,false),child:Text(t('cancel'))),
        FilledButton(onPressed:()=>Navigator.pop(context,true),child:Text(t('accept')))])));
    if(accepted==true){final offered=<String,double>{};for(final pair in rates.text.split(',')){
      final parts=pair.split(':');if(parts.length==2){final value=double.tryParse(parts[1].trim());if(value!=null&&value>0)offered[parts[0].trim()]=value;}}
      await run('me','PATCH',{'facilityName':facility.text,'authorizationNumber':authorization.text,
        'materialsAccepted':materials.text.split(',').map((item)=>item.trim()).where((item)=>item.isNotEmpty).toList(),
        'offeredRates':offered,'serviceArea':area.text,'pickupAvailable':pickup});}
    facility.dispose();authorization.dispose();materials.dispose();rates.dispose();area.dispose();
  }catch(_){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(t('error'))));}}
  Future<Map<String,String>?> fields(String title,List<String> keys) async {
    final controls={for(final key in keys)key:TextEditingController()};
    final result=await showDialog<Map<String,String>>(context:context,builder:(context)=>AlertDialog(title:Text(title),content:Column(mainAxisSize:MainAxisSize.min,children:[for(final key in keys)TextField(controller:controls[key],keyboardType:['reason','response'].contains(key)?TextInputType.text:TextInputType.number,decoration:InputDecoration(labelText:t(key)))]),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:Text(t('cancel'))),FilledButton(onPressed:()=>Navigator.pop(context,{for(final entry in controls.entries)entry.key:entry.value.text}),child:Text(t('submit')))]));
    for(final control in controls.values){control.dispose();}return result;
  }
  Future<void> offer(Map<String,dynamic> item,bool batch) async {
    final rateField=TextEditingController(),daysField=TextEditingController(text:'7');
    final pickupField=TextEditingController(),paymentField=TextEditingController(),notesField=TextEditingController();
    var pickup=false;
    final confirmed=await showDialog<bool>(context:context,builder:(context)=>StatefulBuilder(builder:(context,setDialogState)=>AlertDialog(
      title:Text(t('offer')),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
        TextField(controller:rateField,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:t('rate'))),
        TextField(controller:daysField,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:t('validity'))),
        CheckboxListTile(title:Text(t('pickup')),value:pickup,onChanged:(value)=>setDialogState(()=>pickup=value??false)),
        TextField(controller:pickupField,decoration:InputDecoration(labelText:t('pickupTerms'))),
        TextField(controller:paymentField,decoration:InputDecoration(labelText:t('paymentTerms'))),
        TextField(controller:notesField,decoration:InputDecoration(labelText:t('notes'))),
      ])),actions:[TextButton(onPressed:()=>Navigator.pop(context,false),child:Text(t('cancel'))),
        FilledButton(onPressed:()=>Navigator.pop(context,true),child:Text(t('submit')))])));
    final rate=double.tryParse(rateField.text),days=int.tryParse(daysField.text);
    final pickupTerms=pickupField.text,paymentTerms=paymentField.text,notes=notesField.text;
    rateField.dispose();daysField.dispose();pickupField.dispose();paymentField.dispose();notesField.dispose();
    if(confirmed!=true||rate==null||rate<=0||days==null||days<1)return;
    await run('offers','POST',{batch?'batchId':'lotId':item['id'],'rate':rate,
      'validUntil':DateTime.now().add(Duration(days:days)).toUtc().toIso8601String(),
      'pickupAvailable':pickup,'pickupTerms':pickupTerms,'paymentTerms':paymentTerms,'notes':notes});
  }
  Widget itemCard(Map<String,dynamic> item,{bool batch=false}){final mine=item['owner_id']==widget.controller.profile?.collectorId;
    final sellerRole=item['owner_role']?.toString();
    final buyerRole=widget.controller.userRole.name.toUpperCase();
    final eligible={'COLLECTOR':['AGGREGATOR','MIDDLEMAN','RECYCLER'],
      'AGGREGATOR':['MIDDLEMAN','RECYCLER'],'MIDDLEMAN':['AGGREGATOR','RECYCLER']}[sellerRole]?.contains(buyerRole)??false;
    return Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('${materialName(item['material'])} · ${item['weight_kg']} kg',style:const TextStyle(fontWeight:FontWeight.bold)),Text(item['id'].toString()),
      Text(liveState(widget.controller.language,item['status'])),
      if(!batch && item['image_ref']!=null)IconButton(onPressed:()=>showImage(item['id'].toString()),
        icon:const Icon(Icons.photo_outlined),tooltip:t('image')),
      IconButton(onPressed:()=>showDialog<void>(context:context,builder:(context)=>AlertDialog(
        content:QrImageView(data:'${batch?'batch':'lot'}:${item['id']}',size:220),
        actions:[TextButton(onPressed:()=>Navigator.pop(context),child:Text(t('cancel')))])),
        icon:const Icon(Icons.qr_code),tooltip:widget.controller.t('scanLotQr')),
      if(!mine && eligible && item['status']=='AVAILABLE' &&
          (widget.controller.userRole!=UserRole.recycler || account['authorizationStatus']=='VERIFIED'))
        TextButton(onPressed:()=>offer(item,batch),child:Text(t('offer'))),
      if(mine && !batch && ['aggregator','middleman'].contains(widget.controller.userRole.name) && item['status']=='AVAILABLE')
        CheckboxListTile(value:selected.contains(item['id']),title:Text(t('batch')),onChanged:(v)=>setState((){v==true?selected.add(item['id']):selected.remove(item['id']);})),
      if(mine && widget.controller.userRole==UserRole.recycler)...[
        if(!recycling.any((r)=>(batch?r['batch_id']:r['lot_id'])==item['id']))
          TextButton(onPressed:()=>run('recycling','PATCH',{batch?'batchId':'lotId':item['id'],'status':'RECEIVED'}),child:Text(t('recycling'))),
        for(final record in recycling.where((r)=>(batch?r['batch_id']:r['lot_id'])==item['id']))...[
          Text(liveState(widget.controller.language,record['status'])),
          if(record['status']!='RECYCLED')TextButton(onPressed:()=>run('recycling','PATCH',{batch?'batchId':'lotId':item['id'],
            'status':{'RECEIVED':'SORTED','SORTED':'PROCESSING','PROCESSING':'RECYCLED'}[record['status']]}),child:Text(t('recycling'))),
          if(record['certificate_id']!=null)Text('${t('certificate')}: ${record['certificate_id']}'),
        ],
      ],
    ])));
  }
  Widget offerCard(Map<String,dynamic> offer){final seller=offer['seller_id']==widget.controller.profile?.collectorId;
    return Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('${offer['rate']} / kg · ${offer['quoted_amount']}',style:const TextStyle(fontWeight:FontWeight.bold)),
      Text('${liveState(widget.controller.language,offer['status'])} · ${offer['id']}\n'
        '${t('validity')}: ${offer['valid_until']}\n${t('pickupTerms')}: ${offer['pickup_terms']}\n'
        '${t('paymentTerms')}: ${offer['payment_terms']}\n${t('notes')}: ${offer['notes']}'),
      if(offer['status']=='PENDING')Wrap(children:[
        if(seller)TextButton(onPressed:()=>run('offers','PATCH',{'id':offer['id'],'status':'ACCEPTED'}),child:Text(t('accept'))),
        if(seller)TextButton(onPressed:()async{final v=await fields(t('counter'),['rate']);
          if(v!=null){await run('offers','PATCH',{'id':offer['id'],'status':'COUNTERED','counterRate':double.tryParse(v['rate']??'')});}},child:Text(t('counter'))),
        TextButton(onPressed:()=>run('offers','PATCH',{'id':offer['id'],'status':seller?'REJECTED':'CANCELLED'}),child:Text(t(seller?'reject':'cancel'))),
      ]),
      if(offer['status']=='COUNTERED'&&!seller)TextButton(onPressed:()=>run('offers','PATCH',{'id':offer['id'],'status':'PENDING'}),child:Text(t('accept'))),
    ])));
  }
  Widget handoverCard(Map<String,dynamic> handover){final seller=handover['seller_id']==widget.controller.profile?.collectorId;
    final status=handover['status'];return Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('${handover['id']}',style:const TextStyle(fontWeight:FontWeight.bold)),Text('${liveState(widget.controller.language,status)} · ${handover['final_amount']??handover['quoted_amount']}'),
      if(seller && status=='PENDING_HANDOVER')TextButton(onPressed:()async{final v=await fields(t('submit'),['weight']);if(v!=null){await run('handovers','PATCH',
        {'id':handover['id'],'action':'submit','weightKg':double.tryParse(v['weight']??''),
          'location':widget.controller.profile?.operatingLocation??''});}},child:Text(t('submit'))),
      if(!seller && status=='SUBMITTED_BY_SELLER')TextButton(onPressed:()async{final v=await fields(t('measure'),['weight','finalRate']);if(v!=null)await run('handovers','PATCH',{'id':handover['id'],'action':'measure','weightKg':double.tryParse(v['weight']??''),'finalRate':double.tryParse(v['finalRate']??'')});},child:Text(t('measure'))),
      if(seller && ['AWAITING_SELLER_APPROVAL','RESOLVED'].contains(status))...[TextButton(onPressed:()=>run('handovers','PATCH',{'id':handover['id'],'action':'accept'}),child:Text(t('approve'))),
        TextButton(onPressed:()async{final v=await fields(t('dispute'),['reason']);if(v!=null)await run('handovers','PATCH',{'id':handover['id'],'action':'dispute','reason':v['reason']});},child:Text(t('dispute')))],
    ])));
  }
  @override Widget build(BuildContext context){final role=widget.controller.userRole;
    return ListView(padding:const EdgeInsets.all(16),children:[
      Row(children:[Expanded(child:Text(t('market'),style:Theme.of(context).textTheme.headlineMedium)),
        if(role==UserRole.recycler)IconButton(onPressed:editProfile,icon:const Icon(Icons.person_outline),tooltip:widget.controller.t('profile')),
        IconButton(onPressed:refresh,icon:const Icon(Icons.refresh),tooltip:t('refresh'))]),
      if(role==UserRole.recycler && account['authorizationStatus']!=null)
        Chip(label:Text(liveState(widget.controller.language,account['authorizationStatus']))),
      if(loading)const LinearProgressIndicator(),
      if(role==UserRole.collector)FilledButton(onPressed:()=>widget.controller.go(WorkflowScreen.collectionMode),child:Text(t('scan'))),
      if(role!=UserRole.collector)OutlinedButton.icon(onPressed:()=>widget.controller.go(WorkflowScreen.scanQR),
        icon:const Icon(Icons.qr_code_scanner),label:Text(widget.controller.t('scanLotQr'))),
      if(widget.controller.scannedAsset!=null)Card(child:ListTile(title:Text(materialName(widget.controller.scannedAsset!['material'])),
        subtitle:Text('${widget.controller.scannedAsset!['id']} · ${widget.controller.scannedAsset!['weight_kg']} kg'))),
      Wrap(spacing:8,children:[for(final key in role==UserRole.collector
        ? ['received','receivables'] : role==UserRole.recycler
        ? ['cost','payables'] : ['revenue','received','cost','receivables','payables','inventory','margin'])
        Chip(label:Text('${t(key)}: ${ledger[{'revenue':'sales_revenue','received':'sales_received','cost':'purchase_cost','receivables':'pending_receivables','payables':'pending_payables','inventory':'inventoryCost','margin':'grossMargin'}[key]]??0}'))]),
      Text(widget.controller.t('priceBoard'),style:Theme.of(context).textTheme.titleLarge),
      if(prices.isEmpty)Text(t('empty')),
      ...prices.map((record)=>Card(child:ListTile(title:Text(materialName(record['material_id'])),
        subtitle:Text(record['location'].toString()),trailing:Text('${record['rate']} / ${record['unit']}')))),
      Text(t('lots'),style:Theme.of(context).textTheme.titleLarge),if(lots.isEmpty)Text(t('empty')),...lots.map((e)=>itemCard(e)),
      if(selected.length>=2)FilledButton(onPressed:()async{await run('batches','POST',{'sourceLotIds':selected.toList()});selected.clear();},child:Text(t('batch'))),
      Text(t('offers'),style:Theme.of(context).textTheme.titleLarge),if(offers.isEmpty)Text(t('empty')),...offers.map(offerCard),
      Text(t('handovers'),style:Theme.of(context).textTheme.titleLarge),if(handovers.isEmpty)Text(t('empty')),...handovers.map(handoverCard),
      Text(t('payment'),style:Theme.of(context).textTheme.titleLarge),if(payments.isEmpty)Text(t('empty')),
      ...payments.map((payment)=>Card(child:ListTile(title:Text('${payment['amount']}'),
        subtitle:Text(liveState(widget.controller.language,payment['status'])),
        trailing:payment['payee_id']==widget.controller.profile?.collectorId
          ?TextButton(onPressed:()async{final v=await fields(t('dispute'),['reason']);if(v!=null){await run('disputes','POST',
            {'handoverId':payment['handover_id'],'reason':v['reason']});}},child:Text(t('dispute')))
          :payment['payer_id']==widget.controller.profile?.collectorId && payment['status']!='PAID'
          ?PopupMenuButton<String>(tooltip:t('payment'),onSelected:(status)=>run('payments','PATCH',
            {'id':payment['id'],'status':status}),itemBuilder:(_)=>['PROCESSING','PAID','FAILED']
              .map((status)=>PopupMenuItem(value:status,child:Text(liveState(widget.controller.language,status)))).toList()):null))),
      Text(t('dispute'),style:Theme.of(context).textTheme.titleLarge),if(disputes.isEmpty)Text(t('empty')),
      ...disputes.map((dispute)=>Card(child:ListTile(title:Text(dispute['reason'].toString()),
        subtitle:Text(liveState(widget.controller.language,dispute['status'])),
        trailing:dispute['status']=='OPEN' && dispute['raised_by']!=widget.controller.profile?.collectorId
          ?TextButton(onPressed:()async{final v=await fields(t('response'),['response']);if(v!=null){await run('disputes','PATCH',
            {'id':dispute['id'],'action':'respond','buyerResponse':v['response']});}},child:Text(t('response'))):null))),
      Text(t('batch'),style:Theme.of(context).textTheme.titleLarge),...batches.map((e)=>itemCard(e,batch:true)),
    ]);
  }
}
