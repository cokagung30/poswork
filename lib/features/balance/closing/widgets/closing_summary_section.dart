import 'package:flutter/material.dart';
import 'package:poswork/gen/colors.gen.dart';
import 'package:poswork/utils/utils.dart';

class ClosingSummarySection extends StatelessWidget {
  const ClosingSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      children: [
        _SummaryCard(label: 'Saldo Awal', value: 'Rp ${500000.toCurrency}'),
        const _SummaryCard(label: 'Durasi Buka', value: '8j 16m'),
        _SummaryCard(label: 'Total Tunai', value: 'Rp ${500000.toCurrency}'),
        _SummaryCard(label: 'Total QRIS', value: 'Rp ${500000.toCurrency}'),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
  });

  final String label;

  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: ColorName.grayLight.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(color: ColorName.gray),
            ),
            Text(
              value,
              style: textTheme.bodyLarge?.copyWith(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
