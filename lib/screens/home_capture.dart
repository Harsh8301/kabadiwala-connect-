import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app_controller.dart';
import '../data/app_data.dart';
import '../widgets/common.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.controller,
    required this.onShowRates,
    super.key,
  });

  final AppController controller;
  final VoidCallback onShowRates;

  @override
  Widget build(BuildContext context) {
    final latest = controller.ledger.isEmpty ? null : controller.ledger.last;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [primaryDark, primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Color(0x331B5E20), blurRadius: 18, offset: Offset(0, 8)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Pill(
                controller.t('heroBadge'),
                color: Colors.white.withOpacity(.14),
                textColor: Colors.white,
              ),
              const SizedBox(height: 14),
              Text(
                controller.t('heroTitle'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                controller.t('heroDescription'),
                style: const TextStyle(color: Color(0xFFE8F5E9), height: 1.45),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Pill('⚖️ ${controller.t('featFair')}', color: const Color(0x22FFFFFF), textColor: Colors.white),
                  Pill('🛡️ ${controller.t('featSafety')}', color: const Color(0x22FFFFFF), textColor: Colors.white),
                  Pill('📜 ${controller.t('featQr')}', color: const Color(0x22FFFFFF), textColor: Colors.white),
                  Pill('💵 ${controller.t('featCash')}', color: const Color(0x22FFFFFF), textColor: Colors.white),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        PrimaryButton(
          label: controller.t('start'),
          icon: Icons.camera_alt_rounded,
          onPressed: () => controller.goTo(AppScreen.capture),
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: controller.t('rates'),
          icon: Icons.campaign_rounded,
          onPressed: onShowRates,
        ),
        const SizedBox(height: 10),
        Center(child: Pill('ℹ️ ${controller.t('disclaimer')}')),
        if (latest != null) ...[
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('🕒 ${controller.t('recent')}', style: const TextStyle(color: primary, fontWeight: FontWeight.w800)),
                    TextButton(
                      onPressed: () => controller.goTo(AppScreen.ledger),
                      child: Text(controller.t('viewAll')),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(latest.lotId, style: const TextStyle(color: secondary, fontWeight: FontWeight.w800)),
                          Text('${materials[latest.category]!.nameFor(controller.language)} • ${latest.weightKg} kg'),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(controller.formatCurrency(latest.formalPrice), style: const TextStyle(color: primary, fontSize: 17, fontWeight: FontWeight.w900)),
                        Text(latest.timeLabel, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class CaptureScreen extends StatelessWidget {
  const CaptureScreen({required this.controller, required this.showMessage, super.key});

  final AppController controller;
  final void Function(String) showMessage;

  Future<void> _pick(ImageSource source, bool witness) async {
    final success = await controller.chooseImage(source, witness: witness);
    if (!success) showMessage('Image selection cancelled or unavailable.');
  }

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ScreenHeading(title: controller.t('captureTitle'), subtitle: controller.t('captureSub')),
          const SizedBox(height: 14),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 250,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: primary, width: 1.5),
                ),
                child: controller.capturedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: const BoxDecoration(color: primaryLight, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt_rounded, size: 32, color: primary),
                          ),
                          const SizedBox(height: 10),
                          Text(controller.t('capturePrompt'), style: const TextStyle(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          const Text('PNG, JPG or native camera', style: TextStyle(fontSize: 12, color: textMuted)),
                        ],
                      )
                    : Image.memory(controller.capturedImage!, fit: BoxFit.cover),
              ),
              if (controller.isScanning)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.74),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 14),
                        Text(controller.t('scanning'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        const Pill('Roboflow Model: e-waste-wjf5j/1', color: Color(0x66000000), textColor: Colors.white),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: SecondaryButton(label: controller.t('camera'), icon: Icons.camera_alt_rounded, onPressed: () => _pick(ImageSource.camera, false))),
              const SizedBox(width: 10),
              Expanded(child: SecondaryButton(label: controller.t('gallery'), icon: Icons.photo_library_rounded, onPressed: () => _pick(ImageSource.gallery, false))),
            ],
          ),
          const SizedBox(height: 18),
          Text('⚡ ${controller.t('samples')}', style: const TextStyle(color: textMuted, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: ['pcb', 'battery', 'cables', 'motor'].map((id) {
              final item = materials[id]!;
              return InkWell(
                onTap: controller.isScanning ? null : () => controller.selectSample(id),
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item.icon, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 8),
                      Flexible(child: Text(item.nameFor(controller.language).split(' (').first, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700))),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
}
