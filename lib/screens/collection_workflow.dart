import 'package:flutter/material.dart';

import '../data/ministry_data.dart';
import '../ministry_controller.dart';
import '../models/detection_result.dart';
import '../models/workflow_models.dart';
import '../widgets/common.dart' hide LabelValue;
import '../widgets/ministry_components.dart';

class CollectionModeScreen extends StatelessWidget {
  const CollectionModeScreen({required this.controller, super.key});
  final MinistryController controller;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PageHeading(controller.t('chooseMode'),
              'Batch collection is recommended for day-to-day work.'),
          const SizedBox(height: 16),
          _ChoiceCard(
            icon: Icons.collections_rounded,
            title: controller.t('batch'),
            subtitle: controller.t('batchSub'),
            badge: 'Recommended',
            onTap: () => controller.startCollection(CollectionMode.batch),
          ),
          const SizedBox(height: 10),
          _ChoiceCard(
            icon: Icons.center_focus_strong_rounded,
            title: controller.t('single'),
            subtitle: controller.t('singleSub'),
            onTap: () => controller.startCollection(CollectionMode.single),
          ),
        ],
      );
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap,
      this.badge});
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(children: [
              Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                      color: primaryLight,
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: primary, size: 30)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (badge != null)
                        Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: DemoLabel(text: badge!)),
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 18)),
                      Text(subtitle, style: const TextStyle(color: textMuted)),
                    ]),
              ),
              const Icon(Icons.chevron_right_rounded),
            ]),
          ),
        ),
      );
}

class CaptureBatchScreen extends StatelessWidget {
  const CaptureBatchScreen({required this.controller, super.key});
  final MinistryController controller;

  Future<void> _addManual(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: materialCatalog.values
              .map((item) => ListTile(
                    leading: Icon(materialIcon(item.icon), color: primary),
                    title: Text(item.name(controller.language)),
                    subtitle: Text(item.subcategory),
                    onTap: () => Navigator.pop(sheetContext, item.id),
                  ))
              .toList(),
        ),
      ),
    );
    if (selected != null) controller.addManualMaterial(selected);
  }

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PageHeading(
            controller.collectionMode == CollectionMode.batch
                ? controller.t('batch')
                : controller.t('single'),
            controller.collectionMode == CollectionMode.batch
                ? 'Add up to 8 compressed photos. Similar suggestions are grouped.'
                : 'Capture one item, then add its details.',
          ),
          const SizedBox(height: 12),
          if (controller.draftImages.isEmpty)
            Container(
              height: 170,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: border),
                  borderRadius: BorderRadius.circular(8)),
              child: const Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.add_photo_alternate_rounded,
                    size: 52, color: primary),
                SizedBox(height: 8),
                Text('Photos stay available for the local draft.',
                    style: TextStyle(color: textMuted)),
              ]),
            )
          else
            ...controller.draftImages.map((image) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _DetectionPhotoCard(
                    controller: controller,
                    image: image,
                    result: controller.detectionResults[image.id],
                  ),
                )),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: OutlinedButton.icon(
                    onPressed: controller.detecting &&
                            controller.collectionMode == CollectionMode.batch
                        ? null
                        : controller.addCameraPhoto,
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: Text(controller.t('camera')))),
            const SizedBox(width: 8),
            Expanded(
                child: OutlinedButton.icon(
                    onPressed: controller.detecting &&
                            controller.collectionMode == CollectionMode.batch
                        ? null
                        : controller.addGalleryPhotos,
                    icon: const Icon(Icons.photo_library_rounded),
                    label: Text(controller.t('gallery')))),
          ]),
          if (controller.detecting) ...[
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              label: controller.t('identifying'),
              child: Column(children: [
                const LinearProgressIndicator(),
                const SizedBox(height: 7),
                Text(controller.t('identifying')),
              ]),
            ),
          ],
          if (controller.detectionMessage.isNotEmpty) ...[
            const SizedBox(height: 8),
            InfoBand(
                icon: Icons.auto_awesome_rounded,
                title: controller.t('aiSuggestion'),
                body: controller.detectionMessage),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
              onPressed: () => _addManual(context),
              icon: const Icon(Icons.add_rounded),
              label: Text(controller.t('addMaterial'))),
          const SizedBox(height: 12),
          if (controller.draftMaterials.isNotEmpty)
            ...controller.draftMaterials.map((item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                      materialIcon(materialCatalog[item.materialId]!.icon),
                      color: primary),
                  title: Text(materialCatalog[item.materialId]!
                      .name(controller.language)),
                  trailing: Text('× ${item.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                )),
          const SizedBox(height: 16),
          PrimaryButton(
            label: controller.t('reviewMaterials'),
            icon: Icons.fact_check_rounded,
            onPressed: controller.draftMaterials.isEmpty || controller.detecting
                ? null
                : () => controller.go(WorkflowScreen.review),
          ),
          if (controller.lastError.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(controller.lastError,
                  style: const TextStyle(
                      color: danger, fontWeight: FontWeight.w700)),
            ),
        ],
      );
}

