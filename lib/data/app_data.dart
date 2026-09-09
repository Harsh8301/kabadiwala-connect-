import '../models/material_item.dart';

const brandGreen = 0xFF1B5E20;
const brandGreenDark = 0xFF0A3D11;
const brandGreenLight = 0xFFE8F5E9;
const traceBlue = 0xFF0284C7;
const amber = 0xFFD97706;
const hazardRed = 0xFFDC2626;

const materials = <String, MaterialItem>{
  'cables': MaterialItem(
    id: 'cables',
    icon: '🔌',
    formalRate: 650,
    informalRate: 480,
    names: {
      'mr': 'तांब्याची केबल (Cables)',
      'hi': 'तांबे की केबल (Cables)',
      'en': 'Copper Cables',
    },
    valueTip: ValueTip(
      title: {
        'mr': 'केबलचे प्लास्टिक आवरण कधीही जाळू नका!',
        'hi': 'केबल का प्लास्टिक कवर कभी न जलाएं!',
        'en': 'Never burn cable plastic insulation!',
      },
      description: {
        'mr':
            'इन्सुलेशन जाळल्याने तांब्याचे वजन घटते, काजळी चढल्याने भाव कमी मिळतो आणि विषारी वायूमुळे फुफ्फुसांचे नुकसान होते. अखंड केबल अधिकृत केंद्राला दिल्यास जास्त नफा होतो.',
        'hi':
            'इंसुलेशन जलाने से तांबे का वजन कम होता है, कालिख जमने से कम दाम मिलता है और जहरीला धुआं स्वास्थ्य को नुकसान पहुंचाता है।',
        'en':
            'Burning reduces copper weight, degrades purity, causes soot, and harms lungs. Formal recyclers pay premium rates for unburnt cables.',
      },
    ),
  ),
  'pcb': MaterialItem(
    id: 'pcb',
    icon: '🖧',
    formalRate: 220,
    informalRate: 150,
    names: {
      'mr': 'सर्किट बोर्ड (PCB)',
      'hi': 'सर्किट बोर्ड (PCB)',
      'en': 'Printed Circuit Board (PCB)',
    },
    valueTip: ValueTip(
      title: {
        'mr': 'सर्किट बोर्ड कधीही हातोड्याने फोडू नका!',
        'hi': 'सर्किट बोर्ड को हथौड़े से न तोड़ें!',
        'en': 'Keep Circuit Boards (PCB) intact!',
      },
      description: {
        'mr':
            'पीसीबी अखंड ठेवल्यास त्यावरील आयसी, मौल्यवान सूक्ष्म घटक आणि तांबे सुरक्षित राहतात. अधिकृत केंद्रात सुरक्षित प्रक्रियेद्वारे धातूंचे शुद्धीकरण होते.',
        'hi':
            'पीसीबी को सुरक्षित रखने से कीमती धातुएं व आईसी सही रहते हैं। अधिकृत रीसाइक्लिंग में इसका पूरा मूल्य मिलता है।',
        'en':
            'Do not smash boards with hammers. Authorized processing recovers gold, silver, and copper safely without acid hazards.',
      },
    ),
  ),
  'battery': MaterialItem(
    id: 'battery',
    icon: '🔋',
    formalRate: 110,
    informalRate: 75,
    hazardType: 'battery',
    names: {
      'mr': 'बॅटरी / सेल (Battery)',
      'hi': 'बैटरी / सेल (Battery)',
      'en': 'Battery Cells',
    },
    valueTip: ValueTip(
      title: {
        'mr': 'बॅटरी अखंड अवस्थेतच हस्तांतरित करा!',
        'hi': 'बैटरी को साबुत ही सौंपें!',
        'en': 'Hand over batteries intact and safe!',
      },
      description: {
        'mr':
            'बॅटरी उघडण्याचा प्रयत्न करू नका. आतील रसायने अत्यंत ज्वलनशील असतात. सुरक्षित अखंड बॅटरीला अधिकृत रिसायकलरकडून खात्रीशीर दर मिळतो.',
        'hi':
            'बैटरी कभी न खोलें। अंदर के रसायन ज्वलनशील और जहरीले होते हैं। साबुत बैटरी का अधिकृत रीसाइक्लिंग में सही दाम मिलता है।',
        'en':
            'Do not puncture or strip battery casings. Intact handover protects workers and recovers cobalt and lithium safely.',
      },
    ),
  ),
  'motor': MaterialItem(
    id: 'motor',
    icon: '⚙️',
    formalRate: 180,
    informalRate: 125,
    names: {
      'mr': 'इलेक्ट्रिक मोटर (Motor)',
      'hi': 'इलेक्ट्रिक मोटर (Motor)',
      'en': 'Electric Motor',
    },
    valueTip: ValueTip(
      title: {
        'mr': 'मोटारची तांब्याची कॉइल जळू देऊ नका!',
        'hi': 'मोटर की तांबे की वाइंडिंग न जलाएं!',
        'en': 'Preserve copper motor windings unburnt!',
      },
      description: {
        'mr':
            'मोटार फोडताना कॉइलचे नुकसान टाळा. इन्सुलेशन न जाळता यांत्रिक पद्धतीने काढलेले तांबे सर्वोच्च दराने विकले जाते.',
        'hi':
            'मोटर खोलते समय कॉपर वाइंडिंग न जलाएं। साफ तांबे का अधिकृत केंद्र में सबसे अधिक भाव मिलता है।',
        'en':
            'Do not burn varnish off motor windings. Mechanically separated clean windings fetch maximum scrap value.',
      },
    ),
  ),
  'crt': MaterialItem(
    id: 'crt',
    icon: '📺',
    formalRate: 35,
    informalRate: 20,
    hazardType: 'crt',
    names: {
      'mr': 'सीआरटी डिस्प्ले (CRT)',
      'hi': 'सीआरटी डिस्प्ले (CRT)',
      'en': 'CRT Display',
    },
    valueTip: ValueTip(
      title: {
        'mr': 'सीआरटी मॉनिटरची काच चुकूनही फोडू नका!',
        'hi': 'सीआरटी मॉनिटर का कांच कभी न तोड़ें!',
        'en': 'Never smash CRT monitor glass!',
      },
      description: {
        'mr':
            'सीआरटीच्या काचेमध्ये शिसे आणि विषारी फॉस्फर असते. काच फुटल्यास विष पसरते. अधिकृत केंद्रच याचे सुरक्षित पृथक्करण करू शकते.',
        'hi':
            'कांच में जहरीला लेड और फॉस्फोर होता है। टूटने पर यह फेफड़ों को नुकसान पहुंचाता है। इसे केवल अधिकृत रिसाइक्लर को दें।',
        'en':
            'CRT funnel glass contains toxic lead oxide and phosphors. Only specialized recyclers can process it safely.',
      },
    ),
  ),
  'mixed': MaterialItem(
    id: 'mixed',
    icon: '📦',
    formalRate: 90,
    informalRate: 60,
    names: {
      'mr': 'मिश्रित ई-कचरा (Mixed)',
      'hi': 'मिश्रित ई-वेस्ट (Mixed)',
      'en': 'Mixed E-Waste',
    },
    valueTip: ValueTip(
      title: {
        'mr': 'वेगवेगळे सुटे भाग वेगवेगळे ठेवा!',
        'hi': 'अलग-अलग कबाड़ को छांट कर रखें!',
        'en': 'Segregate components prior to sale!',
      },
      description: {
        'mr':
            'बॅटरी आणि स्क्रीन इतर इलेक्ट्रॉनिक साहित्यापासून वेगळे ठेवल्यास अधिकृत केंद्रावर प्रत्येक प्रकाराला योग्य भाव मिळतो.',
        'hi':
            'बैटरी और स्क्रीन को बाकी सामग्री से अलग रखने पर अधिकृत केंद्र पर हर चीज का सही दाम मिलता है।',
        'en':
            'Separating batteries and boards from mixed chassis prevents contamination and improves batch valuation.',
      },
    ),
  ),
  'other': MaterialItem(
    id: 'other',
    icon: '❓',
    formalRate: 70,
    informalRate: 45,
    names: {
      'mr': 'इतर / अस्पष्ट (Other)',
      'hi': 'अन्य / अस्पष्ट (Other)',
      'en': 'Other / Unclear',
    },
    valueTip: ValueTip(
      title: {
        'mr': 'अस्पष्ट वस्तू अधिकृत केंद्रावर तपासा!',
        'hi': 'अस्पष्ट कबाड़ अधिकृत केंद्र पर जांचें!',
        'en': 'Get unclear scrap verified formally!',
      },
      description: {
        'mr':
            'अंदाजाने माल फेकून देऊ नका. अधिकृत केंद्रात तपासणी करून अचूक मूल्य निश्चित केले जाते.',
        'hi':
            'बिना जाने कम दाम में न बेचें। अधिकृत केंद्र पर जांच करवाकर सही मूल्य प्राप्त करें।',
        'en':
            'Do not sell blind to middlemen. Authorized yards can identify valuable trace alloys.',
      },
    ),
  ),
};

