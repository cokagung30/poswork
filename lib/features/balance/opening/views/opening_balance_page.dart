import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poswork/core/widgets/widgets.dart';
import 'package:poswork/features/balance/opening/opening_balance.dart';
import 'package:poswork/gen/assets.gen.dart';
import 'package:poswork/gen/colors.gen.dart';
import 'package:poswork/utils/utils.dart';

class OpeningBalancePage extends StatelessWidget {
  const OpeningBalancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OpeningBalanceBloc(),
      child: const _OpeningBalanceView(),
    );
  }
}

class _OpeningBalanceView extends StatelessWidget {
  const _OpeningBalanceView();

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ConfrimBalanceListener(
          child: Scaffold(
            appBar: CustomAppBar(
              hideLeading: true,
              titleWidget: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 52,
                  vertical: 32,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Assets.images.logos.image(width: 120, height: 32),
                    const AppBarTrailling(),
                  ],
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                spacing: 12,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36),
                      child: Row(
                        spacing: 36,
                        children: [
                          Expanded(
                            child: Column(
                              spacing: 18,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Saldo Awal Kasir',
                                      style: textTheme.titleLarge?.copyWith(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Masukkan saldo awal laci kas untuk memulai tugas anda hari ini.',
                                      style: textTheme.titleSmall?.copyWith(
                                        color: ColorName.grayLight,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const BalanceInput(),
                                const SuggestionBalances(),
                                const _Information(),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: ColorName.grayLight.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: ColorName.grayLight.withValues(
                                    alpha: 0.25,
                                  ),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Column(
                              children: [
                                NumPadInput(),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: _SubmitButton(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const CustomFooter(),
                ],
              ),
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: ColorName.blueLight),
        borderRadius: BorderRadius.circular(8),
        color: ColorName.blueLight.withValues(alpha: 0.5),
      ),
      child: Row(
        spacing: 8,
        children: [
          Assets.icons.icInfo.svg(width: 20, height: 20),
          Text(
            'Saldo ini akan dicatat sebagai modal awal transaksi kasir Anda.',
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              color: ColorName.blue,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return AppButton.elevated(
      width: 250,
      label: 'BUKA KASIR',
      textStyle: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      suffixIcon: Padding(
        padding: const EdgeInsets.only(left: 28),
        child: Assets.icons.icArrowRight.svg(
          width: 20,
          height: 20,
        ),
      ),
      onTap: () {
        final bloc = context.read<OpeningBalanceBloc>();

        final balance = bloc.state.balance;
        showConfirmSubmitDialog(
          context,
          balance: balance,
          onSubmitTap: () {
            context.read<OpeningBalanceBloc>().add(const BalanceSubmitted());
          },
        );
      },
    );
  }
}
