import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:poswork/gen/colors.gen.dart';
import 'package:poswork/utils/utils.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: ColorName.green,
            ),
          ),
          const Gap(12),
          Text(
            'Sistem Online',
            style: textTheme.bodyMedium?.copyWith(color: ColorName.grayLight),
          ),
          const Gap(16),
          FractionallySizedBox(
            heightFactor: 0.65,
            child: Container(
              width: 1,
              color: ColorName.grayLight,
            ),
          ),
          const Gap(16),
          Text(
            'Blayag Dek Ani',
            style: textTheme.bodyMedium?.copyWith(color: ColorName.grayLight),
          ),
        ],
      ),
    );
  }
}
