import 'package:flutter/material.dart';
import 'package:poswork/gen/colors.gen.dart';
import 'package:poswork/gen/fonts.gen.dart';

abstract class AppInputDecorationStyle {
  static const BorderRadius _borderRadius = BorderRadius.all(
    Radius.circular(8),
  );

  static const normal = InputDecorationTheme(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    fillColor: Colors.white,
    hintStyle: TextStyle(
      fontSize: 12,
      color: ColorName.grayLight,
      fontWeight: FontWeight.w400,
      fontFamily: FontFamily.poppins,
      letterSpacing: -0.1,
    ),
    border: OutlineInputBorder(
      borderRadius: AppInputDecorationStyle._borderRadius,
      borderSide: BorderSide(color: ColorName.gray),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppInputDecorationStyle._borderRadius,
      borderSide: BorderSide(color: ColorName.grayLight),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppInputDecorationStyle._borderRadius,
      borderSide: BorderSide(color: ColorName.blue),
    ),
    errorStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      fontFamily: FontFamily.poppins,
      color: ColorName.red,
      package: 'ui',
    ),
  );

  static const outline = InputDecorationTheme(
    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    hintStyle: TextStyle(
      fontSize: 12,
      color: ColorName.grayLight,
      fontWeight: FontWeight.w400,
      fontFamily: FontFamily.poppins,
    ),
    border: OutlineInputBorder(
      borderRadius: AppInputDecorationStyle._borderRadius,
      borderSide: BorderSide(color: ColorName.gray),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppInputDecorationStyle._borderRadius,
      borderSide: BorderSide(color: ColorName.grayLight),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppInputDecorationStyle._borderRadius,
      borderSide: BorderSide(color: ColorName.blue),
    ),
    errorStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      fontFamily: FontFamily.poppins,
      color: ColorName.red,
      package: 'ui',
    ),
  );
}
