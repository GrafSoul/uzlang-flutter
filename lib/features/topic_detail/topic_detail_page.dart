import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../domain/entities/word_block.dart';
import '../learn/lesson_args.dart';
import '../shared/widgets/widgets.dart';
import 'topic_detail_controller.dart';

/// Запускает учебную сессию блока [blockIndex] темы.
void _startBlock(TopicDetailController controller, int blockIndex) {
  Get.toNamed<void>(
    Routes.learn,
    arguments: LessonArgs(topic: controller.topic, blockIndex: blockIndex),
  );
}

/// Экран «Тема — обзор» — по макету Figma «03 · Тема — обзор».
class TopicDetailPage extends GetView<TopicDetailController> {
  /// Создаёт экран обзора темы.
  const TopicDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              const _Header(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.spaceLg,
                    AppDimens.spaceSm,
                    AppDimens.spaceLg,
                    AppDimens.spaceLg,
                  ),
                  children: [
                    const _HeroCard(),
                    const SizedBox(height: AppDimens.spaceMd),
                    const _Tabs(),
                    const SizedBox(height: AppDimens.spaceLg),
                    Text(
                      'БЛОКИ ПО 20 СЛОВ · УЧИТЬ → ПОВТОР → ТЕСТ',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: AppDimens.spaceMd),
                    ...controller.blocks.map((b) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppDimens.spaceMd),
                          child: _BlockCard(block: b),
                        )),
                  ],
                ),
              ),
              const _BottomCta(),
            ],
          );
        }),
      ),
    );
  }
}

class _Header extends GetView<TopicDetailController> {
  const _Header();

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
          _CircleBack(),
          Expanded(
            child: Center(
              child: Text(controller.topic.title, style: AppTextStyles.heading),
            ),
          ),
          _StreakPill(value: controller.streak.value),
        ],
      ),
    );
  }
}

class _StreakPill extends StatelessWidget {
  const _StreakPill({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const AppIcon(AppIcons.flame,
              color: AppColors.accent, size: AppDimens.iconSm),
          const SizedBox(width: AppDimens.spaceXs),
          Text('$value', style: AppTextStyles.label),
        ],
      ),
    );
  }
}

class _HeroCard extends GetView<TopicDetailController> {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
            child: const Center(
              child: AppIcon(AppIcons.book, size: AppDimens.iconLg),
            ),
          ),
          const SizedBox(width: AppDimens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(controller.topic.title, style: AppTextStyles.heading),
                Text(
                  'Тема ${controller.topic.sortOrder + 1} · Уровень A1',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.spaceMd),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              '${controller.percentInt}%',
              style: AppTextStyles.caption.copyWith(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tabs extends GetView<TopicDetailController> {
  const _Tabs();

  @override
  Widget build(BuildContext context) {
    final unlocked = controller.phrasesUnlocked.value;
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.spaceMd),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            alignment: Alignment.center,
            child: Text(
              'Слова · ${controller.learnedWords.value}/${controller.totalWords.value}',
              style: AppTextStyles.label.copyWith(color: AppColors.onAccent),
            ),
          ),
        ),
        const SizedBox(width: AppDimens.spaceMd),
        Expanded(
          child: GestureDetector(
            onTap: unlocked
                ? () {}
                : () => Get.snackbar(
                      'Фразы закрыты',
                      'Сначала выучите все слова темы',
                      snackPosition: SnackPosition.BOTTOM,
                    ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppDimens.spaceMd),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                border: Border.all(color: AppColors.line),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!unlocked) ...[
                    const AppIcon(AppIcons.lock,
                        color: AppColors.textMuted, size: AppDimens.iconSm),
                    const SizedBox(width: AppDimens.spaceXs),
                  ],
                  Text(
                    'Фразы',
                    style: AppTextStyles.label.copyWith(
                      color: unlocked
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BlockCard extends GetView<TopicDetailController> {
  const _BlockCard({required this.block});

  final WordBlock block;

  @override
  Widget build(BuildContext context) {
    final n = block.index + 1;
    final isActive = block.status == BlockStatus.available;

    final card = Container(
      padding: const EdgeInsets.all(AppDimens.spaceLg),
      decoration: BoxDecoration(
        color: isActive ? AppColors.accentTint : AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: isActive ? AppColors.accent : AppColors.line,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          _BlockMarker(block: block, number: n),
          const SizedBox(width: AppDimens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Блок $n',
                  style: AppTextStyles.label.copyWith(
                    color: block.status == BlockStatus.locked
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(_subtitle(),
                    style: AppTextStyles.caption.copyWith(
                      color:
                          isActive ? AppColors.accent : AppColors.textSecondary,
                    )),
              ],
            ),
          ),
          if (isActive) ...[
            const SizedBox(width: AppDimens.spaceMd),
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: AppIcon(AppIcons.play,
                    color: AppColors.onAccent, size: AppDimens.iconSm),
              ),
            ),
          ],
        ],
      ),
    );

    if (isActive) {
      return GestureDetector(
        onTap: () => _startBlock(controller, block.index),
        child: card,
      );
    }
    return card;
  }

  String _subtitle() {
    final total = block.words.length;
    switch (block.status) {
      case BlockStatus.completed:
        return '$total слов · пройден';
      case BlockStatus.available:
        final learned = controller.learnedInBlock(block);
        return learned > 0
            ? '$learned / $total · продолжить'
            : '$total слов · начать';
      case BlockStatus.locked:
        return 'Откроется после блока ${block.index}';
    }
  }
}

class _BlockMarker extends StatelessWidget {
  const _BlockMarker({required this.block, required this.number});

  final WordBlock block;
  final int number;

  @override
  Widget build(BuildContext context) {
    switch (block.status) {
      case BlockStatus.completed:
        return Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: AppIcon(AppIcons.check,
                color: AppColors.bg, size: AppDimens.iconSm),
          ),
        );
      case BlockStatus.available:
        return Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: AppTextStyles.label.copyWith(color: AppColors.onAccent),
          ),
        );
      case BlockStatus.locked:
        return Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: AppIcon(AppIcons.lock,
                color: AppColors.textMuted, size: AppDimens.iconSm),
          ),
        );
    }
  }
}

class _BottomCta extends GetView<TopicDetailController> {
  const _BottomCta();

  @override
  Widget build(BuildContext context) {
    final active = controller.activeBlock;
    if (active == null) return const SizedBox.shrink();
    final learned = controller.learnedInBlock(active);
    final label = learned > 0
        ? 'Продолжить блок ${active.index + 1}'
        : 'Начать блок ${active.index + 1}';
    return Padding(
      padding: const EdgeInsets.all(AppDimens.spaceLg),
      child: PrimaryButton(
        label: label,
        iconName: AppIcons.play,
        onPressed: () => _startBlock(controller, active.index),
      ),
    );
  }
}

class _CircleBack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(side: BorderSide(color: AppColors.line)),
      child: InkWell(
        onTap: Get.back,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: AppIcon(AppIcons.chevronLeft, size: AppDimens.iconMd),
          ),
        ),
      ),
    );
  }
}
