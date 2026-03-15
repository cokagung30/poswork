import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poswork/features/balance/closing/closing.dart';
import 'package:poswork/gen/colors.gen.dart';
import 'package:poswork/utils/utils.dart';

class ClosingValueField extends StatelessWidget {
  const ClosingValueField({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    final closingBalance = context.select<ClosingBloc, num?>(
      (value) => value.state.closingBalance,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: ColorName.grayLight),
        color: ColorName.blueSurface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        spacing: 12,
        children: [
          Text(
            'Rp',
            style: textTheme.bodyMedium?.copyWith(
              color: ColorName.grayLight,
              fontSize: 16,
            ),
          ),
          Text(
            (closingBalance ?? 0).toCurrency,
            style: textTheme.titleLarge?.copyWith(
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }
}
