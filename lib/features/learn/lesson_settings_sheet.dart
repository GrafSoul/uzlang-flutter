import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/settings_service.dart';
import '../../core/theme/theme.dart';
import '../../domain/entities/enums.dart';
import '../shared/widgets/widgets.dart';

/// Подпись «мин» на выбранном чипе времени (из Figma «11 · Настройки урока»).
const Color _minOnAccent = Color(0xFF8A4A1E);

/// Открывает шит «Настройки урока» — по макету Figma «11 · Настройки урока».
///
/// Письменность применяется на лету: пишется в [SettingsService] и в
/// реактивный [scriptMode] вызывающего контроллера (карточка перерисуется).
/// Время на урок пишется в настройки.
void showLessonSettingsSheet({required Rx<ScriptMode> scriptMode}) {
  final settings = Get.find<SettingsService>();
  final goal = settings.dailyGoalMinutes.obs;

  Get.bottomSheet<void>(
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Зона затемнения над шитом: «урок на паузе» (тапы проходят сквозь).
        const IgnorePointer(
          child: SizedBox(
            height: 150,
            width: double.infinity,
            child: Center(child: _PauseLabel()),
          ),
        ),
        _Sheet(scriptMode: scriptMode, goal: goal, settings: settings),
      ],
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x8C000000), // чёрный 55% — как в макете
  );
}

class _PauseLabel extends StatelessWidget {
  const _PauseLabel();

  @override
  Widget build(BuildContext context) {
    return Text(
      'урок на паузе',
      style: AppTextStyles.label.copyWith(
        fontSize: 13,
        color: const Color(0xFF6B7079),
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({
    required this.scriptMode,
    required this.goal,
    required this.settings,
  });

  final Rx<ScriptMode> scriptMode;
  final RxInt goal;
  final SettingsService settings;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(
          top: BorderSide(color: AppColors.line),
          left: BorderSide(color: AppColors.line),
          right: BorderSide(color: AppColors.line),
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ручка шита.
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Настройки урока',
                      style: AppTextStyles.title.copyWith(fontSize: 22),
                    ),
                  ),
                  _CloseBtn(),
                ],
              ),
              const SizedBox(height: 24),
              const _SectionLabel('ОТОБРАЖЕНИЕ СЛОВА'),
              const SizedBox(height: 12),
              _ScriptOption(
                main: 'Салом',
                sub: '[ салом ]',
                selected: scriptMode.value == ScriptMode.cyrillic,
                onTap: () => _setScript(ScriptMode.cyrillic),
              ),
              const SizedBox(height: 10),
              _ScriptOption(
                main: 'Salom',
                sub: '[ салом ]',
                selected: scriptMode.value == ScriptMode.latin,
                onTap: () => _setScript(ScriptMode.latin),
              ),
              const SizedBox(height: 10),
              _ScriptOption(
                main: 'Salom',
                sub: 'Салом',
                selected: scriptMode.value == ScriptMode.both,
                onTap: () => _setScript(ScriptMode.both),
              ),
              const SizedBox(height: 24),
              const _SectionLabel('ВРЕМЯ НА УРОК В ДЕНЬ'),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final (i, m) in const [5, 10, 15, 20].indexed) ...[
                    if (i != 0) const SizedBox(width: 10),
                    if (i == 3)
                      Expanded(child: _TimeChip(minutes: m, goal: goal))
                    else
                      _TimeChip(minutes: m, goal: goal),
                  ],
                ],
              ),
              const SizedBox(height: 26),
              PrimaryButton(label: 'Готово', onPressed: Get.back),
            ],
          ),
        ),
      ),
    );
  }

  void _setScript(ScriptMode mode) {
    scriptMode.value = mode;
    settings.setScriptMode(mode);
  }
}

class _CloseBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: Get.back,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Center(child: AppIcon(AppIcons.close, size: 16)),
        ),
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

/// Вариант отображения слова (64dp, выбранный — акцентная рамка и тинт).
class _ScriptOption extends StatelessWidget {
  const _ScriptOption({
    required this.main,
    required this.sub,
    required this.selected,
    required this.onTap,
  });

  final String main;
  final String sub;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.accentTint : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.line,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      main,
                      style: AppTextStyles.heading.copyWith(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      sub,
                      style: AppTextStyles.bodyRegular.copyWith(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: AppIcon(
                      AppIcons.check,
                      color: AppColors.onAccent,
                      size: 15,
                    ),
                  ),
                )
              else
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.line, width: 1.5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Чип времени (5/10/15/20 минут).
class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.minutes, required this.goal});

  final int minutes;
  final RxInt goal;

  @override
  Widget build(BuildContext context) {
    final selected = goal.value == minutes;
    return Material(
      color: selected ? AppColors.accent : AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          goal.value = minutes;
          Get.find<SettingsService>().setDailyGoalMinutes(minutes);
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 80,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: selected ? null : Border.all(color: AppColors.line),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$minutes',
                style: AppTextStyles.heading.copyWith(
                  fontSize: 17,
                  color: selected ? AppColors.onAccent : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                'мин',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: selected ? _minOnAccent : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
