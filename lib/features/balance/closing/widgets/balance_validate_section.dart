import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poswork/features/balance/closing/closing.dart';
import 'package:poswork/gen/assets.gen.dart';
import 'package:poswork/gen/colors.gen.dart';
import 'package:poswork/utils/utils.dart';

class BalanceValidateSection extends StatelessWidget {
  const BalanceValidateSection({super.key});

  @override
  Widget build(BuildContext context) {
    final validateStatus = context.select<ClosingBloc, BalanceValidationStatus>(
      (value) => value.state.status,
    );

    final balanceDiff = context.select<ClosingBloc, num?>(
      (value) => value.state.balanceDiff,
    );

    return _CardContainer(type: validateStatus, value: balanceDiff);
  }
}

class _CardContainer extends StatelessWidget {
  const _CardContainer({required this.type, required this.value});

  final BalanceValidationStatus type;
  final num? value;

  Color get titleColor {
    return switch (type) {
      BalanceValidationStatus.initial => ColorName.grayLight,
      BalanceValidationStatus.valid => const Color(0xff009800),
      BalanceValidationStatus.invalid => const Color(0xffDC2424),
    };
  }

  Color get backgroundColor {
    return switch (type) {
      BalanceValidationStatus.initial => ColorName.whiteSurface,
      BalanceValidationStatus.valid => ColorName.greenSurface,
      BalanceValidationStatus.invalid => const Color(0xffFEF2F2),
    };
  }

  Color get borderColor {
    return switch (type) {
      BalanceValidationStatus.initial => ColorName.grayLight,
      BalanceValidationStatus.valid => ColorName.greenLight,
      BalanceValidationStatus.invalid => const Color(0xffFEE8E8),
    };
  }

  Color get valueTextColor {
    return switch (type) {
      BalanceValidationStatus.initial => ColorName.gray,
      BalanceValidationStatus.valid => ColorName.green,
      BalanceValidationStatus.invalid => ColorName.red,
    };
  }

  String get suffixText {
    return switch (type) {
      BalanceValidationStatus.initial => '',
      BalanceValidationStatus.valid => ' (Cocok)',
      BalanceValidationStatus.invalid => ' (Tidak Cocok)',
    };
  }

  Widget get icon {
    return switch (type) {
      BalanceValidationStatus.initial => const SizedBox.shrink(),
      BalanceValidationStatus.valid => Assets.icons.icValid.svg(
        width: 38,
        height: 38,
      ),
      BalanceValidationStatus.invalid => Assets.icons.icInvalid.svg(
        width: 38,
        height: 38,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selisih Saldo',
                  style: textTheme.labelMedium?.copyWith(
                    color: titleColor,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Rp ${value == null ? '-' : value!.toCurrency}',
                      ),
                      TextSpan(text: suffixText),
                    ],
                    style: textTheme.titleLarge?.copyWith(
                      color: valueTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          icon,
        ],
      ),
    );
  }
}
