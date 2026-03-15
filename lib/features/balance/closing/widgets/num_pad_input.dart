import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poswork/core/widgets/widgets.dart';
import 'package:poswork/features/balance/closing/closing.dart';

class NumPadInput extends StatelessWidget {
  const NumPadInput({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomNumberPad(
      horizontalSpacing: 4,
      isEnterButton: false,
      keyHeight: 40,
      backgroundColorEnterKey: Colors.white,
      onEnterPressed: () {
        context.read<ClosingBloc>().add(const BalanceCleared());
      },
      onDeletePressed: () {
        context.read<ClosingBloc>().add(const BalanceRemoved());
      },
      onNumberPressed: (value) {
        context.read<ClosingBloc>().add(BalanceChanged(value));
      },
    );
  }
}
