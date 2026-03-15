import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poswork/core/widgets/custom_number_pad.dart';
import 'package:poswork/features/balance/opening/opening_balance.dart';

class NumPadInput extends StatelessWidget {
  const NumPadInput({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomNumberPad(
      horizontalSpacing: 0,
      verticalSpacing: 10,
      isEnterButton: false,
      onDeletePressed: () {
        context.read<OpeningBalanceBloc>().add(const BalanceRemoved());
      },
      onEnterPressed: () {
        context.read<OpeningBalanceBloc>().add(const BalanceCleared());
      },
      onNumberPressed: (value) {
        context.read<OpeningBalanceBloc>().add(BalanceChanged(value));
      },
    );
  }
}
