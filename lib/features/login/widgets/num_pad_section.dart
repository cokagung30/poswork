import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:poswork/core/router/app_router.dart';
import 'package:poswork/core/widgets/widgets.dart';
import 'package:poswork/features/login/login.dart';

class NumPadSection extends StatelessWidget {
  const NumPadSection({super.key});

  @override
  Widget build(BuildContext context) {
    final pin = context.select<LoginBloc, String>((value) => value.state.pin);

    return CustomNumberPad(
      onNumberPressed: (value) {
        final event = PinChanged(value);
        context.read<LoginBloc>().add(event);
      },
      onDeletePressed: () {
        context.read<LoginBloc>().add(const PinRemoved());
      },
      onEnterPressed: (pin.length < 4)
          ? null
          : () {
              context.goNamed(AppRouterName.openingBalance);
            },
    );
  }
}
