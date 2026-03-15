import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poswork/features/balance/opening/opening_balance.dart';
import 'package:poswork/gen/colors.gen.dart';
import 'package:poswork/utils/utils.dart';

class BalanceInput extends StatelessWidget {
  const BalanceInput({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    final balance = context.select<OpeningBalanceBloc, num>(
      (value) => value.state.balance,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(
          color: ColorName.grayLight.withValues(alpha: 0.5),
        ),
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nominal Input (RP)',
            style: textTheme.titleLarge?.copyWith(
              color: ColorName.grayLight.withValues(alpha: 0.8),
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            spacing: 8,
            children: [
              Text(
                'Rp',
                style: textTheme.titleLarge?.copyWith(
                  color: ColorName.grayLight,
                  fontSize: 32,
                ),
              ),
              Text(
                balance.toCurrency,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 48,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
