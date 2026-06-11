import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/theme.dart';
import '../shared/widgets/app_bottom_nav.dart';
import '../shared/widgets/widgets.dart';
import 'profile_controller.dart';
import 'profile_sheets.dart';

/// Экран «Профиль» — по макету Figma «12 · Профиль».
class ProfilePage extends GetView<ProfileController> {
  /// Создаёт экран.
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppBottomNav(current: AppTab.profile),
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final s = controller.stats.value;
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.spaceLg,
              AppDimens.spaceLg,
              AppDimens.spaceLg,
              AppDimens.spaceXl,
            ),
            children: [
              Text('Профиль', style: AppTextStyles.title),
              const SizedBox(height: AppDimens.spaceLg),
              _ProfileCard(),
              const SizedBox(height: AppDimens.spaceMd),
              Row(
                children: [
                  Expanded(
                      child: _MiniStat(
                          value: '${s.streakCurrent}', label: 'дней')),
                  const SizedBox(width: AppDimens.spaceMd),
                  Expanded(child: _MiniStat(value: '${s.xp}', label: 'XP')),
                  const SizedBox(width: AppDimens.spaceMd),
                  Expanded(
                      child: _MiniStat(
                          value: '${controller.learnedWords.value}',
                          label: 'слова')),
                ],
              ),
              const SizedBox(height: AppDimens.spaceXl),
              const _SectionLabel('ОБУЧЕНИЕ'),
              const SizedBox(height: AppDimens.spaceSm),
              _SettingsGroup(children: [
                _NavRow(
                  icon: AppIcons.pencil,
                  label: 'Письменность',
                  value: controller.scriptLabel,
                  onTap: () => showScriptSheet(controller),
                ),
                _NavRow(
                  icon: AppIcons.target,
                  label: 'Цель дня',
                  value: '${controller.dailyGoal.value} мин',
                  onTap: () => showGoalSheet(controller),
                ),
                _ToggleRow(
                  icon: AppIcons.volume,
                  label: 'Звук в карточках',
                  value: controller.soundEnabled.value,
                  onChanged: controller.setSoundEnabled,
                ),
              ]),
              const SizedBox(height: AppDimens.spaceLg),
              const _SectionLabel('ПРИЛОЖЕНИЕ'),
              const SizedBox(height: AppDimens.spaceSm),
              _SettingsGroup(children: [
                _NavRow(
                  icon: AppIcons.moon,
                  label: 'Тема',
                  value: controller.themeLabel,
                  onTap: () => showThemeSheet(controller),
                ),
                _ToggleRow(
                  icon: AppIcons.clock,
                  label: 'Напоминания',
                  value: controller.remindersEnabled.value,
                  onChanged: controller.setRemindersEnabled,
                ),
                _NavRow(
                  icon: AppIcons.info,
                  label: 'О приложении',
                  value: '',
                  onTap: _showAbout,
                ),
              ]),
            ],
          );
        }),
      ),
    );
  }

  void _showAbout() {
    Get.dialog<void>(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('UzLang', style: AppTextStyles.heading),
        content: Text(
          'Учим узбекский по карточкам.\nВерсия 1.0.0',
          style: AppTextStyles.bodyRegular
              .copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('Ок', style: AppTextStyles.label),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    final name = controller.name.value;
    final letter = name.isEmpty ? 'U' : name.characters.first.toUpperCase();
    return Container(
      padding: const EdgeInsets.all(AppDimens.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            alignment: Alignment.center,
            child: Text(letter,
                style: AppTextStyles.title.copyWith(color: AppColors.onAccent)),
          ),
          const SizedBox(width: AppDimens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name.isEmpty ? 'Без имени' : name,
                    style: AppTextStyles.heading),
                Text('На UzLang ${controller.joinedLabel.value}',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          _CircleBtn(icon: AppIcons.pencil, onTap: () => _editName(context)),
        ],
      ),
    );
  }

  void _editName(BuildContext context) {
    final field = TextEditingController(text: controller.name.value);
    Get.dialog<void>(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Имя', style: AppTextStyles.heading),
        content: TextField(
          controller: field,
          autofocus: true,
          style: AppTextStyles.body,
          cursorColor: AppColors.accent,
          decoration: InputDecoration(
            hintText: 'Имя',
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.line)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.accent)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('Отмена',
                style: AppTextStyles.label
                    .copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              controller.setName(field.text);
              Get.back<void>();
            },
            child: Text('Сохранить',
                style: AppTextStyles.label.copyWith(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Text(value,
              style: AppTextStyles.heading.copyWith(color: AppColors.accent)),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.caption
          .copyWith(color: AppColors.textMuted, letterSpacing: 1),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          children[i],
          if (i != children.length - 1)
            const SizedBox(height: AppDimens.spaceSm),
        ],
      ],
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _RowShell(
      onTap: onTap,
      child: Row(
        children: [
          _LeadIcon(icon: icon),
          const SizedBox(width: AppDimens.spaceMd),
          Expanded(child: Text(label, style: AppTextStyles.label)),
          if (value.isNotEmpty)
            Text(value,
                style: AppTextStyles.label
                    .copyWith(color: AppColors.textSecondary)),
          const SizedBox(width: AppDimens.spaceSm),
          AppIcon(AppIcons.chevronRight,
              color: AppColors.textMuted, size: AppDimens.iconSm),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _RowShell(
      child: Row(
        children: [
          _LeadIcon(icon: icon),
          const SizedBox(width: AppDimens.spaceMd),
          Expanded(child: Text(label, style: AppTextStyles.label)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.bg,
            activeTrackColor: AppColors.accent,
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: AppColors.surface,
          ),
        ],
      ),
    );
  }
}

class _RowShell extends StatelessWidget {
  const _RowShell({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceRaised,
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.spaceLg,
            vertical: AppDimens.spaceMd,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _LeadIcon extends StatelessWidget {
  const _LeadIcon({required this.icon});

  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      ),
      child: Center(
        child: AppIcon(icon,
            color: AppColors.textSecondary, size: AppDimens.iconSm),
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
      color: AppColors.surface,
      shape: CircleBorder(side: BorderSide(color: AppColors.line)),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(child: AppIcon(icon, size: AppDimens.iconSm)),
        ),
      ),
    );
  }
}
