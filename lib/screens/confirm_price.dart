import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../data/app_data.dart';
import '../widgets/common.dart';

class ConfirmScreen extends StatelessWidget {
  const ConfirmScreen({required this.controller, super.key});
  final AppController controller;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ScreenHeading(title: controller.t('confirmTitle'), subtitle: controller.t('confirmSub')),
          const SizedBox(height: 14),
          AppCard(
            color: const Color(0xFFECFDF5),
            borderColor: const Color(0xFFA7F3D0),
            child: Row(
              children: [
                SizedBox(
                  width: 62,
                  height: 62,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: controller.capturedImage == null
                        ? MaterialPreview(category: controller.detectedCategory, height: 62)
                        : Image.memory(controller.capturedImage!, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        children: [
                          Pill(controller.t('suggestion'), color: primary, textColor: Colors.white),
                          const Pill('89%', color: primaryLight, textColor: primary),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(controller.material.nameFor(controller.language), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(controller.t('selectCorrect'), style: const TextStyle(color: textMuted, fontWeight: FontWeight.w700)),
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
                      color: selected ? primary : item.isHazardous ? const Color(0xFFFCA5A5) : border,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item.icon, style: const TextStyle(fontSize: 34)),
                      const SizedBox(height: 5),
                      Text(item.nameFor(controller.language), textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
                      if (item.isHazardous) ...[
                        const SizedBox(height: 5),
                        Pill('⚠️ ${controller.t('hazardous')}', color: const Color(0xFFFEE2E2), textColor: danger),
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

class PriceScreen extends StatelessWidget {
  const PriceScreen({required this.controller, super.key});
  final AppController controller;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ScreenHeading(title: controller.t('priceTitle'), subtitle: controller.t('priceSub')),
          const SizedBox(height: 14),
          AppCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(controller.material.icon, style: const TextStyle(fontSize: 30)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(controller.t('selectedMaterial'), style: Theme.of(context).textTheme.bodySmall),
                      Text(controller.material.nameFor(controller.language), style: const TextStyle(color: primary, fontWeight: FontWeight.w900)),
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
                Text(controller.t('weight'), style: const TextStyle(color: textMuted, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Stepper(icon: Icons.remove, onTap: () => controller.setWeight(controller.weightKg - .5)),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
                      child: Text('${controller.weightKg.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
                    ),
                    _Stepper(icon: Icons.add, onTap: () => controller.setWeight(controller.weightKg + .5)),
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
                  children: [Text('0.1 kg', style: TextStyle(fontSize: 11)), Text('10 kg', style: TextStyle(fontSize: 11)), Text('25+ kg', style: TextStyle(fontSize: 11))],
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
              boxShadow: const [BoxShadow(color: Color(0x161B5E20), blurRadius: 14, offset: Offset(0, 5))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('🏛️ ${controller.t('formalRate')}', style: const TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w900))),
                    Text('${controller.formatCurrency(controller.material.formalRate)} / kg', style: const TextStyle(color: textMuted, fontWeight: FontWeight.w700)),
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
                          Text(controller.t('fairEstimate'), style: Theme.of(context).textTheme.bodySmall),
                          Text(controller.currencyFormal, style: const TextStyle(color: primary, fontSize: 34, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(controller.t('informalPrice'), style: const TextStyle(fontSize: 11.5, color: textMuted)),
                        Text(controller.formatCurrency(controller.informalEstimate), style: const TextStyle(fontSize: 18, color: textMuted, decoration: TextDecoration.lineThrough, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Expanded(child: Text(controller.t('extraValue'), style: const TextStyle(color: Color(0xFF92400E), fontWeight: FontWeight.w800))),
                      Text('+${controller.formatCurrency(controller.potentialExtra)}', style: const TextStyle(color: Color(0xFFB45309), fontSize: 19, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(controller.t('formalBenefit'), style: Theme.of(context).textTheme.bodySmall),
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
        style: IconButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white),
        icon: Icon(icon),
      );
}
