import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'app_controller.dart';
import 'data/app_data.dart';
import 'models/lot_record.dart';
import 'screens/confirm_price.dart';
import 'screens/home_capture.dart';
import 'screens/lot_ledger.dart';
import 'widgets/common.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = AppController();
  await controller.load();
  runApp(KabadiwalaConnectApp(controller: controller));
}

class KabadiwalaConnectApp extends StatelessWidget {
  const KabadiwalaConnectApp({required this.controller, super.key});
  final AppController controller;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Kabadiwala Connect',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: AppShell(controller: controller),
      );
}

class AppShell extends StatefulWidget {
  const AppShell({required this.controller, super.key});
  final AppController controller;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    c.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    c.removeListener(_refresh);
    c.dispose();
    super.dispose();
  }

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
          SnackBar(content: Text(value), behavior: SnackBarBehavior.floating));
  }

  Future<void> _next() async {
    switch (c.screen) {
      case AppScreen.capture:
        if (c.capturedImage != null) c.goTo(AppScreen.confirm);
        return;
      case AppScreen.confirm:
        if (c.material.isHazardous && !c.safetyAcknowledged) {
          final accepted = await _showHazardDialog();
          if (!accepted || !mounted) return;
        }
        final continueFromTip = await _showValueTip();
        if (continueFromTip && mounted) c.goTo(AppScreen.price);
        return;
      case AppScreen.price:
        c.goTo(AppScreen.lot);
        return;
      case AppScreen.lot:
        await _confirmHandover();
        return;
      case AppScreen.welcome:
      case AppScreen.ledger:
        break;
    }
  }

  List<String> _hazardRules() {
    if (c.material.hazardType == 'battery') {
      return switch (c.language) {
        'mr' => [
            'बॅटरी कधीही फोडू नका किंवा चेपू नका.',
            'उष्णता आणि विस्तव यांपासून दूर ठेवा.',
            'हाताळताना शक्य असल्यास हातमोजे वापरा.',
            'वेगळ्या कोरड्या डब्यात साठवून ठेवा.'
          ],
        'hi' => [
            'बैटरी कभी न फोड़ें या दबाएं।',
            'गर्मी और आग से दूर रखें।',
            'दस्ताने पहन कर उठाएं।',
            'अलग सूखे डिब्बे में सुरक्षित रखें।'
          ],
        _ => [
            'Do not puncture or crush the battery.',
            'Keep away from heat, sparks and open flames.',
            'Use protective gloves if accessible.',
            'Store in a separate dry container.'
          ],
      };
    }
    return switch (c.language) {
      'mr' => [
          'काच चुकूनही फोडू नका.',
          'उघडण्याचा किंवा तोडण्याचा प्रयत्न करू नका.',
          'दोन हातांनी काळजीपूर्वक उचला.',
          'थेट अधिकृत रिसायकलरकडे द्या.'
        ],
      'hi' => [
          'कांच बिल्कुल न तोड़ें।',
          'अंदर से खोलने का प्रयास न करें।',
          'दोनों हाथों से सावधानी से उठाएं।',
          'सीधे अधिकृत रिसाइक्लर को दें।'
        ],
      _ => [
          'Do not break or shatter the glass.',
          'Do not attempt to dismantle or pry open.',
          'Carry with both hands carefully.',
          'Transfer intact to an authorized yard.'
        ],
    };
  }

  String _hazardTitle() {
    final battery = c.material.hazardType == 'battery';
    return switch (c.language) {
      'mr' => battery
          ? 'सावधान: रासायनिक आणि आगीची शक्यता!'
          : 'सावधान: उच्च व्होल्टेज आणि विषारी शिसे!',
      'hi' => battery
          ? 'सावधान: रासायनिक व आग लगने का जोखिम!'
          : 'सावधान: उच्च वोल्टेज और जहरीला लेड!',
      _ => battery
          ? 'CAUTION: Chemical & Fire Hazard!'
          : 'CAUTION: High Voltage & Toxic Lead Hazard!',
    };
  }

  Future<bool> _showHazardDialog() async {
    final rules = _hazardRules();
    final title = _hazardTitle();
    await c.speak('$title. ${rules[0]}. ${rules[1]}');
    if (!mounted) return false;
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => Dialog.fullscreen(
            backgroundColor: const Color(0xFF991B1B),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                        child: Text('⚠️', style: TextStyle(fontSize: 72))),
                    const SizedBox(height: 8),
                    Text(title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 20),
                    ...List.generate(
                        rules.length,
                        (index) => Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 9),
                              padding: const EdgeInsets.all(13),
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.13),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Text(
                                  '${[
                                    '🚫',
                                    '🔥',
                                    '🧤',
                                    '📦'
                                  ][index]}  ${rules[index]}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700)),
                            )),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () => c.speak('$title. ${rules.join('. ')}'),
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54)),
                      icon: const Icon(Icons.volume_up_rounded),
                      label: Text(c.t('replay')),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () {
                        c.acknowledgeSafety();
                        Navigator.pop(dialogContext, true);
                      },
                      style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF991B1B)),
                      child: Text(c.t('acknowledge'),
                          style: const TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ) ??
        false;
  }

  Future<bool> _showValueTip() async {
    final tip = c.material.valueTip;
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Expanded(
                    child: Text('💡 ${c.t('valueTip')}',
                        style: const TextStyle(
                            color: Color(0xFFB45309),
                            fontSize: 16,
                            fontWeight: FontWeight.w900))),
                IconButton(
                    onPressed: () => c.speak(
                        '${tip.titleFor(c.language)}. ${tip.descriptionFor(c.language)}'),
                    icon: const Icon(Icons.volume_up_rounded)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(c.material.icon, style: const TextStyle(fontSize: 60)),
                const SizedBox(height: 10),
                Text(tip.titleFor(c.language),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(tip.descriptionFor(c.language),
                    style: const TextStyle(color: textMuted, height: 1.4)),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  c.stopSpeech();
                  Navigator.pop(dialogContext, true);
                },
                style: FilledButton.styleFrom(
                    backgroundColor: warning,
                    minimumSize: const Size.fromHeight(48)),
                child: Text(c.t('understood')),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _confirmHandover() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${c.t('confirmHandover')}?'),
        content: Text(
            '${c.material.nameFor(c.language)} (${c.weightKg} kg) — ${c.currencyFormal}'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(c.t('cancel'))),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(c.t('yesConfirm'))),
        ],
      ),
    );
    if (accepted == true) {
      await c.completeHandover();
      if (mounted) _message('🎉 ${c.t('success')}');
    }
  }

  void _showRates() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📢 ${c.t('rates')}',
                  style: const TextStyle(
                      color: primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              ...['cables', 'pcb', 'battery', 'motor', 'crt'].map((key) {
                final item = materials[key]!;
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      side: const BorderSide(color: border),
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading:
                        Text(item.icon, style: const TextStyle(fontSize: 30)),
                    title: Text(item.nameFor(c.language),
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text(
                        '${c.formatCurrency(item.formalRate)}/kg   ${c.formatCurrency(item.informalRate)}/kg'),
                    trailing: IconButton(
                      icon: const Icon(Icons.volume_up_rounded),
                      onPressed: () {
                        final speech = c.language == 'en'
                            ? '${item.nameFor(c.language)}. Reference formal price ${item.formalRate} rupees per kilogram. Typical informal price ${item.informalRate} rupees per kilogram.'
                            : '${item.nameFor(c.language)}. अधिकृत संदर्भ भाव ${item.formalRate} रुपये प्रति किलो. स्थानिक भाव ${item.informalRate} रुपये प्रति किलो.';
                        c.speak(speech);
                      },
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              PrimaryButton(
                label: c.t('start'),
                icon: Icons.camera_alt_rounded,
                onPressed: () {
                  Navigator.pop(sheetContext);
                  c.goTo(AppScreen.capture);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showAbout() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c.t('about'),
                  style: const TextStyle(
                      color: primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              const Text(
                  'Smart India Hackathon (SIH 2026) अंतर्गत खाण मंत्रालय (JNARDDC) साठी विकसित प्रोटोटाइप.'),
              const SizedBox(height: 10),
              const AppCard(
                color: subtle,
                child: Text(
                    'ध्येय: अनौपचारिक भंगार वेचकांना योग्य भाव, सुरक्षित हाताळणी आणि अधिकृत साखळीतील नोंद उपलब्ध करून देणे. सर्व दर व आकडे seeded prototype data आहेत.'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    final reset = await showDialog<bool>(
                      context: sheetContext,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(c.t('reset')),
                        content: const Text(
                            'सर्व सत्र नोंदी कायमच्या साफ करायच्या आहेत का?'),
                        actions: [
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, false),
                              child: Text(c.t('cancel'))),
                          FilledButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, true),
                              child: Text(c.t('yesConfirm'))),
                        ],
                      ),
                    );
                    if (reset == true) {
                      await c.resetDemo();
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                    }
                  },
                  style: FilledButton.styleFrom(backgroundColor: danger),
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: Text(c.t('reset')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQr(LotRecord record) {
    final payload = jsonEncode({
      'lot': record.lotId,
      'cat': record.category,
      'kg': record.weightKg,
      'formalPrice': record.formalPrice,
      'ts': record.timestamp.toIso8601String(),
      'org': 'JNARDDC_SIH26'
    });
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(c.t('qrView'), textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
                data: payload,
                size: 220,
                eyeStyle: const QrEyeStyle(color: primary)),
            const SizedBox(height: 10),
            Text(record.lotId,
                style: const TextStyle(
                    color: secondary,
                    fontFamily: 'monospace',
                    fontSize: 17,
                    fontWeight: FontWeight.w900)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(c.t('close')))
        ],
      ),
    );
  }

  Widget _body() => switch (c.screen) {
        AppScreen.welcome => HomeScreen(controller: c, onShowRates: _showRates),
        AppScreen.capture =>
          CaptureScreen(controller: c, showMessage: _message),
        AppScreen.confirm => ConfirmScreen(controller: c),
        AppScreen.price => PriceScreen(controller: c),
        AppScreen.lot => LotScreen(controller: c, showMessage: _message),
        AppScreen.ledger => LedgerScreen(controller: c, onShowQr: _showQr),
      };

  String _bottomLabel() => switch (c.screen) {
        AppScreen.capture => c.t('confirmTitle'),
        AppScreen.confirm => c.t('priceTitle'),
        AppScreen.price => c.t('lotTitle'),
        AppScreen.lot => c.t('confirmHandover'),
        _ => c.t('next'),
      };

  @override
  Widget build(BuildContext context) {
    final body = Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76),
        child: _Header(controller: c),
      ),
      body: Column(
        children: [
          if (c.step > 0) _StepProgress(controller: c),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: KeyedSubtree(key: ValueKey(c.screen), child: _body()),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          c.screen == AppScreen.welcome || c.screen == AppScreen.ledger
              ? null
              : SafeArea(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(top: BorderSide(color: border))),
                    child: Row(
                      children: [
                        IconButton.outlined(
                            onPressed: c.goBack,
                            icon: const Icon(Icons.arrow_back_rounded)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: PrimaryButton(
                            label: _bottomLabel(),
                            icon: c.screen == AppScreen.lot
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                            onPressed: c.screen == AppScreen.capture &&
                                    c.capturedImage == null
                                ? null
                                : _next,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
    return PopScope(
      canPop: c.screen == AppScreen.welcome,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && c.screen != AppScreen.welcome) c.goBack();
      },
      child: ColoredBox(
        color: canvas,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: body,
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});
  final AppController controller;

  String get _languageLabel => switch (controller.language) {
        'mr' => 'मराठी',
        'hi' => 'हिंदी',
        _ => 'EN',
      };

  void _nextLanguage() {
    final next = switch (controller.language) {
      'en' => 'mr',
      'mr' => 'hi',
      _ => 'en',
    };
    controller.setLanguage(next);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              InkWell(
                onTap: () => controller.goTo(AppScreen.welcome),
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(11)),
                      child: const Icon(Icons.recycling_rounded,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Kabadiwala Connect',
                            maxLines: 1,
                            style: TextStyle(
                                color: primary, fontWeight: FontWeight.w900)),
                        SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_rounded,
                                size: 13, color: textMuted),
                            SizedBox(width: 3),
                            Text('Harsh',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: textMuted,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _nextLanguage,
                style: TextButton.styleFrom(
                  foregroundColor: primary,
                  backgroundColor: subtle,
                  side: const BorderSide(color: border),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999)),
                ),
                icon: const Icon(Icons.language_rounded, size: 18),
                label: Text(_languageLabel,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final step = controller.step;
    final labels = stepLabels[controller.language] ?? stepLabels['en']!;
    final stepWord = switch (controller.language) {
      'mr' => 'पायरी',
      'hi' => 'चरण',
      _ => 'Step',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Text('$stepWord $step / 5: ${labels[step - 1]}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w800))),
              Text('${step * 20}%',
                  style: const TextStyle(
                      fontSize: 12,
                      color: primary,
                      fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
              value: step / 5,
              minHeight: 6,
              borderRadius: BorderRadius.circular(99),
              backgroundColor: primaryLight,
              color: primary),
        ],
      ),
    );
  }
}
