import 'package:flutter/material.dart';
import 'package:poswork/gen/colors.gen.dart';
import 'package:poswork/utils/utils.dart';

class NetIncomeCard extends StatelessWidget {
  const NetIncomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xffECEFF5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorName.blueSurface),
      ),
      child: Column(
        spacing: 4,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Pendapatan Bersih',
            style: textTheme.bodySmall?.copyWith(color: ColorName.blue),
          ),
          Text(
            'Rp ${500000.toCurrency}',
            style: textTheme.titleLarge?.copyWith(fontSize: 24),
          ),
        ],
      ),
    );
  }
}
