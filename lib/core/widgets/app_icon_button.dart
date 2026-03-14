import 'package:flutter/material.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton.icon({
    required this.icon,
    super.key,
    this.color,
    this.onTap,
    this.constraints,
    this.padding = const EdgeInsets.all(8),
    this.size = 24,
  }) : assetWidget = null;

  const AppIconButton.asset({
    required this.assetWidget,
    super.key,
    this.color,
    this.onTap,
    this.constraints,
    this.padding = const EdgeInsets.all(8),
    this.size = 24,
  }) : icon = null;

  final double size;

  final Widget? assetWidget;

  final IconData? icon;

  final Color? color;

  final GestureTapCallback? onTap;

  final EdgeInsetsGeometry padding;

  final BoxConstraints? constraints;

  Widget _buildIcon() {
    return Icon(
      icon,
      size: size,
    );
  }

  Widget _buildAsset() {
    if (assetWidget == null) {
      return const SizedBox.shrink();
    }

    return assetWidget!;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      splashRadius: size - 4,
      color: color,
      padding: padding,
      constraints:
          constraints ??
          BoxConstraints(
            minHeight: size + 12,
            minWidth: size + 12,
          ),
      icon: icon != null ? _buildIcon() : _buildAsset(),
    );
  }
}
