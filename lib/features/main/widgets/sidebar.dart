import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:poswork/core/widgets/condition_widget.dart';
import 'package:poswork/features/main/main.dart';
import 'package:poswork/gen/colors.gen.dart';
import 'package:poswork/utils/utils.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: BoxBorder.fromLTRB(
            right: const BorderSide(color: Color(0xffEEF0F3)),
            top: const BorderSide(color: Color(0xffEEF0F3)),
          ),
        ),
        child: Column(
          spacing: 24,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: MainMenuEnum.values.map((e) {
            final index = MainMenuEnum.values.indexOf(e);

            return _SidebarMenu(
              isSelected: index == navigationShell.currentIndex,
              menu: e.menu,
              onTap: () {
                navigationShell.goBranch(index);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SidebarMenu extends StatelessWidget {
  const _SidebarMenu({
    required this.isSelected,
    required this.menu,
    required this.onTap,
  });

  final bool isSelected;

  final Menu menu;

  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return InkWell(
      splashColor: Colors.transparent,
      onTap: onTap,
      child: Column(
        spacing: 8,
        children: [
          ConditionWidget(
            isFirstCondition: isSelected,
            firstChild: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColorName.blue,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 5,
                    offset: const Offset(1, 2),
                    color: ColorName.blue.withValues(alpha: 0.5),
                  ),
                ],
              ),
              child: SvgPicture.asset(menu.iconActive, width: 28, height: 28),
            ),
            secondChild: SvgPicture.asset(menu.icon, width: 28, height: 28),
          ),
          Text(
            menu.label,
            style: textTheme.titleLarge?.copyWith(
              color: !isSelected ? ColorName.gray : ColorName.blue,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
