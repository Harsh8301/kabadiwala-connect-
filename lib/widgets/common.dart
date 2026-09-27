import 'package:flutter/material.dart';


const primary = Color(0xFF37474F);
const primaryDark = Color(0xFF263238);
const primaryLight = Color(0xFFECEFF1);
const secondary = Color(0xFFF4A300);
const saffron = Color(0xFFF4A300);
const saffronLight = Color(0xFFFEF3D6);
const saffronDark = Color(0xFFC97D00);
const accent = Color(0xFFA63A22);
const accentLight = Color(0xFFFCEBE6);
const accentBorder = Color(0xFFEDB6AA);
const copper = Color(0xFFF4A300);
const warning = Color(0xFFF4A300);
const danger = Color(0xFFA63A22);
const canvas = Color(0xFFECEFF1);
const appBackground = Color(0xFFFAF8F5);
const subtle = Color(0xFFECEFF1);
const textMain = Color(0xFF263238);
const textMuted = Color(0xFF607D8B);
const border = Color(0xFFCFD8DC);

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
      appBarTheme: const AppBarTheme(
        backgroundColor: appBackground,
        foregroundColor: primary,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
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
          borderRadius: BorderRadius.circular(14),
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
            side: const BorderSide(color: border),
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
  const Pill(this.text,
      {super.key, this.color = subtle, this.textColor = textMuted});

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
          style: TextStyle(
              fontSize: 11.5, color: textColor, fontWeight: FontWeight.w600),
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
      'battery' => ('🔋', primaryDark, accent),
      'cables' => ('🔌', primaryDark, secondary),
      'motor' => ('⚙️', primary, const Color(0xFF546E7A)),
      'crt' => ('📺', primaryDark, primary),
      'mixed' => ('📦', primaryDark, secondary),
      'other' => ('❓', primary, const Color(0xFF78909C)),
      _ => ('🖧', primaryDark, secondary),
    };
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [data.$2, data.$3.withValues(alpha: .78)],
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
  const LabelValue(
      {required this.label,
      required this.value,
      super.key,
      this.highlight = false});
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
                child: Text(label, style: const TextStyle(color: textMuted))),
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
