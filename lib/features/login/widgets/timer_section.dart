import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jiffy/jiffy.dart';
import 'package:poswork/features/login/login.dart';
import 'package:poswork/gen/colors.gen.dart';
import 'package:poswork/utils/utils.dart';

class TimerSection extends StatelessWidget {
  const TimerSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    final currentTime = context.watch<LoginBloc>().state.currentTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          Jiffy.parse(
            (currentTime ?? DateTime.now()).toLocal().toIso8601String(),
          ).format(pattern: 'HH:mm:ss'),
          style: textTheme.titleLarge?.copyWith(
            color: ColorName.blue,
          ),
        ),
        Text(
          Jiffy.now().format(pattern: 'EEEE, dd MMMM yyyy'),
          style: textTheme.bodySmall?.copyWith(
            color: ColorName.gray,
          ),
        ),
      ],
    );
  }
}
