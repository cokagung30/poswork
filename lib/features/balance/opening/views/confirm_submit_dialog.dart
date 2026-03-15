import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poswork/core/widgets/widgets.dart';
import 'package:poswork/gen/assets.gen.dart';
import 'package:poswork/gen/colors.gen.dart';
import 'package:poswork/utils/utils.dart';

void showConfirmSubmitDialog(
  BuildContext context, {
  required num balance,
  required void Function() onSubmitTap,
}) {
  unawaited(
    showDialog<void>(
      context: context,
      builder: (_) => _ConfirmSubmitViewDialog(
        balance: balance,
        onSubmitTap: onSubmitTap,
      ),
    ),
  );
}

class _ConfirmSubmitViewDialog extends StatelessWidget {
  const _ConfirmSubmitViewDialog({
    required this.balance,
    required this.onSubmitTap,
  });

  final num balance;

  final void Function() onSubmitTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    final screenWidth = MediaQuery.sizeOf(context).width;

    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: SizedBox(
          width: screenWidth * 0.4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Assets.icons.icInfo.svg(width: 18, height: 18),
                    Text(
                      'Simpan Saldo Awal',
                      style: textTheme.bodyLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Saldo awal yang anda masukkan yaitu ',
                      ),
                      TextSpan(
                        text: 'Rp. ${balance.toCurrency}',
                        style: textTheme.bodyLarge?.copyWith(
                          color: ColorName.blue,
                        ),
                      ),
                      const TextSpan(
                        text:
                            '. Saldo awal yang sudah disimpan tidak dapat '
                            'diubah kembali  pastikan nominal yang dimasukkan '
                            'sudah benar.',
                      ),
                    ],
                    style: textTheme.bodySmall?.copyWith(color: Colors.black),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton.text(
                      label: 'Batal',
                      isWidthDynamic: true,
                      textStyle: textTheme.labelLarge,
                      textColor: ColorName.red,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 16),
                    AppButton.elevated(
                      label: 'Simpan',
                      isWidthDynamic: true,
                      textStyle: textTheme.labelLarge,
                      backgroundColor: ColorName.blue,
                      onTap: onSubmitTap,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
