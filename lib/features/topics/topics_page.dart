import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../domain/entities/topic.dart';
import '../../domain/entities/topic_progress.dart';
import '../shared/widgets/widgets.dart';
import 'topics_controller.dart';

/// Экран «Выбор темы» — по макету Figma «02 · Выбор темы».
class TopicsPage extends GetView<TopicsController> {
  /// Создаёт экран выбора темы.
  const TopicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.spaceLg,
              AppDimens.spaceMd,
              AppDimens.spaceLg,
              AppDimens.spaceXl,
            ),
            children: [
              _Header(count: controller.all.length),
              const SizedBox(height: AppDimens.spaceLg),
              if (controller.inProgress.isNotEmpty) ...[
                const _SectionLabel('ПРОДОЛЖАЮ'),
                ...controller.inProgress.map(
                  (t) => _Tile(progress: t, reason: ''),
                ),
                const SizedBox(height: AppDimens.spaceMd),
              ],
              if (controller.available.isNotEmpty) ...[
                const _SectionLabel('ДОСТУПНЫЕ'),
                ...controller.available.map(
                  (t) => _Tile(progress: t, reason: ''),
                ),
                const SizedBox(height: AppDimens.spaceMd),
              ],
              if (controller.locked.isNotEmpty) ...[
                const _SectionLabel('ЗАКРЫТЫЕ'),
                ...controller.locked.map(
                  (t) => _Tile(progress: t, reason: controller.lockReason(t)),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleBack(),
        const SizedBox(width: AppDimens.spaceMd),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Темы', style: AppTextStyles.title),
            Text('$count тем · A1–A2', style: AppTextStyles.caption),
          ],
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppDimens.spaceMd,
        bottom: AppDimens.spaceSm,
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textMuted,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

/// Карточка темы, вид зависит от статуса.
class _Tile extends StatelessWidget {
  const _Tile({required this.progress, required this.reason});

  final TopicProgress progress;
  final String reason;

  @override
  Widget build(BuildContext context) {
    final locked = progress.isLocked;
    final fg = locked ? AppColors.textMuted : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.spaceMd),
      child: AppCard(
        onTap: locked ? null : () => _open(progress.topic),
        radius: AppDimens.radiusMd,
        color: AppColors.surfaceRaised,
        child: Row(
          children: [
            _IconTile(locked: locked),
            const SizedBox(width: AppDimens.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(progress.topic.title,
                      style: AppTextStyles.label.copyWith(color: fg)),
                  const SizedBox(height: 2),
                  Text(_subtitle(), style: AppTextStyles.caption),
                  if (progress.status == TopicStatus.inProgress ||
                      progress.status == TopicStatus.completed) ...[
                    const SizedBox(height: AppDimens.spaceSm),
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusBadge),
                      child: LinearProgressIndicator(
                        value: progress.percent,
                        minHeight: 6,
                        backgroundColor: AppColors.line,
                        valueColor:
                            const AlwaysStoppedAnimation(AppColors.accent),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppDimens.spaceMd),
            _Trailing(progress: progress),
          ],
        ),
      ),
    );
  }

  String _subtitle() {
    switch (progress.status) {
      case TopicStatus.locked:
        return reason;
      case TopicStatus.available:
        return 'Новая тема · 0 / ${progress.totalWords} слов';
      case TopicStatus.inProgress:
      case TopicStatus.completed:
        return '${progress.learnedWords} / ${progress.totalWords} слов · ${progress.percentInt}%';
    }
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.locked});

  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      ),
      child: Center(
        child: AppIcon(
          AppIcons.book,
          color: locked ? AppColors.textMuted : AppColors.textPrimary,
          size: AppDimens.iconMd,
        ),
      ),
    );
  }
}

class _Trailing extends StatelessWidget {
  const _Trailing({required this.progress});

  final TopicProgress progress;

  @override
  Widget build(BuildContext context) {
    switch (progress.status) {
      case TopicStatus.locked:
        return const AppIcon(AppIcons.lock, color: AppColors.textMuted);
      case TopicStatus.available:
        return Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: AppIcon(AppIcons.chevronRight,
                color: AppColors.onAccent, size: AppDimens.iconSm),
          ),
        );
      case TopicStatus.inProgress:
      case TopicStatus.completed:
        return Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accent, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            '${progress.percentInt}%',
            style: AppTextStyles.caption.copyWith(color: AppColors.accent),
          ),
        );
    }
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

void _open(Topic topic) {
  Get.toNamed<void>(Routes.topicDetail, arguments: topic);
}
