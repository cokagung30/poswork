import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.height,
    this.leadingWidth,
    this.shadowColor,
    this.titleWidget,
    this.leading,
    this.flexibleSpace,
    this.actions,
    this.bottom,
    this.systemUiOverlayStyle,
    this.onBackTap,
    this.titleStyle,
    this.elevation = 0.5,
    this.hideLeading = false,
    this.backgroundColor = Colors.white,
  });

  final String? title;

  final double? elevation;

  final double? leadingWidth;

  final bool hideLeading;

  final Size? height;

  final Color? backgroundColor;

  final Color? shadowColor;

  final Widget? titleWidget;

  final Widget? leading;

  final Widget? flexibleSpace;

  final TextStyle? titleStyle;

  final List<Widget>? actions;

  final PreferredSizeWidget? bottom;

  final SystemUiOverlayStyle? systemUiOverlayStyle;

  final GestureTapCallback? onBackTap;

  Widget? _buildLeading(BuildContext context) {
    if (hideLeading) {
      return null;
    }

    return leading ?? const SizedBox.shrink();
  }

  Widget? _buildTitle(BuildContext context) {
    if (titleWidget == null && title == null) {
      return null;
    }

    if (titleWidget != null) {
      return titleWidget;
    }

    if (title == null) {
      return null;
    }

    final textTheme = Theme.of(context).textTheme;

    return Text(
      title!,
      style:
          titleStyle ??
          textTheme.headlineLarge?.copyWith(
            fontSize: 18,
            color: Colors.black,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: !hideLeading,
      title: _buildTitle(context),
      leading: _buildLeading(context),
      backgroundColor: backgroundColor,
      elevation: elevation,
      actions: actions,
      leadingWidth: leadingWidth,
      bottom: bottom,
      titleSpacing: 0.5,
      flexibleSpace: flexibleSpace,
      centerTitle: false,
      shadowColor: shadowColor,
      surfaceTintColor: backgroundColor,
      systemOverlayStyle:
          systemUiOverlayStyle ??
          const SystemUiOverlayStyle(
            systemNavigationBarIconBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            statusBarColor: Color(0x00000000),
          ),
    );
  }

  @override
  Size get preferredSize => height ?? const Size.fromHeight(kToolbarHeight);
}
