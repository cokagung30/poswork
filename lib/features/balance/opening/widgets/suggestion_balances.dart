import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poswork/features/balance/opening/opening_balance.dart';
import 'package:poswork/gen/colors.gen.dart';
import 'package:poswork/utils/utils.dart';

class SuggestionBalances extends StatelessWidget {
  const SuggestionBalances({super.key});

  @override
  Widget build(BuildContext context) {
    final suggestionValueSelect = context.select<OpeningBalanceBloc, num>(
      (value) => value.state.suggestionValueSelected,
    );

    return Row(
      spacing: 16,
      children: [50000, 100000, 500000, 1000000].map((value) {
        return Expanded(
          child: _SuggestionCard(
            value: value,
            isSelected: value == suggestionValueSelect,
          ),
        );
      }).toList(),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.value, this.isSelected = false});

  final num value;

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return InkWell(
      splashColor: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        context.read<OpeningBalanceBloc>().add(SuggestionSelected(value));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? ColorName.blue : ColorName.gray,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: isSelected ? ColorName.blueLight : ColorName.grayLight,
              blurRadius: 6,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        child: Column(
          spacing: 4,
          children: [
            Text(
              'Rp',
              style: textTheme.titleMedium?.copyWith(
                color: isSelected ? ColorName.blue : ColorName.grayLight,
              ),
            ),
            Text(
              value.toCurrency,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? ColorName.blue : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
