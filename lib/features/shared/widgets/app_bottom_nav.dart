import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/theme.dart';
import 'app_icon.dart';

/// Вкладки нижней навигации.
enum AppTab {
  /// Учить (главная).
  learn,

  /// Прогресс/статистика.
  progress,

  /// Профиль.
  profile,
}

/// Нижняя навигация приложения (по макету Figma): Учить · Прогресс · Профиль.
///
/// Активная вкладка подсвечивается акцентом. Переходы на Прогресс/Профиль
/// появятся в Фазе 9; пока соответствующие вкладки неактивны.
class AppBottomNav extends StatelessWidget {
  /// Создаёт навигацию с активной вкладкой [current].
  const AppBottomNav({required this.current, super.key});

  /// Текущая активная вкладка.
  final AppTab current;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.spaceSm),
          child: Row(
            children: const [
              Expanded(
                child: _NavItem(
                  tab: AppTab.learn,
                  icon: AppIcons.book,
                  label: 'Учить',
                ),
              ),
              Expanded(
                child: _NavItem(
                  tab: AppTab.progress,
                  icon: AppIcons.chart,
                  label: 'Прогресс',
                ),
              ),
              Expanded(
                child: _NavItem(
                  tab: AppTab.profile,
                  icon: AppIcons.user,
                  label: 'Профиль',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.tab, required this.icon, required this.label});

  final AppTab tab;
  final String icon;
  final String label;

  void _go(AppTab tab) {
    final route = switch (tab) {
      AppTab.learn => Routes.home,
      AppTab.progress => Routes.progress,
      AppTab.profile => Routes.profile,
    };
    Get.offAllNamed<void>(route);
  }

  @override
  Widget build(BuildContext context) {
    // Активность определяется по предку (передаётся через InheritedWidget темы
    // навбара). Здесь просто читаем из ближайшего [AppBottomNav].
    final nav = context.findAncestorWidgetOfExactType<AppBottomNav>();
    final active = nav?.current == tab;
    final color = active ? AppColors.accent : AppColors.textMuted;
    return InkWell(
      onTap: active ? null : () => _go(tab),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.spaceXs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(icon, color: color, size: AppDimens.iconMd),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.caption.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
