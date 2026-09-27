import 'package:flutter/material.dart';
import '../ministry_controller.dart';
import '../widgets/common.dart';
import '../widgets/ministry_components.dart';

class UnitEconomicsScreen extends StatelessWidget {
  const UnitEconomicsScreen({required this.controller, super.key});
  final MinistryController controller;

  @override
  Widget build(BuildContext context) {
    // These numbers would ideally come from the DatasetService or active transaction data.
    // For demonstration, we use realistic modeled metrics for a typical collector's monthly operation.
    const double currentEarnings = 12000.0;
    const double platformEarnings = 15800.0;
    
    // Breakdown for Current Route
    const double currentGross = 16000.0;
    const double currentTransport = 1500.0;
    const double currentMiddlemanDeductions = 2500.0;
    
    // Breakdown for Platform Route
    const double platformGross = 17000.0; // Slightly better market matching
    const double platformTransport = 800.0; // Optimized logistics
    const double platformFee = 400.0; // Platform transaction/SaaS fee (if applicable)

    return Scaffold(
      appBar: AppBar(
        title: Text(controller.t('unitEconomicsTitle'), style: const TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        foregroundColor: primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PageHeading(controller.t('impactAnalysis'), controller.t('impactAnalysisSub')),
          const SizedBox(height: 16),
          _RouteCard(
            controller: controller,
            title: controller.t('currentRoute'),
            gross: currentGross,
            deductions: [
              _Deduction(controller.t('transport'), currentTransport),
              _Deduction(controller.t('middlemanMargin'), currentMiddlemanDeductions),
            ],
            net: currentEarnings,
            color: saffronLight,
            accent: saffronDark,
          ),
          const SizedBox(height: 16),
          _RouteCard(
            controller: controller,
            title: controller.t('platformRoute'),
            gross: platformGross,
            deductions: [
              _Deduction(controller.t('optimizedTransport'), platformTransport),
              _Deduction(controller.t('platformServiceFee'), platformFee),
            ],
            net: platformEarnings,
            color: primaryLight,
            accent: primary,
            highlight: true,
          ),
          const SizedBox(height: 24),
          Text(controller.t('platformSustainability'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(
            controller.t('sustainabilityBody'),
            style: const TextStyle(color: textMuted, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _Deduction {
  const _Deduction(this.label, this.amount);
  final String label;
  final double amount;
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.controller,
    required this.title,
    required this.gross,
    required this.deductions,
    required this.net,
    required this.color,
    required this.accent,
    this.highlight = false,
  });

  final MinistryController controller;
  final String title;
  final double gross;
  final List<_Deduction> deductions;
  final double net;
  final Color color;
  final Color accent;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: highlight ? const BorderSide(color: primary, width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: accent)),
            const Divider(height: 24),
            _LineItem(controller.t('grossSaleValue'), gross, isBold: true),
            const SizedBox(height: 8),
            ...deductions.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _LineItem('- ${d.label}', -d.amount, color: danger),
            )),
            const Divider(height: 24),
            _LineItem(controller.t('netEarnings'), net, isBold: true, color: accent, size: 20),
          ],
        ),
      ),
    );
  }
}

class _LineItem extends StatelessWidget {
  const _LineItem(this.label, this.amount, {this.isBold = false, this.color, this.size});
  final String label;
  final double amount;
  final bool isBold;
  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.w800 : FontWeight.w500, fontSize: size, color: color)),
        Text('₹${amount.abs().toStringAsFixed(0)}', style: TextStyle(fontWeight: isBold ? FontWeight.w800 : FontWeight.w600, fontSize: size, color: color)),
      ],
    );
  }
}
