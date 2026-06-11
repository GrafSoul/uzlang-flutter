import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/theme.dart';
import '../../domain/entities/enums.dart';
import '../shared/widgets/widgets.dart';
import 'profile_controller.dart';

/// Открывает шит выбора письменности.
void showScriptSheet(ProfileController c) {
  _openSheet(
    title: 'Письменность',
    subtitle: 'Как показывать слова на карточках',
    options: () => [
      _Option(
        title: 'Кириллица + чтение',
        subtitle: 'Салом · [ салом ]',
        selected: c.scriptMode.value == ScriptMode.cyrillic,
        onTap: () => c.setScriptMode(ScriptMode.cyrillic),
      ),
      _Option(
        title: 'Латиница + чтение',
        subtitle: 'Salom · [ салом ]',
        selected: c.scriptMode.value == ScriptMode.latin,
        onTap: () => c.setScriptMode(ScriptMode.latin),
      ),
      _Option(
        title: 'Латиница + кириллица',
        subtitle: 'Salom · Салом',
        selected: c.scriptMode.value == ScriptMode.both,
        onTap: () => c.setScriptMode(ScriptMode.both),
      ),
    ],
  );
}

/// Открывает шит выбора дневной цели.
void showGoalSheet(ProfileController c) {
  const goals = <(int, String)>[
    (5, 'Лайт · пара карточек'),
    (10, 'Норм · оптимально'),
    (15, 'Серьёзно'),
    (20, 'Хардкор'),
  ];
  _openSheet(
    title: 'Цель дня',
    subtitle: 'Сколько минут в день уделять учёбе',
    options: () => [
      for (final (m, label) in goals)
        _Option(
          title: '$m минут',
          subtitle: label,
          selected: c.dailyGoal.value == m,
          onTap: () => c.setDailyGoal(m),
        ),
    ],
  );
}

/// Открывает шит выбора темы.
void showThemeSheet(ProfileController c) {
  const modes = <(ThemeMode, String, String)>[
    (ThemeMode.dark, 'Тёмная', 'Премиум-тёмная (рекомендуется)'),
    (ThemeMode.light, 'Светлая', 'Светлое оформление'),
    (ThemeMode.system, 'Системная', 'Как в настройках телефона'),
  ];
  _openSheet(
    title: 'Тема',
    subtitle: 'Оформление приложения',
    options: () => [
      for (final (mode, title, subtitle) in modes)
        _Option(
          title: title,
          subtitle: subtitle,
          selected: c.themeMode.value == mode,
          onTap: () => c.setThemeMode(mode),
        ),
    ],
  );
}

void _openSheet({
  required String title,
  required String subtitle,
  required List<_Option> Function() options,
}) {
  // Фон рисуем ВНУТРИ виджета: параметры роута не ребилдятся при смене
  // темы, и шит оставался бы в цветах старой палитры.
  Get.bottomSheet<void>(
    _ChoiceSheet(title: title, subtitle: subtitle, optionsBuilder: options),
    backgroundColor: Colors.transparent,
  );
}

class _Option {
  const _Option({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
}

class _ChoiceSheet extends StatelessWidget {
  const _ChoiceSheet({
    required this.title,
    required this.subtitle,
    required this.optionsBuilder,
  });

  final String title;
  final String subtitle;
  final List<_Option> Function() optionsBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusXl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppDimens.spaceLg),
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  Expanded(child: Text(title, style: AppTextStyles.title)),
                  _CircleBtn(icon: AppIcons.close, onTap: Get.back),
                ],
              ),
              const SizedBox(height: AppDimens.spaceXs),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  subtitle,
                  style: AppTextStyles.bodyRegular.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.spaceLg),
              Obx(
                () => Column(
                  children: [
                    for (final o in optionsBuilder()) ...[
                      _OptionTile(option: o),
                      const SizedBox(height: AppDimens.spaceMd),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.spaceSm),
              PrimaryButton(label: 'Готово', onPressed: Get.back),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.option});

  final _Option option;

  @override
  Widget build(BuildContext context) {
    final sel = option.selected;
    return AppCard(
      onTap: option.onTap,
      color: sel ? AppColors.accentTint : AppColors.surfaceRaised,
      radius: AppDimens.radiusMd,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.title,
                  style: AppTextStyles.label.copyWith(
                    color: sel ? AppColors.accent : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(option.subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          if (sel)
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: AppIcon(
                  AppIcons.check,
                  color: AppColors.onAccent,
                  size: 16,
                ),
              ),
            )
          else
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.line),
              ),
            ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.onTap});

  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceRaised,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(child: AppIcon(icon, size: AppDimens.iconSm)),
        ),
      ),
    );
  }
}
