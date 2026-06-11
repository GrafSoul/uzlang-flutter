import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/settings_service.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/script_display.dart';
import '../shared/widgets/widgets.dart';
import 'test_controller.dart';

/// Экран «Слова — Тест» — по макету Figma «06 · Слова — Тест».
class TestPage extends GetView<TestController> {
  /// Создаёт экран.
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value || controller.questions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final q = controller.question;
          return Column(
            children: [
              _TopBar(
                title: 'Тест · ${controller.args.topic.title}',
                lives: controller.lives.value,
              ),
              const SizedBox(height: AppDimens.spaceMd),
              _Segments(
                total: controller.questions.length,
                done: controller.index.value +
                    (controller.revealed.value ? 1 : 0),
              ),
              const SizedBox(height: AppDimens.spaceLg),
              Text('Выбери перевод', style: AppTextStyles.caption),
              const SizedBox(height: AppDimens.spaceMd),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.spaceLg,
                  ),
                  children: [
                    _PromptCard(),
                    const SizedBox(height: AppDimens.spaceLg),
                    ...q.options.map((opt) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppDimens.spaceMd),
                          child: _OptionTile(option: opt),
                        )),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimens.spaceLg),
                child: PrimaryButton(
                  label: 'Продолжить',
                  onPressed: controller.revealed.value ? controller.next : null,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.lives});

  final String title;
  final int lives;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.spaceLg,
        AppDimens.spaceMd,
        AppDimens.spaceLg,
        0,
      ),
      child: Row(
        children: [
          _CircleBtn(icon: AppIcons.close, onTap: Get.back),
          Expanded(
              child: Center(child: Text(title, style: AppTextStyles.label))),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.spaceMd,
              vertical: AppDimens.spaceSm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusXl),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(AppIcons.heart,
                    color: AppColors.error, size: AppDimens.iconSm),
                const SizedBox(width: AppDimens.spaceXs),
                Text('$lives', style: AppTextStyles.label),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Segments extends StatelessWidget {
  const _Segments({required this.total, required this.done});

  final int total;
  final int done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.spaceLg),
      child: Row(
        children: List.generate(total, (i) {
          return Expanded(
            child: Container(
              height: 6,
              margin: EdgeInsets.only(right: i == total - 1 ? 0 : 4),
              decoration: BoxDecoration(
                color: i < done ? AppColors.success : AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PromptCard extends GetView<TestController> {
  @override
  Widget build(BuildContext context) {
    final w = controller.question.word;
    final pair = ScriptDisplay.of(
      Get.find<SettingsService>().scriptMode,
      w.uz,
      w.reading,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spaceXl,
        vertical: AppDimens.spaceXl,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      ),
      child: Column(
        children: [
          Text(pair.main,
              style: AppTextStyles.word, textAlign: TextAlign.center),
          const SizedBox(height: AppDimens.spaceSm),
          Text(pair.sub,
              style: AppTextStyles.reading, textAlign: TextAlign.center),
          const SizedBox(height: AppDimens.spaceMd),
          Material(
            color: AppColors.surface,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: controller.playAudio,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: AppIcon(AppIcons.volume,
                      color: AppColors.accent, size: AppDimens.iconMd),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Вариант ответа.
class _OptionTile extends GetView<TestController> {
  const _OptionTile({required this.option});

  final String option;

  @override
  Widget build(BuildContext context) {
    final revealed = controller.revealed.value;
    final isCorrect = option == controller.question.correct;
    final isSelected = controller.selected.value == option;

    Color bg = AppColors.surface;
    Color border = AppColors.line;
    Color fg = AppColors.textPrimary;
    if (revealed && isCorrect) {
      bg = AppColors.successTint;
      border = AppColors.success;
      fg = AppColors.success;
    } else if (revealed && isSelected && !isCorrect) {
      border = AppColors.error;
      fg = AppColors.error;
    } else if (revealed) {
      fg = AppColors.textMuted;
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      child: InkWell(
        onTap: revealed ? null : () => controller.select(option),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.spaceLg,
            vertical: AppDimens.spaceLg,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(option,
                    style: AppTextStyles.label.copyWith(color: fg)),
              ),
              if (revealed && isCorrect)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child:
                        AppIcon(AppIcons.check, color: AppColors.bg, size: 14),
                  ),
                ),
            ],
          ),
        ),
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
