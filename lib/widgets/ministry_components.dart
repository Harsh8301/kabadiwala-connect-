import 'package:flutter/material.dart';

import '../models/workflow_models.dart';
import 'common.dart';

class PageHeading extends StatelessWidget {
  const PageHeading(this.title, this.subtitle, {super.key});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: textMuted)),
        ],
      );
}

class MetricTile extends StatelessWidget {
  const MetricTile(
      {required this.label,
      required this.value,
      required this.icon,
      super.key});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 94),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primary, size: 21),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w900)),
            ),
            Text(label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 11,
                    color: textMuted,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

class InfoBand extends StatelessWidget {
  const InfoBand(
      {required this.icon,
      required this.title,
      required this.body,
      this.dangerStyle = false,
      super.key});
  final IconData icon;
  final String title;
  final String body;
  final bool dangerStyle;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: dangerStyle ? const Color(0xFFFFF1F2) : primaryLight,
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: dangerStyle ? danger : const Color(0xFFB7CCB8)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: dangerStyle ? danger : primary),
          const SizedBox(width: 8),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 2),
              Text(body),
            ]),
          ),
        ]),
      );
}

class DemoLabel extends StatelessWidget {
  const DemoLabel({required this.text, super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7E6),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFF2C66D)),
        ),
        child: Text(text,
            style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF7A4B00),
                fontWeight: FontWeight.w800)),
      );
}

class LabelValue extends StatelessWidget {
  const LabelValue(this.label, this.value, {this.strong = false, super.key});
  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Text(label, style: const TextStyle(color: textMuted))),
          const SizedBox(width: 10),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: strong ? primary : textMain)),
          ),
        ]),
      );
}

class EmptyState extends StatelessWidget {
  const EmptyState({required this.icon, required this.text, super.key});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(30),
        child: Column(children: [
          Icon(icon, size: 48, color: textMuted),
          const SizedBox(height: 8),
          Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: textMuted)),
        ]),
      );
}

class SafetyNoticeCard extends StatelessWidget {
  const SafetyNoticeCard({
    required this.title,
    required this.body,
    required this.instructions,
    required this.speakLabel,
    required this.onSpeak,
    super.key,
    this.acknowledgeLabel,
    this.acknowledgedLabel,
    this.acknowledged = false,
    this.onAcknowledge,
  });

  final String title;
  final String body;
  final String instructions;
  final String speakLabel;
  final VoidCallback onSpeak;
  final String? acknowledgeLabel;
  final String? acknowledgedLabel;
  final bool acknowledged;
  final VoidCallback? onAcknowledge;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4E5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE58A2B), width: 1.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE1DC),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: danger, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Color(0xFF8F241B),
                            fontSize: 17,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 5),
                    Text(body,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ]),
            ),
          ]),
          const SizedBox(height: 10),
          Text(instructions),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: onSpeak,
            icon: const Icon(Icons.volume_up_rounded),
            label: Text(speakLabel),
          ),
          if (onAcknowledge != null) ...[
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: acknowledged
                  ? Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(children: [
                        const Icon(Icons.check_circle_rounded, color: primary),
                        const SizedBox(width: 8),
                        Expanded(child: Text(acknowledgedLabel ?? '')),
                      ]),
                    )
                  : FilledButton.icon(
                      onPressed: onAcknowledge,
                      style: FilledButton.styleFrom(backgroundColor: danger),
                      icon: const Icon(Icons.verified_user_rounded),
                      label: Text(acknowledgeLabel ?? ''),
                    ),
            ),
          ],
        ]),
      );
}

IconData materialIcon(IconSeed seed) => switch (seed) {
      IconSeed.memory => Icons.memory_rounded,
      IconSeed.cable => Icons.cable_rounded,
      IconSeed.battery => Icons.battery_charging_full_rounded,
      IconSeed.television => Icons.tv_rounded,
      IconSeed.display => Icons.monitor_rounded,
      IconSeed.motor => Icons.settings_rounded,
      IconSeed.magnet => Icons.blur_circular_rounded,
      IconSeed.plastic => Icons.recycling_rounded,
    };

String shortDate(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

String dateTimeLabel(DateTime value) =>
    '${shortDate(value)} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

String statusLabel(LotStatus value) => value.name
    .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
    .trim();
