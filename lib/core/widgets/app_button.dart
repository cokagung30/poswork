import 'package:flutter/material.dart';
import 'package:poswork/gen/colors.gen.dart';
import 'package:poswork/gen/fonts.gen.dart';

enum AppButtonType { elevated, outlined, text }

class AppButton extends StatelessWidget {
  const AppButton.elevated({
    required this.label,
    super.key,
    this.backgroundColor,
    this.height,
    this.width,
    this.onTap,
    this.textStyle,
    this.contentPadding,
    this.splashColor,
    this.leadingIcon,
    this.borderRadius,
    this.suffixIcon,
    this.textColor = Colors.white,
    this.isLoading = false,
    this.isWidthDynamic = false,
  }) : type = AppButtonType.elevated,
       borderColor = null;

  const AppButton.outlined({
    required this.label,
    super.key,
    this.backgroundColor,
    this.height,
    this.width,
    this.onTap,
    this.textStyle,
    this.contentPadding,
    this.splashColor,
    this.leadingIcon,
    this.borderRadius,
    this.textColor = ColorName.blue,
    this.isLoading = false,
    this.isWidthDynamic = false,
    this.borderColor = ColorName.grayLight,
  }) : type = AppButtonType.outlined,
       suffixIcon = null;

  const AppButton.text({
    required this.label,
    super.key,
    this.height,
    this.width,
    this.onTap,
    this.textStyle,
    this.contentPadding,
    this.leadingIcon,
    this.suffixIcon,
    this.splashColor,
    this.borderRadius,
    this.textColor = ColorName.blue,
    this.isLoading = false,
    this.isWidthDynamic = false,
  }) : type = AppButtonType.text,
       borderColor = null,
       backgroundColor = null;

  final double? height;

  final double? width;

  final double? borderRadius;

  final String label;

  final bool isWidthDynamic;

  final bool isLoading;

  final EdgeInsets? contentPadding;

  final Color? backgroundColor;

  final Color? borderColor;

  final Color? splashColor;

  final Color textColor;

  final GestureTapCallback? onTap;

  final AppButtonType type;

  final Widget? leadingIcon;

  final Widget? suffixIcon;

  final TextStyle? textStyle;

  EdgeInsets get padding => contentPadding != null
      ? contentPadding!
      : const EdgeInsets.symmetric(vertical: 10, horizontal: 16);

  Color get defaultTextColor {
    switch (type) {
      case AppButtonType.elevated:
        return onTap == null ? Colors.white : textColor;
      case AppButtonType.outlined:
        return onTap == null ? ColorName.blue : textColor;
      case AppButtonType.text:
        return onTap == null ? ColorName.blue : textColor;
    }
  }

  static TextStyle get defaultTextStyle {
    return const TextStyle(
      fontFamily: FontFamily.poppins,
      package: 'ui',
      fontWeight: FontWeight.w400,
      fontSize: 14,
    );
  }

  ButtonStyle? _themeStyle(BuildContext context) {
    switch (type) {
      case AppButtonType.elevated:
        return Theme.of(context).elevatedButtonTheme.style;
      case AppButtonType.outlined:
        return Theme.of(context).outlinedButtonTheme.style;
      case AppButtonType.text:
        return Theme.of(context).textButtonTheme.style;
    }
  }

  Widget _buildSuffixIcon() {
    if (suffixIcon == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: suffixIcon,
    );
  }

  Widget _buildLeadingIcon() {
    if (leadingIcon == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: leadingIcon,
    );
  }

  Widget _buildText() {
    return Text(
      label,
      textAlign: TextAlign.center,
      style:
          textStyle?.copyWith(color: defaultTextColor) ??
          defaultTextStyle.copyWith(color: defaultTextColor),
    );
  }

  Widget _buildLoading() {
    return const SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: Colors.white,
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return _buildLoading();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLeadingIcon(),
        if (isWidthDynamic || width != null)
          _buildText()
        else
          Expanded(child: _buildText()),
        _buildSuffixIcon(),
      ],
    );
  }

  Widget _buildButton(BuildContext context) {
    switch (type) {
      case AppButtonType.elevated:
        final style = _themeStyle(context)?.copyWith(
          padding: WidgetStateProperty.all<EdgeInsets?>(padding),
          elevation: WidgetStateProperty.all<double?>(0),
          overlayColor: WidgetStateColor.resolveWith(
            (states) => (splashColor ?? defaultTextColor).withValues(
              alpha: 0.1,
            ),
          ),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 8),
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            final color = backgroundColor ?? ColorName.blue;
            if (states.contains(WidgetState.disabled)) {
              return color.withValues(alpha: 0.8);
            }

            return color;
          }),
        );

        return ElevatedButton(
          onPressed: onTap,
          style: style,
          child: _buildContent(),
        );
      case AppButtonType.outlined:
        final style = _themeStyle(context)?.copyWith(
          padding: WidgetStateProperty.all<EdgeInsets?>(padding),
          overlayColor: WidgetStateColor.resolveWith(
            (states) => defaultTextColor.withValues(alpha: 0.1),
          ),
          side: borderColor != null
              ? WidgetStateProperty.all(
                  BorderSide(color: borderColor ?? ColorName.gray),
                )
              : null,
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 8),
              side: BorderSide(
                color: borderColor ?? ColorName.blue,
              ),
            ),
          ),
          backgroundColor: backgroundColor != null
              ? WidgetStateProperty.resolveWith((states) {
                  return backgroundColor;
                })
              : null,
        );

        return OutlinedButton(
          onPressed: onTap,
          style: style,
          child: _buildContent(),
        );
      case AppButtonType.text:
        final style = _themeStyle(context)?.copyWith(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 8),
            ),
          ),
          padding: WidgetStateProperty.all<EdgeInsets?>(padding),
          overlayColor: WidgetStateColor.resolveWith(
            (states) => defaultTextColor.withValues(alpha: 0.1),
          ),
        );

        return TextButton(
          onPressed: onTap,
          style: style,
          child: _buildContent(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final button = _buildButton(context);

    if (width != null && height != null) {
      return Wrap(
        children: [
          SizedBox(height: height, width: width, child: button),
        ],
      );
    }

    if (height != null) {
      return Wrap(
        children: [
          SizedBox(
            height: height,
            width: isWidthDynamic ? null : width,
            child: button,
          ),
        ],
      );
    }

    if (width != null) {
      return Wrap(
        children: [
          SizedBox(
            height: isWidthDynamic ? null : height,
            width: width,
            child: button,
          ),
        ],
      );
    }

    if (isWidthDynamic) {
      return Wrap(
        children: [
          SizedBox(
            height: isWidthDynamic ? null : height,
            width: isWidthDynamic ? null : width,
            child: button,
          ),
        ],
      );
    }

    return button;
  }
}
