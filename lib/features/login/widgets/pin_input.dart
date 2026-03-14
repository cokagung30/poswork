import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poswork/features/login/login.dart';
import 'package:poswork/gen/colors.gen.dart';

class PinInput extends StatelessWidget {
  const PinInput({super.key});

  @override
  Widget build(BuildContext context) {
    final pin = context.select<LoginBloc, String>((value) => value.state.pin);

    return Row(
      spacing: 24,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final dotColor = _dotColor(index, pin);

        return _PinDot(dotColor: dotColor);
      }),
    );
  }

  Color _dotColor(int index, String pin) {
    if (pin.length > index) return ColorName.blue;
    if (pin.length == index) return ColorName.blue.withValues(alpha: 0.3);
    return ColorName.grayLight;
  }
}

class _PinDot extends StatelessWidget {
  const _PinDot({required this.dotColor});

  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: dotColor,
        shape: BoxShape.circle,
      ),
    );
  }
}
