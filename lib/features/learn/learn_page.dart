import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/theme.dart';
import '../../core/utils/script_display.dart';
import '../shared/widgets/widgets.dart';
import 'learn_controller.dart';
import 'lesson_settings_sheet.dart';

/// Экран «Слова — Учить» — по макету Figma «04 · Слова — Учить (свайп)».
class LearnPage extends GetView<LearnController> {
  /// Создаёт экран.
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value || controller.words.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              _TopBar(
                title:
                    '${controller.args.topic.title} · ${controller.index.value + 1} / ${controller.words.length}',
              ),
              const SizedBox(height: AppDimens.spaceMd),
              _Segments(
                total: controller.words.length,
                done: controller.index.value,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.spaceLg),
                  child: Center(child: _WordCard()),
                ),
              ),
              _Actions(),
            ],
          );
        }),
      ),
    );
  }
}

/// Верхняя панель: закрыть · заголовок · настройки + streak.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});

  final String title;

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
            child: Center(
              child: Text(title, style: AppTextStyles.label),
            ),
          ),
          const SizedBox(width: AppDimens.spaceSm),
          InkWell(
            onTap: () => showLessonSettingsSheet(
              scriptMode: Get.find<LearnController>().scriptMode,
            ),
            customBorder: const CircleBorder(),
            child: const Padding(
              padding: EdgeInsets.all(AppDimens.spaceXs),
              child: AppIcon(AppIcons.settings,
                  color: AppColors.textSecondary, size: AppDimens.iconMd),
            ),
          ),
          const SizedBox(width: AppDimens.spaceSm),
        ],
      ),
    );
  }
}

/// Сегментированный прогресс по словам блока.
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
              height: 5,
              margin: EdgeInsets.only(right: i == total - 1 ? 0 : 3),
              decoration: BoxDecoration(
                color: i < done ? AppColors.accent : AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Карточка слова.
class _WordCard extends GetView<LearnController> {
  @override
  Widget build(BuildContext context) {
    final w = controller.current;
    final pair = ScriptDisplay.of(controller.scriptMode.value, w.uz, w.reading);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spaceXl,
        vertical: AppDimens.spaceXxl,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(pair.main,
              style: AppTextStyles.word, textAlign: TextAlign.center),
          const SizedBox(height: AppDimens.spaceSm),
          Text(pair.sub,
              style: AppTextStyles.reading, textAlign: TextAlign.center),
          const SizedBox(height: AppDimens.spaceLg),
          Container(width: 40, height: 1, color: AppColors.line),
          const SizedBox(height: AppDimens.spaceLg),
          Text(w.ru, style: AppTextStyles.heading, textAlign: TextAlign.center),
          const SizedBox(height: AppDimens.spaceLg),
          _ListenButton(onTap: controller.playAudio),
        ],
      ),
    );
  }
}

/// Кнопка «Прослушать» (обводка акцентом).
class _ListenButton extends StatelessWidget {
  const _ListenButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: StadiumBorder(
        side: const BorderSide(color: AppColors.accent),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.spaceLg,
            vertical: AppDimens.spaceSm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppIcon(AppIcons.volume,
                  color: AppColors.accent, size: AppDimens.iconSm),
              const SizedBox(width: AppDimens.spaceSm),
              Text('Прослушать',
                  style: AppTextStyles.label.copyWith(color: AppColors.accent)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Нижние кнопки «Ещё учу» / «Знаю».
class _Actions extends GetView<LearnController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.spaceLg),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: SecondaryButton(
              label: 'Ещё учу',
              onPressed: () => controller.mark(known: false),
            ),
          ),
          const SizedBox(width: AppDimens.spaceMd),
          Expanded(
            flex: 3,
            child: PrimaryButton(
              label: 'Знаю',
              onPressed: () => controller.mark(known: true),
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
      color: AppColors.surface,
      shape: const CircleBorder(side: BorderSide(color: AppColors.line)),
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
