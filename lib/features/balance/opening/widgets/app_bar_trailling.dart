import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jiffy/jiffy.dart';
import 'package:poswork/features/balance/opening/opening_balance.dart';
import 'package:poswork/gen/assets.gen.dart';
import 'package:poswork/gen/colors.gen.dart';
import 'package:poswork/utils/utils.dart';

class AppBarTrailling extends StatelessWidget {
  const AppBarTrailling({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return IntrinsicHeight(
      child: Row(
        spacing: 14,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Kasir Utama',
                style: textTheme.titleLarge?.copyWith(fontSize: 16),
              ),
              const _TimerSection(),
            ],
          ),
          FractionallySizedBox(
            heightFactor: 0.8,
            child: Container(
              width: 1,
              color: ColorName.grayLight,
            ),
          ),
          const _LogoutButton(),
        ],
      ),
    );
  }
}

class _TimerSection extends StatelessWidget {
  const _TimerSection();

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    final currentTime = context.watch<OpeningBalanceBloc>().state.currentTime;

    return Text(
      Jiffy.parse(
        (currentTime ?? DateTime.now()).toLocal().toIso8601String(),
      ).format(pattern: 'dd MMMM yyyy, HH:mm:ss'),
      style: textTheme.labelSmall?.copyWith(
        color: ColorName.grayLight,
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return InkWell(
      onTap: () {},
      splashColor: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Row(
          spacing: 8,
          children: [
            Assets.icons.icLogout.svg(width: 20, height: 20),
            Text(
              'Keluar',
              style: textTheme.bodyLarge?.copyWith(color: ColorName.red),
            ),
          ],
        ),
      ),
    );
  }
}
