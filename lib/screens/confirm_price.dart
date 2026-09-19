import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../data/app_data.dart';
import '../widgets/common.dart';

class ConfirmScreen extends StatelessWidget {
  const ConfirmScreen({required this.controller, super.key});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final suggested = materials[controller.detectedCategory];
    final selected = materials[controller.confirmedCategory];
    final hasError = controller.detectionStatus == 'error';
    final hasSuggestion = suggested != null;
    final title = hasError
        ? controller.t('detectionUnavailable')
        : hasSuggestion
            ? '${controller.detectionStatus == 'possible' ? controller.t('possibleMaterial') : controller.t('suggestion')}: ${suggested.nameFor(controller.language)}'
            : controller.t('uncertainDetection');
    final confidence = (controller.detectionConfidence * 100).round();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ScreenHeading(
            title: controller.t('confirmTitle'),
            subtitle: controller.t('confirmSub')),
        const SizedBox(height: 14),
        AppCard(
          color:
              hasSuggestion ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
          borderColor:
              hasSuggestion ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DetectionPreview(controller: controller),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  Pill(
                      controller.detectionSource == 'demo'
                          ? 'Demo sample'
                          : controller.t('suggestion'),
                      color: primary,
                      textColor: Colors.white),
                  if (hasSuggestion)
                    Pill('${controller.t('confidence')}: $confidence%',
                        color: primaryLight, textColor: primary),
                ],
              ),
              const SizedBox(height: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(
                hasError
                    ? (controller.detectionError.isEmpty
                        ? controller.t('detectionUnavailable')
                        : controller.detectionError)
                    : controller.t('verifyAi'),
                style: const TextStyle(color: textMuted, height: 1.35),
              ),
              if (!hasSuggestion) ...[
                const SizedBox(height: 6),
                Text(controller.t('manualFallback'),
                    style: const TextStyle(
                        color: Color(0xFFD97706), fontWeight: FontWeight.w800)),
              ],
              if (controller.capturedImage != null &&
                  controller.detectionSource != 'demo') ...[
                const SizedBox(height: 10),
                SecondaryButton(
                  label: controller.t('retryDetection'),
                  icon: Icons.refresh_rounded,
                  onPressed:
                      controller.isScanning ? null : controller.retryDetection,
                ),
              ],
              if (selected != null) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: selected.recoverableMinerals
                      .map((mineral) => Pill(
                            '${controller.t('recoverable')}: $mineral',
                            color: const Color(0xFFE0F2FE),
                            textColor: secondary,
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(controller.t('selectCorrect'),
            style:
                const TextStyle(color: textMuted, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.22,
          children: materials.values.map((item) {
            final selected = item.id == controller.confirmedCategory;
            return InkWell(
              onTap: () => controller.setCategory(item.id),
              borderRadius: BorderRadius.circular(16),
              child: Ink(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: selected ? primaryLight : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? primary
                        : item.isHazardous
                            ? const Color(0xFFFCA5A5)
                            : border,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item.icon, style: const TextStyle(fontSize: 34)),
                    const SizedBox(height: 5),
                    Text(item.nameFor(controller.language),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: const TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 5),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 4,
                      runSpacing: 4,
                      children: item.recoverableMinerals
                          .take(2)
                          .map((mineral) => Pill(
                                mineral,
                                color: const Color(0xFFE0F2FE),
                                textColor: secondary,
                              ))
                          .toList(),
                    ),
                    if (item.isHazardous) ...[
                      const SizedBox(height: 5),
                      Pill('⚠️ ${controller.t('hazardous')}',
                          color: const Color(0xFFFEE2E2), textColor: danger),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class DetectionPreview extends StatelessWidget {
  const DetectionPreview({required this.controller, super.key});
  final AppController controller;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (controller.capturedImage == null)
                MaterialPreview(
                  category: controller.detectedCategory.isEmpty
                      ? 'other'
                      : controller.detectedCategory,
                  height: 220,
                )
              else
                Image.memory(controller.capturedImage!, fit: BoxFit.cover),
              if (controller.detectionPredictions.any((box) => box.hasBox))
                CustomPaint(painter: _DetectionBoxPainter(controller)),
            ],
          ),
        ),
      );
}

class _DetectionBoxPainter extends CustomPainter {
  const _DetectionBoxPainter(this.controller);
  final AppController controller;

  @override
  void paint(Canvas canvas, Size size) {
    final imageWidth = controller.detectionImageWidth;
    final imageHeight = controller.detectionImageHeight;
    if (imageWidth <= 0 || imageHeight <= 0) return;

    final scale = (size.width / imageWidth > size.height / imageHeight)
        ? size.width / imageWidth
        : size.height / imageHeight;
    final dx = (size.width - imageWidth * scale) / 2;
    final dy = (size.height - imageHeight * scale) / 2;
    final paint = Paint()
      ..color = secondary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final labelPaint = Paint()..color = secondary;
    final textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 11,
      fontWeight: FontWeight.w900,
    );

    for (final box
        in controller.detectionPredictions.where((box) => box.hasBox).take(5)) {
      final rect = Rect.fromCenter(
        center: Offset(dx + box.x * scale, dy + box.y * scale),
        width: box.width * scale,
        height: box.height * scale,
      );
      canvas.drawRect(rect, paint);

      final name = materials[box.categoryId]?.nameFor(controller.language) ??
          box.className;
      final text = '$name ${(box.confidence * 100).round()}%';
      final painter = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: size.width - 12);
      final labelRect = Rect.fromLTWH(
        rect.left.clamp(0, size.width - painter.width - 8),
        (rect.top - 24).clamp(0, size.height - 22),
        painter.width + 8,
        22,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(labelRect, const Radius.circular(6)),
        labelPaint,
      );
      painter.paint(canvas, labelRect.topLeft + const Offset(4, 3));
    }
  }

  @override
  bool shouldRepaint(covariant _DetectionBoxPainter oldDelegate) => true;
}

class PriceScreen extends StatelessWidget {
  const PriceScreen({required this.controller, super.key});
  final AppController controller;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ScreenHeading(
              title: controller.t('priceTitle'),
              subtitle: controller.t('priceSub')),
          const SizedBox(height: 14),
          AppCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(controller.material.icon,
                    style: const TextStyle(fontSize: 30)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(controller.t('selectedMaterial'),
                          style: Theme.of(context).textTheme.bodySmall),
                      Text(controller.material.nameFor(controller.language),
                          style: const TextStyle(
                              color: primary, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => controller.speak(controller.priceSpeech()),
                  tooltip: controller.t('listenPrice'),
                  icon: const Icon(Icons.volume_up_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            color: subtle,
            child: Column(
              children: [
                Text(controller.t('weight'),
                    style: const TextStyle(
                        color: textMuted, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Stepper(
                        icon: Icons.remove,
                        onTap: () =>
                            controller.setWeight(controller.weightKg - .5)),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 12),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: border)),
                      child: Text(
                          '${controller.weightKg.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w900)),
                    ),
                    _Stepper(
                        icon: Icons.add,
                        onTap: () =>
                            controller.setWeight(controller.weightKg + .5)),
                  ],
                ),
                Slider(
                  value: controller.weightKg.clamp(.1, 25).toDouble(),
                  min: .1,
                  max: 25,
                  divisions: 249,
                  label: '${controller.weightKg} kg',
                  onChanged: controller.setWeight,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0.1 kg', style: TextStyle(fontSize: 11)),
                    Text('10 kg', style: TextStyle(fontSize: 11)),
                    Text('25+ kg', style: TextStyle(fontSize: 11))
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFA7D7AA), width: 1.5),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x161B5E20),
                    blurRadius: 14,
                    offset: Offset(0, 5))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text('🏛️ ${controller.t('formalRate')}',
                            style: const TextStyle(
                                color: primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w900))),
                    Text(
                        '${controller.formatCurrency(controller.material.formalRate)} / kg',
                        style: const TextStyle(
                            color: textMuted, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(controller.t('fairEstimate'),
                              style: Theme.of(context).textTheme.bodySmall),
                          Text(controller.currencyFormal,
                              style: const TextStyle(
                                  color: primary,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(controller.t('informalPrice'),
                            style: const TextStyle(
                                fontSize: 11.5, color: textMuted)),
                        Text(
                            controller
                                .formatCurrency(controller.informalEstimate),
                            style: const TextStyle(
                                fontSize: 18,
                                color: textMuted,
                                decoration: TextDecoration.lineThrough,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(controller.t('extraValue'),
                              style: const TextStyle(
                                  color: Color(0xFF92400E),
                                  fontWeight: FontWeight.w800))),
                      Text(
                          '+${controller.formatCurrency(controller.potentialExtra)}',
                          style: const TextStyle(
                              color: Color(0xFFB45309),
                              fontSize: 19,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(controller.t('formalBenefit'),
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Center(child: Pill('ℹ️ ${controller.t('disclaimer')}')),
        ],
      );
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton.filled(
        onPressed: onTap,
        style: IconButton.styleFrom(
            backgroundColor: primary, foregroundColor: Colors.white),
        icon: Icon(icon),
      );
}
