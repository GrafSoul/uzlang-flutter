import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/theme.dart';
import '../../domain/entities/enums.dart';
import '../shared/widgets/widgets.dart';
import 'onboarding_controller.dart';

/// Экран онбординга — строго по макету Figma (O1–O5).
class OnboardingPage extends GetView<OnboardingController> {
  /// Создаёт экран онбординга.
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: controller.pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            _WelcomeStep(),
            _NameStep(),
            _ScriptStep(),
            _GoalStep(),
            _DoneStep(),
          ],
        ),
      ),
    );
  }
}

// ─── Общие части ──────────────────────────────────────────────────────────

/// Шапка шага: круглая кнопка «назад» слева и точки прогресса по центру.
class _StepHeader extends GetView<OnboardingController> {
  const _StepHeader({required this.activeDot});

  /// Индекс активной точки (0-based).
  final int activeDot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.spaceLg,
        AppDimens.spaceMd,
        AppDimens.spaceLg,
        AppDimens.spaceSm,
      ),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _CircleButton(
                icon: AppIcons.chevronLeft,
                onTap: controller.back,
              ),
            ),
            _ProgressDots(active: activeDot),
          ],
        ),
      ),
    );
  }
}

/// Круглая кнопка-иконка (для «назад»).
class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(side: BorderSide(color: AppColors.line)),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(child: AppIcon(icon, size: AppDimens.iconMd)),
        ),
      ),
    );
  }
}

/// Точки прогресса: активная — оранжевая «таблетка», прочие — серые точки.
class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.active});

  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(OnboardingController.progressDots, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: isActive ? AppColors.accent : AppColors.textMuted,
            borderRadius: BorderRadius.circular(AppDimens.radiusBadge),
          ),
        );
      }),
    );
  }
}

/// Заголовок + подзаголовок шага (левое выравнивание).
class _StepHeadline extends StatelessWidget {
  const _StepHeadline({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.title),
        const SizedBox(height: AppDimens.spaceSm),
        Text(
          subtitle,
          style: AppTextStyles.bodyRegular
              .copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

/// Нижняя CTA-кнопка шага.
class _Cta extends StatelessWidget {
  const _Cta({required this.label, required this.onPressed, this.caption});

  final String label;
  final VoidCallback? onPressed;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.spaceLg,
        AppDimens.spaceSm,
        AppDimens.spaceLg,
        AppDimens.spaceLg,
      ),
      child: Column(
        children: [
          PrimaryButton(label: label, onPressed: onPressed),
          if (caption != null) ...[
            const SizedBox(height: AppDimens.spaceMd),
            Text(caption!, style: AppTextStyles.caption),
          ],
        ],
      ),
    );
  }
}

// ─── O1 · Приветствие ─────────────────────────────────────────────────────

class _WelcomeStep extends GetView<OnboardingController> {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  ),
                  child: const Center(
                    child: AppIcon(AppIcons.book,
                        color: AppColors.onAccent, size: 30),
                  ),
                ),
                const SizedBox(height: AppDimens.spaceXl),
                Text('UzLang', style: AppTextStyles.title),
                const SizedBox(height: AppDimens.spaceSm),
                Text(
                  'Узбекский — легко.\nКарточки, привычка, прогресс.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyRegular
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        _Cta(
          label: 'Начать',
          onPressed: controller.next,
          caption: 'Бесплатно · без регистрации',
        ),
      ],
    );
  }
}

// ─── O2 · Имя ─────────────────────────────────────────────────────────────

