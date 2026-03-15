import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:poswork/features/balance/closing/closing.dart';
import 'package:poswork/gen/assets.gen.dart';
import 'package:poswork/gen/colors.gen.dart';
import 'package:poswork/utils/utils.dart';

class ClosingPage extends StatelessWidget {
  const ClosingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClosingBloc(),
      child: const _ClosingPageView(),
    );
  }
}

class _ClosingPageView extends StatelessWidget {
  const _ClosingPageView();

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return ClosingListener(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        color: ColorName.whiteSurface,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              const Gap(4),
              Column(
                spacing: 4,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tutup Kasir',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    'Selesaikan penjualan dan verifikasi saldo akhir anda',
                    style: textTheme.bodySmall?.copyWith(
                      color: ColorName.gray,
                    ),
                  ),
                ],
              ),
              const ClosingSummarySection(),
              const NetIncomeCard(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: ColorName.grayLight.withValues(alpha: 0.4),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  spacing: 12,
                  children: [
                    Row(
                      spacing: 12,
                      children: [
                        Assets.icons.icCash.svg(width: 28, height: 28),
                        Text(
                          'Uang Fisik di Laci',
                          style: textTheme.bodyLarge?.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                    IntrinsicHeight(
                      child: Row(
                        spacing: 16,
                        children: [
                          const Expanded(
                            child: Column(
                              spacing: 14,
                              children: [
                                ClosingValueField(),
                                BalanceValidateSection(),
                                _Information(),
                              ],
                            ),
                          ),
                          FractionallySizedBox(
                            child: Container(
                              width: 1,
                              color: ColorName.grayLight.withValues(alpha: 0.4),
                            ),
                          ),
                          const NumPadInput(),
                        ],
                      ),
                    ),
                    const SubmitButton(),
                  ],
                ),
              ),
              const Gap(4),
            ],
          ),
        ),
      ),
    );
  }
}

class _Information extends StatelessWidget {
  const _Information();

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: ColorName.blueLight),
        borderRadius: BorderRadius.circular(8),
        color: ColorName.blueLight.withValues(alpha: 0.5),
      ),
      child: Row(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Assets.icons.icInfo.svg(width: 20, height: 20),
          Expanded(
            child: Text(
              'Masukkan jumlah uang fisik tunai yan ada di laci. Sistem akan '
              'memvalidasi terhadap pendapatan tunai bersih.',
              style: textTheme.bodyMedium?.copyWith(
                color: ColorName.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
