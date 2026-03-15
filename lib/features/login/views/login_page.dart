import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:poswork/core/widgets/widgets.dart';
import 'package:poswork/features/login/login.dart';
import 'package:poswork/gen/assets.gen.dart';
import 'package:poswork/gen/colors.gen.dart';
import 'package:poswork/utils/utils.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Scaffold(
          appBar: CustomAppBar(
            hideLeading: true,
            titleWidget: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Assets.images.logos.image(width: 120, height: 32),
                  const TimerSection(),
                ],
              ),
            ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                spacing: 12,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Text(
                              'Selamat Datang',
                              style: textTheme.titleLarge?.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              'Masukkan PIN untuk mengakses halaman utama ',
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: 16,
                                color: ColorName.grayLight,
                              ),
                            ),
                          ],
                        ),
                        const Gap(18),
                        const PinInput(),
                        const Gap(18),
                        const NumPadSection(),
                      ],
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