class _DetectionPhotoCard extends StatelessWidget {
  const _DetectionPhotoCard({
    required this.controller,
    required this.image,
    required this.result,
  });

  final MinistryController controller;
  final DraftImage image;
  final DetectionResult? result;

  @override
  Widget build(BuildContext context) {
    final suggestion = result?.categoryId == null
        ? null
        : materialCatalog[result!.categoryId!];
    final confidence = ((result?.confidence ?? 0) * 100).round();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 210,
          width: double.infinity,
          child: Stack(fit: StackFit.expand, children: [
            ColoredBox(
              color: const Color(0xFF17211C),
              child: Image.memory(image.bytes,
                  fit: BoxFit.contain, cacheWidth: 900),
            ),
            if (result != null && result!.predictions.any((box) => box.hasBox))
              IgnorePointer(
                child: CustomPaint(painter: _DetectionBoxPainter(result!)),
              ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (result == null)
              Text(controller.online
                  ? controller.t('identifying')
                  : controller.t('detectionUnavailable'))
            else if (suggestion != null) ...[
              DemoLabel(text: controller.t('aiSuggestion')),
              const SizedBox(height: 8),
              Text(
                '${suggestion.name(controller.language)} · $confidence%',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(confidence >= 70
                  ? controller.t('verifyAi')
                  : controller.t('lowConfidence')),
            ] else
              Text(controller.t('uncertainDetection'),
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(controller.t('detectionPrivacy'),
                style: const TextStyle(fontSize: 12, color: textMuted)),
            if (result != null) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: controller.detecting || !controller.online
                    ? null
                    : () => controller.retryDetection(image.id),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(controller.t('retryDetection')),
              ),
            ],
          ]),
        ),
      ]),
    );
  }
}

class _DetectionBoxPainter extends CustomPainter {
  const _DetectionBoxPainter(this.result);
  final DetectionResult result;

  @override
  void paint(Canvas canvas, Size size) {
    if (result.imageWidth <= 0 || result.imageHeight <= 0) return;
    final widthScale = size.width / result.imageWidth;
    final heightScale = size.height / result.imageHeight;
    final scale = widthScale < heightScale ? widthScale : heightScale;
    final drawnWidth = result.imageWidth * scale;
    final drawnHeight = result.imageHeight * scale;
    final dx = (size.width - drawnWidth) / 2;
    final dy = (size.height - drawnHeight) / 2;
    final paint = Paint()
      ..color = const Color(0xFFFFB547)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    for (final box in result.predictions.where((item) => item.hasBox).take(8)) {
      final left = dx + (box.x - box.width / 2) * scale;
      final top = dy + (box.y - box.height / 2) * scale;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, box.width * scale, box.height * scale),
          const Radius.circular(6),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DetectionBoxPainter oldDelegate) =>
      oldDelegate.result != result;
}

class MaterialReviewScreen extends StatelessWidget {
  const MaterialReviewScreen({required this.controller, super.key});
  final MinistryController controller;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PageHeading(controller.t('reviewMaterials'),
              'Confirm AI suggestions, quantity and material-wise weight.'),
          const SizedBox(height: 12),
          for (var index = 0;
              index < controller.draftMaterials.length;
              index++) ...[
            _MaterialEditor(controller: controller, index: index),
            const SizedBox(height: 10),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(children: [
                LabelValue(controller.t('totalWeight'),
                    '${controller.draftWeight.toStringAsFixed(2)} kg'),
                LabelValue(controller.t('estimatedValue'),
                    controller.money(controller.draftValue),
                    strong: true),
                const Divider(),
                Text(controller.t('referenceOnly'),
                    style: const TextStyle(fontSize: 12, color: textMuted)),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Collection location',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(controller.collectionLocation.label,
                      style: const TextStyle(color: textMuted)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.locating
                            ? null
                            : controller.requestLocation,
                        icon: const Icon(Icons.my_location_rounded),
                        label: Text(
                            controller.locating ? 'Locating...' : 'Use GPS'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.useDemoLocation,
                        icon: const Icon(Icons.science_outlined),
                        label: const Text('Demo location'),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
              label: controller.t('createLot'),
              icon: Icons.qr_code_2_rounded,
              onPressed: controller.canCreateLot ? controller.createLot : null),
          if (!controller.canCreateLot)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                  controller.draftMaterials.any((item) => item.weightKg <= 0)
                      ? 'Every material needs a weight greater than zero.'
                      : controller.t('safetyRequired'),
                  style: const TextStyle(
                      color: danger, fontWeight: FontWeight.w700)),
            ),
        ],
      );
}

