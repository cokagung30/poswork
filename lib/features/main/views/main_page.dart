import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:poswork/core/widgets/widgets.dart';
import 'package:poswork/features/main/bloc/main_bloc.dart';
import 'package:poswork/features/main/main.dart';
import 'package:poswork/gen/assets.gen.dart';

class MainPage extends StatelessWidget {
  const MainPage({
    required this.navigationShell,
    required this.children,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MainBloc(),
      child: _MainPageView(
        navigationShell: navigationShell,
        children: children,
      ),
    );
  }
}

class _MainPageView extends StatelessWidget {
  const _MainPageView({required this.navigationShell, required this.children});

  final StatefulNavigationShell navigationShell;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Scaffold(
          appBar: CustomAppBar(
            hideLeading: true,
            titleWidget: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 36,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Assets.images.logos.image(width: 120, height: 32),
                  const AppBarTrailling(),
                ],
              ),
            ),
            // elevation: 1,
          ),
          body: Row(
            children: [
              Sidebar(navigationShell: navigationShell),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: BoxBorder.fromLTRB(
                      top: const BorderSide(color: Color(0xffEEF0F3)),
                    ),
                  ),
                  child: children[navigationShell.currentIndex],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