class _NameStep extends GetView<OnboardingController> {
  const _NameStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _StepHeader(activeDot: 0),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _StepHeadline(
                  title: 'Как тебя зовут?',
                  subtitle: 'Будем обращаться по имени. Аккаунт не нужен.',
                ),
                const SizedBox(height: AppDimens.spaceXl),
                TextField(
                  controller: controller.nameField,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label,
                  cursorColor: AppColors.accent,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Имя',
                    hintStyle: AppTextStyles.label
                        .copyWith(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.spaceLg,
                      vertical: 18,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      borderSide: const BorderSide(color: AppColors.accent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      borderSide:
                          const BorderSide(color: AppColors.accent, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Obx(
          () => _Cta(
            label: 'Дальше',
            onPressed: controller.nameEntered.value ? controller.next : null,
          ),
        ),
      ],
    );
  }
}

// ─── O3 · Письменность ────────────────────────────────────────────────────

class _ScriptStep extends GetView<OnboardingController> {
  const _ScriptStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _StepHeader(activeDot: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _StepHeadline(
                  title: 'Как показывать слова?',
                  subtitle: 'Это можно поменять потом в профиле и в уроке.',
                ),
                const SizedBox(height: AppDimens.spaceLg),
                Obx(() {
                  final sel = controller.scriptMode.value;
                  return Column(
                    children: [
                      _ScriptOption(
                        main: 'Салом',
                        reading: '[ салом ]',
                        label: 'Кириллица + чтение',
                        selected: sel == ScriptMode.cyrillic,
                        onTap: () =>
                            controller.selectScript(ScriptMode.cyrillic),
                      ),
                      const SizedBox(height: AppDimens.spaceMd),
                      _ScriptOption(
                        main: 'Salom',
                        reading: '[ салом ]',
                        label: 'Латиница + чтение',
                        selected: sel == ScriptMode.latin,
                        onTap: () => controller.selectScript(ScriptMode.latin),
                      ),
                      const SizedBox(height: AppDimens.spaceMd),
                      _ScriptOption(
                        main: 'Salom',
                        reading: 'Салом · [ салом ]',
                        label: 'Латиница + кириллица',
                        selected: sel == ScriptMode.both,
                        onTap: () => controller.selectScript(ScriptMode.both),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
        _Cta(label: 'Дальше', onPressed: controller.next),
      ],
    );
  }
}

/// Карточка выбора письменности с примером слова.
class _ScriptOption extends StatelessWidget {
  const _ScriptOption({
    required this.main,
    required this.reading,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String main;
  final String reading;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _OptionShell(
      selected: selected,
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(main, style: AppTextStyles.heading),
                    const SizedBox(width: AppDimens.spaceSm),
                    Flexible(
                      child: Text(
                        reading,
                        style: AppTextStyles.bodyRegular
                            .copyWith(color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.spaceXs),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color:
                        selected ? AppColors.accent : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.spaceMd),
          _CheckCircle(selected: selected),
        ],
      ),
    );
  }
}

// ─── O4 · Цель дня ────────────────────────────────────────────────────────

class _GoalStep extends GetView<OnboardingController> {
  const _GoalStep();

  @override
  Widget build(BuildContext context) {
    const goals = <(int, String)>[
      (5, 'Лайт · пара карточек'),
      (10, 'Норм · оптимально'),
      (15, 'Серьёзно'),
      (20, 'Хардкор'),
    ];
    return Column(
      children: [
        const _StepHeader(activeDot: 2),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _StepHeadline(
                  title: 'Сколько минут в день?',
                  subtitle: 'Привычка важнее объёма. Можно поменять позже.',
                ),
                const SizedBox(height: AppDimens.spaceLg),
                Obx(
                  () => Column(
                    children: [
                      for (final (minutes, label) in goals) ...[
                        _GoalOption(
                          minutes: minutes,
                          label: label,
                          selected: controller.dailyGoal.value == minutes,
                          onTap: () => controller.selectGoal(minutes),
                        ),
                        const SizedBox(height: AppDimens.spaceMd),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _Cta(label: 'Дальше', onPressed: controller.next),
      ],
    );
  }
}

/// Карточка выбора цели дня с иконкой-часами.
class _GoalOption extends StatelessWidget {
  const _GoalOption({
    required this.minutes,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final int minutes;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _OptionShell(
      selected: selected,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
            child: const Center(
              child: AppIcon(AppIcons.clock, size: AppDimens.iconMd),
            ),
          ),
          const SizedBox(width: AppDimens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$minutes минут', style: AppTextStyles.label),
                const SizedBox(height: 2),
                Text(label, style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.spaceMd),
          _CheckCircle(selected: selected),
        ],
      ),
    );
  }
}

// ─── O5 · Готово ──────────────────────────────────────────────────────────

class _DoneStep extends GetView<OnboardingController> {
  const _DoneStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Obx(() {
              final name = controller.name;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('👋', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: AppDimens.spaceLg),
                  Text(
                    name.isEmpty ? 'Salom!' : 'Salom, $name!',
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: AppDimens.spaceSm),
                  Text(
                    'Всё готово — начинаем учить\nпо чуть-чуть каждый день.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyRegular
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppDimens.spaceLg),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SummaryPill(text: _scriptLabel(controller.scriptMode.value)),
                      const SizedBox(width: AppDimens.spaceSm),
                      _SummaryPill(text: '${controller.dailyGoal.value} мин / день'),
                    ],
                  ),
                ],
              );
            }),
          ),
        ),
        _Cta(label: 'Начать учить', onPressed: controller.next),
      ],
    );
  }

  String _scriptLabel(ScriptMode mode) => switch (mode) {
        ScriptMode.cyrillic => 'Кириллица + чтение',
        ScriptMode.latin => 'Латиница + чтение',
        ScriptMode.both => 'Латиница + кириллица',
      };
}

/// Итоговый чип на экране «Готово».
class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spaceMd,
        vertical: AppDimens.spaceSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(text, style: AppTextStyles.caption),
    );
  }
}

// ─── Общие виджеты опций ──────────────────────────────────────────────────

/// Оболочка карточки-опции (выбранная — акцентная рамка + тинт).
class _OptionShell extends StatelessWidget {
  const _OptionShell({
    required this.child,
    required this.selected,
    required this.onTap,
  });

  final Widget child;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppDimens.radiusMd);
    return Material(
      color: selected ? AppColors.accentTint : AppColors.surfaceRaised,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.spaceLg,
            vertical: AppDimens.spaceLg,
          ),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.line,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Кружок-индикатор выбора (заполненный с галочкой / пустой).
class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return Container(
        width: 26,
        height: 26,
        decoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: AppIcon(AppIcons.check, color: AppColors.onAccent, size: 16),
        ),
      );
    }
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.line),
      ),
    );
  }
}
