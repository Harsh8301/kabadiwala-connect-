import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../app_controller.dart';
import '../data/app_data.dart';
import '../models/lot_record.dart';
import '../widgets/common.dart';

class LotScreen extends StatelessWidget {
  const LotScreen(
      {required this.controller, required this.showMessage, super.key});
  final AppController controller;
  final void Function(String) showMessage;

  Future<void> _pickWitness() async {
    final success =
        await controller.chooseImage(ImageSource.camera, witness: true);
    if (success) {
      showMessage(controller.t('photoAdded'));
    } else {
      showMessage('Camera unavailable or image selection cancelled.');
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ScreenHeading(
              title: controller.t('lotTitle'),
              subtitle: controller.t('lotSub')),
          const SizedBox(height: 14),
          AppCard(
            borderColor: const Color(0xFFA7D7AA),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(controller.lotId,
                            style: const TextStyle(
                                color: secondary,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w900))),
                    Pill(controller.t('awaiting'),
                        color: const Color(0xFFFEF3C7),
                        textColor: const Color(0xFF92400E)),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(10),
                  child: QrImageView(
                    data: controller.lotPayloadJson,
                    version: QrVersions.auto,
                    size: 160,
                    eyeStyle: const QrEyeStyle(
                        color: primary, eyeShape: QrEyeShape.square),
                    dataModuleStyle: const QrDataModuleStyle(
                        color: textMain,
                        dataModuleShape: QrDataModuleShape.square),
                  ),
                ),
                const Divider(height: 26),
                LabelValue(
                    label: '${controller.t('material')}:',
                    value: controller.material.nameFor(controller.language)),
                LabelValue(
                    label: '${controller.t('totalWeight')}:',
                    value: '${controller.weightKg.toStringAsFixed(1)} kg'),
                LabelValue(
                    label: '${controller.t('expectedValue')}:',
                    value: controller.currencyFormal,
                    highlight: true),
                LabelValue(
                    label: '${controller.t('gps')}:',
                    value: controller.locationStatus == 'unavailable'
                        ? controller.t('locationUnavailable')
                        : controller.collectionLocationLabel),
                if (controller.isLocating)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(),
                  ),
                const SizedBox(height: 8),
                Text(controller.t('traceNotice'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text('📸 ${controller.t('witness')}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w800))),
                    Pill(controller.t('optional')),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 140,
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                      color: subtle,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: border)),
                  child: controller.witnessImage != null
                      ? Image.memory(controller.witnessImage!,
                          fit: BoxFit.cover)
                      : controller.sampleWitness
                          ? const _SampleWitness()
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('🤳',
                                    style: TextStyle(fontSize: 38)),
                                Text(controller.t('witnessPrompt'),
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Expanded(
                        child: SecondaryButton(
                            label: controller.t('takePhoto'),
                            icon: Icons.camera_alt_rounded,
                            onPressed: _pickWitness)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SecondaryButton(
                        label: controller.t('samplePhoto'),
                        icon: Icons.auto_awesome_rounded,
                        onPressed: () {
                          controller.useSampleWitness();
                          showMessage(controller.t('photoAdded'));
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(controller.t('faceNotice'),
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      );
}

class RecyclerMatchScreen extends StatelessWidget {
  const RecyclerMatchScreen({required this.controller, super.key});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final matches = controller.recyclerMatches();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ScreenHeading(
          title: controller.t('matchTitle'),
          subtitle:
              '${controller.material.nameFor(controller.language)} • ${controller.collectionLocationLabel}',
        ),
        const SizedBox(height: 12),
        ...matches.map((recycler) {
          final km = controller.distanceToRecycler(recycler);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              borderColor: recycler.recyclerId == controller.selectedRecyclerId
                  ? primary
                  : border,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(recycler.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w900)),
                      ),
                      Pill('${km.toStringAsFixed(0)} km'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(recycler.location.address,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 6),
                  Pill('Authorized status: ${recycler.authorizationStatus}',
                      color: const Color(0xFFFEF3C7),
                      textColor: const Color(0xFF92400E)),
                  const SizedBox(height: 8),
                  Text(recycler.authorizationDetails,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Text(recycler.materialsAccepted.join(', '),
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    label: controller.t('confirmRecycler'),
                    icon: Icons.local_shipping_rounded,
                    onPressed: () {
                      controller.chooseRecycler(recycler.recyclerId);
                      controller.goTo(AppScreen.payment);
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({required this.controller, super.key});
  final AppController controller;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ScreenHeading(
            title: controller.t('paymentTitle'),
            subtitle: controller.selectedRecycler?.name ?? '',
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('💰 ${controller.t('payment')}',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 9),
                _PaymentOption(
                  selected: controller.paymentMethod == 'cash',
                  title: '💵 ${controller.t('cash')}',
                  subtitle: controller.t('cashSub'),
                  emphasized: true,
                  onTap: () => controller.setPayment('cash'),
                ),
                const SizedBox(height: 8),
                _PaymentOption(
                  selected: controller.paymentMethod == 'upi',
                  title: '📱 ${controller.t('upi')}',
                  subtitle: controller.t('upiSub'),
                  emphasized: false,
                  onTap: () => controller.setPayment('upi'),
                ),
                const SizedBox(height: 8),
                Text(controller.t('paymentNotice'),
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      );
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption(
      {required this.selected,
      required this.title,
      required this.subtitle,
      required this.onTap,
      this.emphasized = false});
  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.all(emphasized ? 15 : 10),
          decoration: BoxDecoration(
            color: selected ? primaryLight : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selected ? primary : border, width: selected ? 2 : 1),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? primary : textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: selected ? primary : textMain,
                            fontSize: emphasized ? 16 : 13,
                            fontWeight: FontWeight.w800)),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _SampleWitness extends StatelessWidget {
  const _SampleWitness();
  @override
  Widget build(BuildContext context) => Container(
        color: const Color(0xFF0F766E),
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🙂', style: TextStyle(fontSize: 46)),
            SizedBox(height: 5),
            Pill('✓ Handover Verified',
                color: Colors.white, textColor: Color(0xFF0F766E)),
          ],
        ),
      );
}

class LedgerScreen extends StatelessWidget {
  const LedgerScreen(
      {required this.controller, required this.onShowQr, super.key});
  final AppController controller;
  final void Function(LotRecord) onShowQr;

  @override
  Widget build(BuildContext context) {
    final totalWeight =
        controller.ledger.fold<double>(0, (sum, item) => sum + item.weightKg);
    final paidValue = controller.ledger
        .where((item) => item.paymentStatus == 'Paid')
        .fold<int>(0, (sum, item) => sum + item.formalPrice);
    final pendingValue = controller.ledger
        .where((item) => item.paymentStatus != 'Paid')
        .fold<int>(0, (sum, item) => sum + item.formalPrice);
    final latest = controller.ledger.isEmpty ? null : controller.ledger.last;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Center(
          child: CircleAvatar(
              radius: 34,
              backgroundColor: primary,
              child: Icon(Icons.check_rounded, color: Colors.white, size: 42)),
        ),
        const SizedBox(height: 10),
        Text(controller.t('success'),
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: primary, fontSize: 23, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(controller.t('successSub'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall),
        if (latest != null) ...[
          const SizedBox(height: 14),
          AppCard(
            color: const Color(0xFFECFDF5),
            borderColor: const Color(0xFFA7F3D0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text('🌱 ${controller.t('impact')}',
                            style: const TextStyle(
                                color: primary, fontWeight: FontWeight.w900))),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(11)),
                  child: Text(controller.impactFor(latest),
                      style: const TextStyle(
                          color: primary, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 8),
                Text(controller.t('environment'),
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
                child: Text('📋 ${controller.t('ledger')}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w900))),
            Pill(
                '${controller.ledger.length} ${controller.language == 'mr' ? 'लॉट' : 'lots'}'),
          ],
        ),
        const SizedBox(height: 8),
        AppCard(
          color: subtle,
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              Expanded(
                  child: _Total(
                      label: controller.t('totalWeight'),
                      value: '${totalWeight.toStringAsFixed(1)} kg')),
              Expanded(
                  child: _Total(
                      label: controller.t('paid'),
                      value: controller.formatCurrency(paidValue),
                      highlight: true)),
              Expanded(
                  child: _Total(
                      label: controller.t('pending'),
                      value: controller.formatCurrency(pendingValue))),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...controller.ledger.reversed.map((record) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(record.lotId,
                              style: const TextStyle(
                                  color: secondary,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w900)),
                          Text(
                              '${materials[record.category]!.nameFor(controller.language)} • ${record.weightKg} kg',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                          Text(
                              '${record.timeLabel} • ${record.paymentMethod == 'cash' ? '💵 Cash' : '📱 UPI'}',
                              style: Theme.of(context).textTheme.bodySmall),
                          Text(
                              '${record.transactionStatus} • ${record.recyclerName}',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Pill(
                          record.paymentStatus,
                          color: record.paymentStatus == 'Paid'
                              ? primaryLight
                              : const Color(0xFFFEF3C7),
                          textColor: record.paymentStatus == 'Paid'
                              ? primary
                              : const Color(0xFF92400E),
                        ),
                        Text(controller.formatCurrency(record.formalPrice),
                            style: const TextStyle(
                                color: primary,
                                fontSize: 18,
                                fontWeight: FontWeight.w900)),
                        TextButton.icon(
                            onPressed: () => onShowQr(record),
                            icon: const Icon(Icons.qr_code_2, size: 17),
                            label: Text(controller.t('qrView'))),
                      ],
                    ),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 6),
        PrimaryButton(
            label: controller.t('another'),
            icon: Icons.refresh_rounded,
            onPressed: controller.startAnother),
        const SizedBox(height: 8),
        SecondaryButton(
            label: controller.t('home'),
            icon: Icons.home_rounded,
            onPressed: () => controller.goTo(AppScreen.welcome)),
        const SizedBox(height: 8),
        SecondaryButton(
            label: controller.t('recyclerView'),
            icon: Icons.verified_rounded,
            onPressed: () => controller.goTo(AppScreen.recyclerView)),
      ],
    );
  }
}

class RecyclerViewScreen extends StatelessWidget {
  const RecyclerViewScreen({required this.controller, super.key});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final pending = controller.ledger
        .where((record) => record.transactionStatus != 'completed')
        .toList()
        .reversed;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ScreenHeading(
          title: controller.t('recyclerView'),
          subtitle: controller.t('confirmHandover'),
        ),
        const SizedBox(height: 12),
        ...pending.map((record) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: record.scrapImageBase64 == null
                          ? MaterialPreview(
                              category: record.category,
                              height: 64,
                            )
                          : Image.memory(
                              base64Decode(record.scrapImageBase64!),
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(materials[record.category]!
                              .nameFor(controller.language)),
                          Text(
                            '${record.weightKg} kg • ${controller.formatCurrency(record.formalPrice)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(record.lotId,
                              style: const TextStyle(
                                  color: secondary,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: () =>
                          controller.confirmRecyclerReceipt(record.lotId),
                      child: Text(controller.t('receipt')),
                    ),
                  ],
                ),
              ),
            )),
        if (pending.isEmpty)
          AppCard(child: Center(child: Text(controller.t('noPendingLots')))),
        const SizedBox(height: 8),
        SecondaryButton(
          label: controller.t('collectorView'),
          icon: Icons.person_rounded,
          onPressed: () => controller.goTo(AppScreen.ledger),
        ),
      ],
    );
  }
}

class _Total extends StatelessWidget {
  const _Total(
      {required this.label, required this.value, this.highlight = false});
  final String label;
  final String value;
  final bool highlight;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value,
              style: TextStyle(
                  color: highlight ? primary : textMain,
                  fontSize: 18,
                  fontWeight: FontWeight.w900)),
        ],
      );
}