const translations = <String, Map<String, String>>{
  'mr': {
    'appTitle': 'कबाडीवाला कनेक्ट',
    'subtitle': 'SIH 2026 • JNARDDC (खाण मंत्रालय)',
    'heroBadge': '🌿 अधिकृत ई-कचरा क्रांती',
    'heroTitle': 'रास्त भाव. सुरक्षित काम. अधिकृत नोंद.',
    'heroDescription':
        'अंदाजाने माल विकणे थांबवा! ई-कचऱ्याचा अचूक भाव जाणा, सुरक्षित हाताळणी शिका आणि खात्रीशीर पावती मिळवा.',
    'featFair': 'अधिकृत तोल व भाव',
    'featSafety': 'आरोग्य सुरक्षा नियम',
    'featQr': 'QR लॉट नोंद',
    'featCash': 'तत्काळ रोख रक्कम',
    'start': 'नवीन भंगार नोंदणी करा',
    'rates': 'आजचे संदर्भ भाव ऐका',
    'disclaimer': 'सीडेड प्रोटोटाइप संदर्भ दर — थेट बाजार भाव नाही',
    'recent': 'अलीकडील नोंदणी',
    'viewAll': 'सर्व पहा →',
    'captureTitle': 'भंगार मालाचा फोटो काढा',
    'captureSub': 'कॅमेऱ्याने फोटो घ्या किंवा गॅलरीतून निवडा.',
    'capturePrompt': 'येथे फोटो अपलोड करा किंवा काढा',
    'camera': 'कॅमेरा',
    'gallery': 'गॅलरी',
    'samples': 'त्वरित चाचणी नमुने (Offline Samples)',
    'scanning': 'सामग्री ओळखत आहे...',
    'confirmTitle': 'सामग्रीची खात्री करा',
    'confirmSub': 'आम्ही चुकीचा अंदाज न लावता थेट खात्री करून घेतो.',
    'suggestion': 'प्रोटोटाइप अंदाज',
    'selectCorrect': 'अचूक निवडीसाठी खालील पर्यायावर टॅप करा:',
    'hazardous': 'धोकादायक',
    'priceTitle': 'वजन आणि रास्त भाव अंदाज',
    'priceSub': 'वजन नोंदवा आणि अधिकृत व स्थानिक दरातील फरक पहा.',
    'selectedMaterial': 'निवडलेली सामग्री',
    'listenPrice': 'भाव ऐका',
    'weight': 'मालाचे वजन (किलोग्रॅम)',
    'formalRate': 'अधिकृत संदर्भ मूल्य',
    'fairEstimate': 'एकूण योग्य अंदाज',
    'informalPrice': 'स्थानिक अनौपचारिक भाव',
    'extraValue': 'अधिकृत केंद्रात अतिरिक्त फायदा',
    'formalBenefit':
        'अधिकृत रीसायकलिंगमुळे मध्यस्थांशिवाय योग्य तोल, अचूक वजन आणि संपूर्ण मूल्य मिळते.',
    'lotTitle': 'लॉट पावती आणि हस्तांतरण',
    'lotSub': 'अधिकृत केंद्रासाठी डिजिटल पावती तयार केली आहे.',
    'awaiting': 'हस्तांतरणाची प्रतीक्षा',
    'material': 'सामग्री',
    'totalWeight': 'एकूण वजन',
    'expectedValue': 'अपेक्षित मूल्य',
    'traceNotice':
        'हा QR कोड अधिकृत रिसायकलरकडे स्कॅन करून थेट पडताळणी करता येते.',
    'witness': 'हस्तांतरण पुरावा (Witness Selfie)',
    'optional': 'पर्यायी',
    'witnessPrompt': 'हस्तांतरण करताना फोटो जोडा',
    'takePhoto': 'फोटो घ्या',
    'samplePhoto': 'नमुना फोटो',
    'faceNotice':
        'फक्त प्रोटोटाइप पुरावा — कोणताही चेहरा ओळख तंत्रज्ञान वापरलेले नाही.',
    'payment': 'पैसे मिळवण्याचे माध्यम',
    'cash': 'रोख रक्कम (Cash) - प्राधान्य',
    'cashSub': 'केंद्रावर ताबडतोब हातावर रोख पैसे',
    'upi': 'UPI (Google Pay / PhonePe)',
    'upiSub': 'थेट बँक खात्यात डिजिटल जमा',
    'paymentNotice': 'येथे प्रत्यक्ष पेमेंट होत नाही; फक्त पसंती नोंदवली जाते.',
    'confirmHandover': 'हस्तांतरण निश्चित करा',
    'success': 'हस्तांतरण यशस्वीपणे नोंदवले!',
    'successSub': 'अधिकृत रिसायकलिंग पावती नोंद वहीमध्ये सुरक्षित झाली आहे.',
    'impact': 'अंदाजे पुनर्प्राप्ती क्षमता (Micro-Impact)',
    'seeded': 'सीडेड गुणक',
    'environment':
        'अधिकृत साखळीमुळे विषारी धूर, आम्ल प्रक्रिया आणि पर्यावरणातील प्रदूषण रोखण्यास मदत होते.',
    'ledger': 'या सत्रातील एकूण जमा वही',
    'totalValue': 'एकूण मूल्य',
    'another': 'दुसरा भंगार लॉट नोंदवा',
    'home': 'मुख्य पानावर जा',
    'valueTip': 'मूल्य वाढवण्याचा मार्ग',
    'listen': 'ऐका',
    'understood': 'समजले — पुढे चला',
    'acknowledge': 'मला समजले — पुढे जा',
    'replay': 'इशारा पुन्हा ऐका',
    'next': 'पुढे जा',
    'close': 'बंद करा',
    'cancel': 'रद्द करा',
    'yesConfirm': 'होय, पूर्ण करा',
    'reset': 'डेमो रीसेट करा (सत्र साफ करा)',
    'about': 'कबाडीवाला कनेक्ट माहिती',
    'qrView': 'QR पहा',
    'photoAdded': 'हस्तांतरण फोटो जोडला!',
  },
  'hi': {
    'appTitle': 'कबाड़ीवाला कनेक्ट',
    'subtitle': 'SIH 2026 • JNARDDC (खान मंत्रालय)',
    'heroBadge': '🌿 अधिकृत ई-कचरा क्रांति',
    'heroTitle': 'उचित मूल्य. सुरक्षित कार्य. प्रमाणित रिकॉर्ड.',
    'heroDescription':
        'अनुमान से कबाड़ बेचना बंद करें! ई-वेस्ट का सही भाव जानें, सुरक्षित छंटाई सीखें और अधिकृत पर्ची पाएं।',
    'featFair': 'अधिकृत तौल व भाव',
    'featSafety': 'स्वास्थ्य सुरक्षा नियम',
    'featQr': 'QR लॉट रिकॉर्ड',
    'featCash': 'तत्काल नकद भुगतान',
    'start': 'नया कबाड़ पिकअप शुरू करें',
    'rates': 'आज के संदर्भ भाव सुनें',
    'disclaimer': 'सीडेड प्रोटोटाइप संदर्भ दर — वास्तविक बाज़ार भाव नहीं',
    'recent': 'हालिया रिकॉर्ड',
    'viewAll': 'सभी देखें →',
    'captureTitle': 'कबाड़ का फोटो खींचें',
    'captureSub': 'कैमरे से फोटो लें या गैलरी से चुनें।',
    'capturePrompt': 'यहाँ फोटो अपलोड करें या खींचें',
    'camera': 'कैमरा',
    'gallery': 'गैलरी',
    'samples': 'त्वरित परीक्षण नमूने (Offline Samples)',
    'scanning': 'सामग्री की पहचान हो रही है...',
    'confirmTitle': 'सामग्री की पुष्टि करें',
    'confirmSub': 'हम गलत अनुमान लगाने के बजाय आपसे पुष्टि करते हैं।',
    'suggestion': 'प्रोटोटाइप सुझाव',
    'selectCorrect': 'सटीक चयन के लिए नीचे दिए विकल्प पर टैप करें:',
    'hazardous': 'खतरनाक',
    'priceTitle': 'वजन और उचित मूल्य अनुमान',
    'priceSub': 'वजन दर्ज करें और अधिकृत व स्थानीय दरों में अंतर देखें।',
    'selectedMaterial': 'चुनी गई सामग्री',
    'listenPrice': 'भाव सुनें',
    'weight': 'कबाड़ का वजन (किलोग्राम)',
    'formalRate': 'अधिकृत संदर्भ मूल्य',
    'fairEstimate': 'कुल उचित अनुमान',
    'informalPrice': 'स्थानीय अनौपचारिक भाव',
    'extraValue': 'अधिकृत केंद्र में अतिरिक्त लाभ',
    'formalBenefit':
        'अधिकृत रीसाइक्लिंग से बिचौलियों के बिना पूरा तौल, सही वजन और पूरा मूल्य मिलता है।',
    'lotTitle': 'लॉट रसीद और हैंडओवर',
    'lotSub': 'अधिकृत केंद्र के लिए डिजिटल रसीद तैयार की गई है।',
    'awaiting': 'हस्तांतरण की प्रतीक्षा',
    'material': 'सामग्री',
    'totalWeight': 'कुल वजन',
    'expectedValue': 'अनुमानित मूल्य',
    'traceNotice':
        'यह QR कोड अधिकृत रिसाइक्लर द्वारा स्कैन कर सत्यापित किया जा सकता है।',
    'witness': 'हैंडओवर गवाह फोटो',
    'optional': 'वैकल्पिक',
    'witnessPrompt': 'हैंडओवर करते समय फोटो जोड़ें',
    'takePhoto': 'फोटो लें',
    'samplePhoto': 'नमूना फोटो',
    'faceNotice':
        'केवल प्रोटोटाइप साक्ष्य — चेहरे की पहचान का उपयोग नहीं किया गया है।',
    'payment': 'भुगतान का माध्यम',
    'cash': 'नकद भुगतान (Cash) - प्राथमिकता',
    'cashSub': 'केंद्र पर तुरंत नकद भुगतान',
    'upi': 'UPI (Google Pay / PhonePe)',
    'upiSub': 'सीधे बैंक खाते में डिजिटल भुगतान',
    'paymentNotice':
        'यहाँ वास्तविक भुगतान नहीं होता; केवल प्राथमिकता दर्ज की जाती है।',
    'confirmHandover': 'हैंडओवर की पुष्टि करें',
    'success': 'हस्तांतरण सफलतापूर्वक दर्ज हुआ!',
    'successSub': 'अधिकृत रीसाइक्लिंग रसीद बहीखाते में सुरक्षित हो गई है।',
    'impact': 'अनुमानित पुनर्प्राप्ति क्षमता',
    'seeded': 'सीडेड कारक',
    'environment':
        'अधिकृत प्रणाली जहरीला धुआं और पर्यावरण प्रदूषण रोकने में मदद करती है।',
    'ledger': 'इस सत्र का कुल बहीखाता',
    'totalValue': 'कुल मूल्य',
    'another': 'दूसरा कबाड़ लॉट दर्ज करें',
    'home': 'मुख्य पृष्ठ पर जाएं',
    'valueTip': 'मूल्य बढ़ाने का तरीका',
    'listen': 'सुनें',
    'understood': 'समझ गया — आगे बढ़ें',
    'acknowledge': 'मुझे समझ आ गया — आगे बढ़ें',
    'replay': 'चेतावनी दोबारा सुनें',
    'next': 'आगे बढ़ें',
    'close': 'बंद करें',
    'cancel': 'रद्द करें',
    'yesConfirm': 'हाँ, पूरा करें',
    'reset': 'डेमो रीसेट करें',
    'about': 'कबाड़ीवाला कनेक्ट जानकारी',
    'qrView': 'QR देखें',
    'photoAdded': 'हैंडओवर फोटो जोड़ा गया!',
  },
  'en': {
    'appTitle': 'Kabadiwala Connect',
    'subtitle': 'SIH 2026 • JNARDDC (Ministry of Mines)',
    'heroBadge': '🌿 Formal E-Waste Revolution',
    'heroTitle': 'Fair Value. Safe Handling. Verified Handover.',
    'heroDescription':
        'Stop selling scrap on guesses! Discover formal reference prices, learn hazard protection, and create verified records.',
    'featFair': 'Formal Weight & Rate',
    'featSafety': 'Safety Protection Rules',
    'featQr': 'QR Lot Traceability',
    'featCash': 'Instant Cash Preference',
    'start': 'Start Scrap Pickup',
    'rates': "Hear Today’s Rates",
    'recent': 'Recent Handover',
    'viewAll': 'View All →',
    'captureTitle': 'Photograph the scrap',
    'captureSub': 'Take a clear photo or pick from your device gallery.',
    'capturePrompt': 'Upload or capture scrap photo',
    'camera': 'Camera',
    'gallery': 'Gallery',
    'samples': 'Quick Demo Samples (Guaranteed Offline)',
    'scanning': 'Identifying material...',
    'confirmTitle': 'Confirm the material',
    'confirmSub': 'We ask you to verify rather than making an unsafe guess.',
    'suggestion': 'Prototype Suggestion',
    'selectCorrect': 'Tap below to select or correct the material:',
    'hazardous': 'Hazardous',
    'priceTitle': 'Weight & Fair-Price Estimate',
    'priceSub': 'Adjust weight to compare formal reference and informal price.',
    'selectedMaterial': 'Selected Material',
    'listenPrice': 'Listen to Price',
    'weight': 'Scrap Weight (kilograms)',
    'formalRate': 'Formal Reference Price',
    'fairEstimate': 'Fair Reference Estimate',
    'informalPrice': 'Typical Informal Price',
    'extraValue': 'Potential Additional Value',
    'formalBenefit':
        'A formal recycling channel provides transparent weighing, fair pricing, and documented verification.',
    'lotTitle': 'Lot Record & Handover',
    'lotSub': 'Digital handover pass generated for authorized recycling.',
    'awaiting': 'Awaiting Handover',
    'material': 'Material',
    'totalWeight': 'Total Weight',
    'expectedValue': 'Reference Estimate',
    'traceNotice':
        'This QR code contains traceable metadata for authorized recyclers.',
    'witness': 'Handover Witness Photo',
    'optional': 'Optional',
    'witnessPrompt': 'Attach photo of exchange',
    'takePhoto': 'Take Selfie',
    'samplePhoto': 'Sample Selfie',
    'faceNotice': 'Prototype evidence only — no facial recognition is used.',
    'payment': 'Payment Preference',
    'cash': 'Cash Payment - Primary',
    'cashSub': 'Instant cash handed over at collection point',
    'upi': 'UPI (Google Pay / PhonePe)',
    'upiSub': 'Direct digital transfer to bank account',
    'paymentNotice':
        'No money is transferred; this records the chosen preference only.',
    'confirmHandover': 'Confirm Handover',
    'success': 'Handover Recorded!',
    'successSub': 'Traceable handover receipt is saved to the session ledger.',
    'impact': 'Estimated Recovery Potential (Micro-Impact)',
    'seeded': 'Seeded Factors',
    'environment':
        'Formal recycling prevents open burning, acid leaching, and toxic soil runoff.',
    'ledger': 'Current Session Ledger',
    'totalValue': 'Total Reference Value',
    'another': 'Start Another Pickup',
    'home': 'Return to Home',
    'valueTip': 'Value-Recovery Tip',
    'listen': 'Listen',
    'understood': 'Got It — Continue',
    'acknowledge': 'I Understand — Continue',
    'replay': 'Replay Warning',
    'next': 'Continue',
    'close': 'Close',
    'cancel': 'Cancel',
    'yesConfirm': 'Yes, Confirm',
    'reset': 'Restart Demo (Clear Session)',
    'about': 'About Kabadiwala Connect',
    'qrView': 'View QR',
    'photoAdded': 'Handover photo added!',
  },
};

String textFor(String language, String key) =>
    translations[language]?[key] ?? translations['en']?[key] ?? key;

const stepLabels = <String, List<String>>{
  'mr': [
    'फोटो घ्या',
    'प्रकार तपासा',
    'वजन व भाव',
    'हस्तांतरण लॉट',
    'पावती व प्रभाव'
  ],
  'hi': [
    'फोटो लें',
    'प्रकार पुष्टि',
    'वजन व भाव',
    'हस्तांतरण लॉट',
    'रसीद व प्रभाव'
  ],
  'en': [
    'Capture Photo',
    'Confirm Scrap',
    'Weight & Rates',
    'Handover Lot',
    'Receipt & Impact'
  ],
};