class _MaterialEditor extends StatelessWidget {
  const _MaterialEditor({required this.controller, required this.index});
  final MinistryController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    final item = controller.draftMaterials[index];
    final definition = materialCatalog[item.materialId]!;
    final detectedDefinition = item.detectedMaterialId == null
        ? null
        : materialCatalog[item.detectedMaterialId!];
    final price = controller.valuation.priceFor(item.materialId);
    final lowConfidence =
        item.sourceType.startsWith('ai') && item.confidence < .65;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(materialIcon(definition.icon), color: primary, size: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(definition.name(controller.language),
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 17)),
                    Text(definition.subcategory,
                        style: const TextStyle(color: textMuted, fontSize: 12)),
                  ]),
            ),
            IconButton(
                tooltip: 'Remove material',
                onPressed: () => controller.removeMaterial(index),
                icon: const Icon(Icons.delete_outline_rounded, color: danger)),
          ]),
          if (item.sourceType.startsWith('ai'))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: DemoLabel(
                  text:
                      '${controller.t('aiSuggestion')}: ${detectedDefinition?.name(controller.language) ?? definition.name(controller.language)} • ${(item.confidence * 100).round()}%'),
            ),
          if (item.sourceType == 'manual_correction' &&
              detectedDefinition != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${controller.t('aiSuggestion')}: ${detectedDefinition.name(controller.language)} · ${controller.t('manual')}: ${definition.name(controller.language)}',
                style: const TextStyle(color: textMuted, fontSize: 12),
              ),
            ),
          if (lowConfidence)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(controller.t('lowConfidence'),
                  style: const TextStyle(
                      color: danger, fontWeight: FontWeight.w800)),
            ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: item.materialId,
            decoration: InputDecoration(
                labelText: controller.t('manual'), isDense: true),
            items: materialCatalog.values
                .map((value) => DropdownMenuItem(
                    value: value.id,
                    child: Text(value.name(controller.language),
                        maxLines: 1, overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (value) {
              if (value != null) controller.replaceMaterial(index, value);
            },
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: TextFormField(
                initialValue: '${item.quantity}',
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: controller.t('quantity'), isDense: true),
                onChanged: (value) => controller.updateMaterial(index,
                    quantity: int.tryParse(value)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: item.weightKg == 0 ? '' : '${item.weightKg}',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                    labelText: controller.t('weight'), isDense: true),
                onChanged: (value) => controller.updateMaterial(index,
                    weightKg: double.tryParse(value) ?? 0),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: item.condition,
            decoration: InputDecoration(
                labelText: controller.t('condition'), isDense: true),
            items: const ['mixed', 'intact', 'damaged', 'sorted']
                .map((value) =>
                    DropdownMenuItem(value: value, child: Text(value)))
                .toList(),
            onChanged: (value) =>
                controller.updateMaterial(index, condition: value),
          ),
          const SizedBox(height: 10),
          Text(
              '${controller.t('potentiallyRecoverable')}: ${definition.recoverableMaterials.join(', ')}',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          if (definition.hazardous)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SafetyNoticeCard(
                title: controller.t('${definition.id}WarningTitle'),
                body: controller.t('${definition.id}WarningBody'),
                instructions: controller.t('${definition.id}WarningSteps'),
                speakLabel: controller.t('speakSafety'),
                onSpeak: () => controller.speak(
                    safetyLines(controller.language, definition.id).join('. ')),
                acknowledgeLabel: controller.t('acknowledgeSafety'),
                acknowledgedLabel: controller.t('safetyAcknowledged'),
                acknowledged: controller.safetyAcknowledged(definition.id),
                onAcknowledge: () =>
                    controller.acknowledgeSafety(definition.id),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: InfoBand(
                icon: Icons.recycling_rounded,
                title: controller.t('valueRecoveryTip'),
                body: controller.t('valueTipBody'),
              ),
            ),
          const Divider(),
          LabelValue(
              'Reference rate', '${controller.money(price.buyingPrice)} / kg'),
          LabelValue(controller.t('estimatedValue'),
              controller.money(item.estimatedValue),
              strong: true),
        ]),
      ),
    );
  }
}
