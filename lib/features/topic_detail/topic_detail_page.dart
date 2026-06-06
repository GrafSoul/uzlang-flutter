import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../domain/entities/word_block.dart';
import '../learn/lesson_args.dart';
import '../shared/widgets/widgets.dart';
import 'topic_detail_controller.dart';

/// Экран «Тема — обзор» — по макету Figma (03 Слова / 08 Фразы-заперты).
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
                    if (controller.activeTab.value == 0)
                      ..._wordsTab()
                    else
                      ..._phrasesTab(),
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

  List<Widget> _wordsTab() {
    return [
      const _SectionLabel('БЛОКИ ПО 20 СЛОВ · УЧИТЬ → ПОВТОР → ТЕСТ'),
      const SizedBox(height: AppDimens.spaceMd),
      ...controller.blocks.map((b) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.spaceMd),
            child: _BlockCard(
              number: b.index + 1,
              status: b.status,
              subtitle: _wordSubtitle(b),
              onTap: b.status == BlockStatus.available
                  ? () => _startWordBlock(controller, b.index)
                  : null,
            ),
          )),
    ];
  }

  String _wordSubtitle(WordBlock b) {
    final total = b.words.length;
    switch (b.status) {
      case BlockStatus.completed:
        return '$total слов · пройден';
      case BlockStatus.available:
        final learned = controller.learnedInBlock(b);
        return learned > 0
            ? '$learned / $total · продолжить'
            : '$total слов · начать';
      case BlockStatus.locked:
        return 'Откроется после блока ${b.index}';
    }
  }

  List<Widget> _phrasesTab() {
    if (!controller.phrasesUnlocked.value) {
      return const [_PhrasesLocked()];
    }
    return [
      const _SectionLabel('БЛОКИ ФРАЗ · УЧИТЬ → ТЕСТ'),
      const SizedBox(height: AppDimens.spaceMd),
      ...controller.phraseBlocks.map((b) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.spaceMd),
            child: _BlockCard(
              number: b.index + 1,
              status: b.status,
              subtitle: switch (b.status) {
                BlockStatus.completed => '${b.count} фраз · пройден',
                BlockStatus.available => '${b.count} фраз · собрать',
                BlockStatus.locked => 'Откроется после блока ${b.index}',
              },
              onTap: b.status == BlockStatus.available
                  ? () => _startPhraseBlock(controller, b.index)
                  : null,
            ),
          )),
    ];
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
    final tab = controller.activeTab.value;
    final unlocked = controller.phrasesUnlocked.value;
    return Row(
      children: [
        Expanded(
          child: _TabButton(
            label: 'Слова · ${controller.learnedWords.value}/${controller.totalWords.value}',
            active: tab == 0,
            onTap: () => controller.setTab(0),
          ),
        ),
        const SizedBox(width: AppDimens.spaceMd),
        Expanded(
          child: _TabButton(
            label: 'Фразы',
            active: tab == 1,
            locked: !unlocked,
            onTap: () => controller.setTab(1),
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
    this.locked = false,
  });

  final String label;
  final bool active;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.spaceMd),
        decoration: BoxDecoration(
          color: active ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: active ? null : Border.all(color: AppColors.line),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (locked) ...[
              AppIcon(AppIcons.lock,
                  color: active ? AppColors.onAccent : AppColors.textMuted,
                  size: AppDimens.iconSm),
              const SizedBox(width: AppDimens.spaceXs),
            ],
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: active ? AppColors.onAccent : AppColors.textPrimary,
              ),
            ),
          ],
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
      style: AppTextStyles.caption.copyWith(
        color: AppColors.textMuted,
        letterSpacing: 0.5,
      ),
    );
  }
}

/// Карточка блока (универсальная для слов и фраз).
class _BlockCard extends StatelessWidget {
  const _BlockCard({
    required this.number,
    required this.status,
    required this.subtitle,
    required this.onTap,
  });

  final int number;
  final BlockStatus status;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = status == BlockStatus.available;
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
          _BlockMarker(status: status, number: number),
          const SizedBox(width: AppDimens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Блок $number',
                  style: AppTextStyles.label.copyWith(
                    color: status == BlockStatus.locked
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: isActive
                          ? AppColors.accent
                          : AppColors.textSecondary,
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

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

class _BlockMarker extends StatelessWidget {
  const _BlockMarker({required this.status, required this.number});

  final BlockStatus status;
  final int number;

  @override
  Widget build(BuildContext context) {
    switch (status) {
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
          child: Text('$number',
              style: AppTextStyles.label.copyWith(color: AppColors.onAccent)),
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

/// Содержимое вкладки «Фразы», когда они ещё заперты (по макету 08).
class _PhrasesLocked extends GetView<TopicDetailController> {
  const _PhrasesLocked();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppDimens.spaceLg),
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: AppColors.surfaceRaised,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: AppIcon(AppIcons.lock,
                color: AppColors.textMuted, size: 32),
          ),
        ),
        const SizedBox(height: AppDimens.spaceLg),
        Text('Фразы заперты', style: AppTextStyles.title),
        const SizedBox(height: AppDimens.spaceSm),
        Text(
          'Выучи все слова темы «${controller.topic.title}»,\nчтобы открыть ${controller.totalPhrases.value} фраз',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyRegular
              .copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppDimens.spaceXl),
        Container(
          padding: const EdgeInsets.all(AppDimens.spaceLg),
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Слова темы выучены',
                        style: AppTextStyles.label),
                  ),
                  Text(
                    '${controller.learnedWords.value} / ${controller.totalWords.value}',
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.accent),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.spaceSm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.radiusBadge),
                child: LinearProgressIndicator(
                  value: controller.percent,
                  minHeight: 8,
                  backgroundColor: AppColors.line,
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.accent),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.spaceLg),
        if (controller.activeBlock != null)
          PrimaryButton(
            label: 'Доучить слова · осталось ${controller.remainingWords}',
            onPressed: () =>
                _startWordBlock(controller, controller.activeBlock!.index),
          ),
        const SizedBox(height: AppDimens.spaceMd),
        ...List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.spaceMd),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.spaceLg,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('• • • • • • •',
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.textMuted)),
                    ),
                    const AppIcon(AppIcons.lock,
                        color: AppColors.textMuted, size: AppDimens.iconSm),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomCta extends GetView<TopicDetailController> {
  const _BottomCta();

  @override
  Widget build(BuildContext context) {
    // Вкладка слов: CTA активного блока слов.
    if (controller.activeTab.value == 0) {
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
          onPressed: () => _startWordBlock(controller, active.index),
        ),
      );
    }
    // Вкладка фраз: CTA только если фразы открыты.
    if (!controller.phrasesUnlocked.value) return const SizedBox.shrink();
    final active = controller.activePhraseBlock;
    if (active == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(AppDimens.spaceLg),
      child: PrimaryButton(
        label: 'Собрать блок ${active.index + 1}',
        iconName: AppIcons.play,
        onPressed: () => _startPhraseBlock(controller, active.index),
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

/// Запускает блок слов.
void _startWordBlock(TopicDetailController controller, int blockIndex) {
  Get.toNamed<void>(
    Routes.learn,
    arguments: LessonArgs(topic: controller.topic, blockIndex: blockIndex),
  );
}

/// Запускает блок фраз.
void _startPhraseBlock(TopicDetailController controller, int blockIndex) {
  Get.toNamed<void>(
    Routes.phraseLearn,
    arguments: LessonArgs(topic: controller.topic, blockIndex: blockIndex),
  );
}
