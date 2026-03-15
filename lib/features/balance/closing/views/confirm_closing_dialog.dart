import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poswork/core/widgets/widgets.dart';
import 'package:poswork/gen/assets.gen.dart';
import 'package:poswork/gen/colors.gen.dart';
import 'package:poswork/utils/utils.dart';

void showConfirmClosingDialog(
  BuildContext context, {
  required num closingBalance,
  required num totalCash,
  required void Function() onSubmitTap,
}) {
  unawaited(
    showDialog<void>(
      context: context,
      builder: (_) => _ConfirmClosingViewDialog(
        closingBalance: closingBalance,
        totalCash: totalCash,
        onSubmitTap: onSubmitTap,
      ),
    ),
  );
}

class _ConfirmClosingViewDialog extends StatelessWidget {
  const _ConfirmClosingViewDialog({
    required this.closingBalance,
    required this.totalCash,
    required this.onSubmitTap,
  });

  final num closingBalance;
  final num totalCash;
  final void Function() onSubmitTap;

  num get diffBalance => closingBalance - totalCash;

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
                      'Tutup Toko',
                      style: textTheme.bodyLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text:
                            'Total uang fisik anda di laci berdasarkan '
                            'perhitungan sistem yaitu',
                      ),
                      TextSpan(
                        text: ' Rp. ${totalCash.toCurrency}',
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text:
                            '. Sementara perhitungan uang fisik anda di laci '
                            'yaitu',
                      ),
                      TextSpan(
                        text: ' Rp. ${closingBalance.toCurrency}',
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: ColorName.blue,
                        ),
                      ),
                      const TextSpan(
                        text: '. Sehingga selisih uang anda yaitu ',
                      ),
                      TextSpan(
                        text: 'Rp. ${diffBalance.abs().toCurrency} ',
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: (diffBalance < 0)
                              ? ColorName.red
                              : ColorName.green,
                        ),
                      ),
                      TextSpan(
                        text: (diffBalance < 0) ? '(Tidak Cocok)' : '(Cocok)',
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: (diffBalance < 0)
                              ? ColorName.red
                              : ColorName.green,
                        ),
                      ),
                    ],
                    style: textTheme.bodySmall?.copyWith(color: Colors.black),
                  ),
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
