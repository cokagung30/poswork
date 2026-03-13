import 'package:flutter/material.dart';
import 'package:poswork/core/theme/theme.dart';
import 'package:poswork/gen/colors.gen.dart';
import 'package:poswork/gen/fonts.gen.dart';

class AppTheme {
  static ThemeData get standard {
    return ThemeData(
      textTheme: _textTheme,
      primaryColor: ColorName.blue,
      brightness: Brightness.light,
      inputDecorationTheme: AppInputDecorationStyle.outline,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: ColorName.blue,
        secondary: ColorName.gray,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: AppButtonStyle.outlined,
      ),
      textButtonTheme: TextButtonThemeData(
        style: AppButtonStyle.outlined,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: AppButtonStyle.elevated,
      ),
      scaffoldBackgroundColor: ColorName.white,
      tabBarTheme: const TabBarThemeData(
        labelColor: ColorName.blue,
        unselectedLabelColor: Colors.black,
        labelStyle: TextStyle(
          fontSize: 14,
          color: ColorName.blue,
          fontWeight: FontWeight.w600,
          fontFamily: FontFamily.poppins,
        ),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: ColorName.blue,
            width: 2,
          ),
        ),
      ),
    );
  }

  static TextTheme get _textTheme {
    return const TextTheme(
      titleLarge: AppTextStyle.titleSemibold,
      titleMedium: AppTextStyle.titleMedium,
      titleSmall: AppTextStyle.titleRegular,
      headlineLarge: AppTextStyle.largeSemibold,
      headlineMedium: AppTextStyle.largeMedium,
      headlineSmall: AppTextStyle.largeRegular,
      bodyLarge: AppTextStyle.bodySemibold,
      bodyMedium: AppTextStyle.bodyMedium,
      bodySmall: AppTextStyle.bodyRegular,
      labelLarge: AppTextStyle.captionSemibold,
      labelMedium: AppTextStyle.captionMedium,
      labelSmall: AppTextStyle.captionRegular,
    );
  }
}
