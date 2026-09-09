import 'package:flutter/material.dart';

import '../data/app_data.dart';

const primary = Color(brandGreen);
const primaryDark = Color(brandGreenDark);
const primaryLight = Color(brandGreenLight);
const secondary = Color(traceBlue);
const warning = Color(amber);
const danger = Color(hazardRed);
const canvas = Color(0xFFEDEFEA);
const appBackground = Color(0xFFF7F9F6);
const subtle = Color(0xFFF1F4F0);
const textMain = Color(0xFF1F2937);
const textMuted = Color(0xFF4B5563);
const border = Color(0xFFE5E7EB);

ThemeData buildTheme() => ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: appBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        error: danger,
        surface: Colors.white,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 22,
          height: 1.15,
          fontWeight: FontWeight.w800,
          color: textMain,
        ),
        titleLarge: TextStyle(fontWeight: FontWeight.w800, color: textMain),
        titleMedium: TextStyle(fontWeight: FontWeight.w700, color: textMain),
        bodyMedium: TextStyle(fontSize: 15, height: 1.4, color: textMain),
        bodySmall: TextStyle(fontSize: 13, height: 1.35, color: textMuted),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
      ),
    );

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.color = Colors.white,
    this.borderColor = border,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: child,
      );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.color = primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton.icon(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
          icon: icon == null ? const SizedBox.shrink() : Icon(icon),
          label: Text(label, textAlign: TextAlign.center),
        ),
      );
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 48,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: Color(0xFFB7CCB8)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
          icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 20),
          label: Text(label),
        ),
      );
}

class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.color = subtle, this.textColor = textMuted});

  final String text;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 11.5, color: textColor, fontWeight: FontWeight.w600),
        ),
      );
}

class ScreenHeading extends StatelessWidget {
  const ScreenHeading({required this.title, required this.subtitle, super.key});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ],
      );
}

class MaterialPreview extends StatelessWidget {
  const MaterialPreview({required this.category, super.key, this.height = 180});
  final String category;
  final double height;

  @override
  Widget build(BuildContext context) {
    final data = switch (category) {
      'battery' => ('🔋', const Color(0xFF18181B), const Color(0xFFDC2626)),
      'cables' => ('🔌', const Color(0xFF1E293B), const Color(0xFFEA580C)),
      'motor' => ('⚙️', const Color(0xFF334155), const Color(0xFF0284C7)),
      'crt' => ('📺', const Color(0xFF312E81), const Color(0xFF818CF8)),
      'mixed' => ('📦', const Color(0xFF374151), const Color(0xFFD97706)),
      'other' => ('❓', const Color(0xFF475569), const Color(0xFFCBD5E1)),
      _ => ('🖧', const Color(0xFF064E3B), const Color(0xFF10B981)),
    };
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [data.$2, data.$3.withOpacity(.78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(data.$1, style: TextStyle(fontSize: height * .38)),
    );
  }
}

class LabelValue extends StatelessWidget {
  const LabelValue({required this.label, required this.value, super.key, this.highlight = false});
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(color: textMuted))),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: highlight ? primary : textMain,
                fontSize: highlight ? 16 : 14,
              ),
            ),
          ],
        ),
      );
}
