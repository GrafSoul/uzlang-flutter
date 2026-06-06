import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/theme.dart';
import '../../domain/entities/enums.dart';
import '../shared/widgets/widgets.dart';
import 'review_controller.dart';

/// Экран «Слова — Повтор» — по макету Figma «05 · Слова — Повтор».
class ReviewPage extends GetView<ReviewController> {
  /// Создаёт экран.
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!controller.hasCards) {
            return const _EmptyState();
          }
          return Column(
            children: [
              _TopBar(count: controller.due.length),
              const SizedBox(height: AppDimens.spaceMd),
              _Segments(
                total: controller.due.length,
                done: controller.index.value,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.spaceLg),
                  child: Center(child: _Card()),
                ),
              ),
              const _RatingBar(),
            ],
          );
        }),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.count});

  final int count;

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
              child: Text('Повтор · $count на сегодня',
                  style: AppTextStyles.label),
            ),
          ),
          const SizedBox(width: 40),
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

class _Card extends GetView<ReviewController> {
  @override
  Widget build(BuildContext context) {
    final w = controller.currentWord;
    if (w == null) return const SizedBox.shrink();
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
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.spaceMd,
              vertical: AppDimens.spaceXs,
            ),
            decoration: BoxDecoration(
              color: AppColors.accentTint,
              borderRadius: BorderRadius.circular(AppDimens.radiusBadge),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppIcon(AppIcons.refresh,
                    color: AppColors.accent, size: 14),
                const SizedBox(width: AppDimens.spaceXs),
                Text('ПОВТОР',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.accent, letterSpacing: 1)),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.spaceMd),
          Text(w.uz, style: AppTextStyles.word, textAlign: TextAlign.center),
          const SizedBox(height: AppDimens.spaceSm),
          Text('[ ${w.reading} ]',
              style: AppTextStyles.reading, textAlign: TextAlign.center),
          const SizedBox(height: AppDimens.spaceLg),
          Container(width: 40, height: 1, color: AppColors.line),
          const SizedBox(height: AppDimens.spaceLg),
          Text(w.ru, style: AppTextStyles.heading, textAlign: TextAlign.center),
          const SizedBox(height: AppDimens.spaceLg),
          Material(
            color: AppColors.surface,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: controller.playAudio,
              customBorder: const CircleBorder(),
              child: const SizedBox(
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

/// Панель из четырёх оценок FSRS.
class _RatingBar extends GetView<ReviewController> {
  const _RatingBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.spaceLg),
      child: Column(
        children: [
          Text('Насколько легко вспомнил?', style: AppTextStyles.caption),
          const SizedBox(height: AppDimens.spaceMd),
          Row(
            children: [
              _RatingBtn(
                label: 'Снова',
                hint: '<1 мин',
                color: AppColors.error,
                onTap: () => controller.rate(Rating.again),
              ),
              const SizedBox(width: AppDimens.spaceSm),
              _RatingBtn(
                label: 'Трудно',
                hint: '10 мин',
                color: AppColors.accent,
                onTap: () => controller.rate(Rating.hard),
              ),
              const SizedBox(width: AppDimens.spaceSm),
              _RatingBtn(
                label: 'Хорошо',
                hint: '1 день',
                color: AppColors.success,
                onTap: () => controller.rate(Rating.good),
              ),
              const SizedBox(width: AppDimens.spaceSm),
              _RatingBtn(
                label: 'Лёгко',
                hint: '4 дня',
                color: AppColors.info,
                onTap: () => controller.rate(Rating.easy),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RatingBtn extends StatelessWidget {
  const _RatingBtn({
    required this.label,
    required this.hint,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String hint;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.spaceMd),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(color: color),
            ),
            child: Column(
              children: [
                Text(label,
                    style: AppTextStyles.labelSmall.copyWith(color: color)),
                const SizedBox(height: 2),
                Text(hint, style: AppTextStyles.caption),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppDimens.spaceLg),
            Text('На сегодня всё повторено', style: AppTextStyles.title),
            const SizedBox(height: AppDimens.spaceSm),
            Text(
              'Возвращайся позже — карточки появятся\nпо мере того, как подойдёт срок.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyRegular
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimens.spaceXl),
            SizedBox(
              width: 200,
              child: PrimaryButton(label: 'Готово', onPressed: Get.back),
            ),
          ],
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
