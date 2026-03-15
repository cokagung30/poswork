import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poswork/core/widgets/widgets.dart';
import 'package:poswork/features/balance/closing/closing.dart';
import 'package:poswork/gen/assets.gen.dart';
import 'package:poswork/gen/colors.gen.dart';
import 'package:poswork/utils/utils.dart';

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    final validateStatus = context.select<ClosingBloc, BalanceValidationStatus>(
      (value) => value.state.status,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: AppButton.elevated(
        width: double.infinity,
        label: 'Konfirmasi & Tutup Kasir',
        leadingIcon: Assets.icons.icPrint.svg(
          width: 36,
          height: 36,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        backgroundColor: ColorName.green,
        textStyle: textTheme.titleLarge?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        onTap: (validateStatus == BalanceValidationStatus.initial)
            ? null
            : () {
                final bloc = context.read<ClosingBloc>();
                final state = bloc.state;

                final closingBalance = state.closingBalance;
                final totalCash = state.totalCash;

                showConfirmClosingDialog(
                  context,
                  closingBalance: closingBalance ?? 0,
                  totalCash: totalCash,
                  onSubmitTap: () => bloc.add(const ClosingSubmitted()),
                );
              },
      ),
    );
  }
}
