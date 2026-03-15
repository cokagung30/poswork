import 'package:equatable/equatable.dart';
import 'package:poswork/gen/assets.gen.dart';

enum MainMenuEnum { cashier, history, closing }

class Menu extends Equatable {
  const Menu({
    required this.label,
    required this.icon,
    required this.iconActive,
  });

  final String label;

  final String icon;

  final String iconActive;

  @override
  List<Object?> get props => [label, icon, iconActive];
}

extension MainMenuEnumExt on MainMenuEnum {
  Menu get menu {
    return switch (this) {
      MainMenuEnum.cashier => Menu(
        label: 'Kasir',
        icon: Assets.icons.icCashier.path,
        iconActive: Assets.icons.icCashierActive.path,
      ),
      MainMenuEnum.history => Menu(
        label: 'Riwayat',
        icon: Assets.icons.icHistory.path,
        iconActive: Assets.icons.icHistoryActive.path,
      ),
      MainMenuEnum.closing => Menu(
        label: 'Tutup',
        icon: Assets.icons.icClosing.path,
        iconActive: Assets.icons.icClosingActive.path,
      ),
    };
  }
}
