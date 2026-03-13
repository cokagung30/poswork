import 'package:flutter/material.dart';
import 'package:poswork/gen/colors.gen.dart';

abstract class AppButtonStyle {
  static final elevated = ButtonStyle(
    padding: WidgetStateProperty.all<EdgeInsets>(const EdgeInsets.all(12)),
    backgroundColor: WidgetStateProperty.all<Color>(ColorName.blue),
    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: ColorName.blue),
      ),
    ),
  );

  static final outlined = ButtonStyle(
    padding: WidgetStateProperty.all<EdgeInsets>(const EdgeInsets.all(12)),
    backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: ColorName.gray),
      ),
    ),
  );

  static final text = ButtonStyle(
    padding: const WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.all(12)),
    backgroundColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
    shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
