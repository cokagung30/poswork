import 'package:flutter/material.dart';
import 'package:poswork/core/widgets/condition_widget.dart';
import 'package:poswork/gen/assets.gen.dart';
import 'package:poswork/gen/colors.gen.dart';
import 'package:poswork/utils/utils.dart';

class CustomNumberPad extends StatelessWidget {
  const CustomNumberPad({
    super.key,
    this.onNumberPressed,
    this.onDeletePressed,
    this.onEnterPressed,
    this.horizontalSpacing = 16,
    this.verticalSpacing = 8,
    this.isEnterButton = true,
  });

  final ValueChanged<int>? onNumberPressed;
  final VoidCallback? onDeletePressed;
  final VoidCallback? onEnterPressed;

  final num verticalSpacing;

  final num horizontalSpacing;

  final bool isEnterButton;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        child: Column(
          spacing: verticalSpacing.toDouble(),
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var row = 0; row < 4; row++)
              Padding(
                padding: EdgeInsets.only(bottom: row < 3 ? 8 : 0),
                child: Row(
                  spacing: horizontalSpacing.toDouble(),
                  mainAxisSize: MainAxisSize.min,
                  children: _buildRow(row),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRow(int row) {
    if (row < 3) {
      return [
        for (var col = 0; col < 3; col++) ...[
          if (col > 0) const SizedBox(width: 8),
          _NumberButton(
            number: row * 3 + col + 1,
            onPressed: onNumberPressed,
          ),
        ],
      ];
    }

    // Last row: delete, 0, enter
    return [
      _IconButton(
        icon: Assets.icons.icDelete,
        onPressed: onDeletePressed,
      ),
      const SizedBox(width: 8),
      _NumberButton(
        number: 0,
        onPressed: onNumberPressed,
      ),
      const SizedBox(width: 8),
      ConditionWidget(
        isFirstCondition: isEnterButton,
        firstChild: _EnterButton(onPressed: onEnterPressed),
        secondChild: _ClearButton(onPressed: onEnterPressed),
      ),
    ];
  }
}

class _NumberButton extends StatelessWidget {
  const _NumberButton({
    required this.number,
    this.onPressed,
  });

  final int number;
  final ValueChanged<int>? onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return SizedBox(
      width: 80,
      height: 60,
      child: Material(
        color: ColorName.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        shadowColor: Colors.black12,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onPressed?.call(number),
          child: Center(
            child: Text(
              '$number',
              style: textTheme.titleLarge?.copyWith(fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    this.onPressed,
  });

  final SvgGenImage icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 60,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Center(
          child: icon.svg(width: 28, height: 28),
        ),
      ),
    );
  }
}

class _EnterButton extends StatelessWidget {
  const _EnterButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 60,
      child: Material(
        color: onPressed != null
            ? ColorName.blue
            : ColorName.blue.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        shadowColor: Colors.black12,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.transparent,
          onTap: onPressed,
          child: Center(
            child: Assets.icons.icEnter.svg(
              width: 28,
              height: 28,
              colorFilter: const ColorFilter.mode(
                ColorName.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return SizedBox(
      width: 80,
      height: 60,
      child: Material(
        color: ColorName.blueLight,
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        shadowColor: Colors.black12,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Center(
            child: Text(
              'C',
              style: textTheme.titleLarge?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorName.blue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
