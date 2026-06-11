import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../domain/entities/topic_progress.dart';
import '../shared/widgets/app_bottom_nav.dart';
import '../shared/widgets/widgets.dart';
import 'home_controller.dart';

/// Главный экран — по макету Figma «01 · Главная».
class HomePage extends GetView<HomeController> {
  /// Создаёт главный экран.
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppBottomNav(current: AppTab.learn),
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.spaceLg,
              AppDimens.spaceLg,
              AppDimens.spaceLg,
              AppDimens.spaceXl,
            ),
            children: [
              const _Header(),
              const SizedBox(height: AppDimens.spaceLg),
              const _StatsRow(),
              const SizedBox(height: AppDimens.spaceLg),
              const _ContinueCard(),
              const SizedBox(height: AppDimens.spaceXl),
              _TopicsHeader(count: controller.topics.length),
              const SizedBox(height: AppDimens.spaceMd),
              ...controller.topics.take(6).map((tp) => Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.spaceMd),
                    child: _TopicTile(progress: tp),
                  )),
            ],
          );
        }),
      ),
    );
  }
}

/// Шапка: аватар, приветствие, кнопка настроек.
class _Header extends GetView<HomeController> {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final name = controller.userName.value;
    final letter = name.isEmpty ? 'U' : name.characters.first.toUpperCase();
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          alignment: Alignment.center,
          child: Text(
            letter,
            style: AppTextStyles.heading.copyWith(color: AppColors.onAccent),
          ),
        ),
        const SizedBox(width: AppDimens.spaceMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isEmpty ? 'Salom!' : 'Salom, $name!',
                style: AppTextStyles.heading,
              ),
              Text('Davom etamizmi?', style: AppTextStyles.caption),
            ],
          ),
        ),
        // Шестерёнка ведёт в «Профиль» — там живут все настройки.
        _RoundIconButton(
          icon: AppIcons.settings,
          onTap: () => Get.offAllNamed<void>(Routes.profile),
        ),
      ],
    );
  }
}

/// Ряд из трёх стат-карточек.
class _StatsRow extends GetView<HomeController> {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    final s = controller.stats.value;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: AppIcons.flame,
            iconColor: AppColors.accent,
            value: '${s.streakCurrent}',
            label: 'дней подряд',
          ),
        ),
        const SizedBox(width: AppDimens.spaceMd),
        Expanded(
          child: _StatCard(
            icon: AppIcons.star,
            iconColor: AppColors.accent,
            value: '${s.xp}',
            label: 'XP всего',
          ),
        ),
        const SizedBox(width: AppDimens.spaceMd),
        Expanded(
          child: _StatCard(
            icon: AppIcons.target,
            iconColor: AppColors.success,
            value:
                '${controller.todayMinutes.value}/${controller.dailyGoalMinutes.value}',
            label: 'цель дня',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final String icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIcon(icon, color: iconColor, size: AppDimens.iconMd),
          const SizedBox(height: AppDimens.spaceSm),
          Text(value, style: AppTextStyles.heading),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

/// Большая карточка «Продолжить».
class _ContinueCard extends GetView<HomeController> {
  const _ContinueCard();

  @override
  Widget build(BuildContext context) {
    final tp = controller.continueTopic;
    if (tp == null) return const SizedBox.shrink();
    return Material(
      color: AppColors.accent,
      borderRadius: BorderRadius.circular(AppDimens.radiusXl),
      child: InkWell(
        onTap: controller.openContinue,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ПРОДОЛЖИТЬ',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.onAccent.withValues(alpha: 0.7),
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Тема: ${tp.topic.title}',
                          style: AppTextStyles.heading
                              .copyWith(color: AppColors.onAccent),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: AppIcon(AppIcons.play,
                          color: AppColors.accent, size: AppDimens.iconMd),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.spaceLg),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.radiusBadge),
                child: LinearProgressIndicator(
                  value: tp.percent,
                  minHeight: 8,
                  backgroundColor: AppColors.onAccent.withValues(alpha: 0.25),
                  valueColor: AlwaysStoppedAnimation(AppColors.bg),
                ),
              ),
              const SizedBox(height: AppDimens.spaceSm),
              Text(
                '${tp.learnedWords} из ${tp.totalWords} слов выучено',
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.onAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Заголовок секции «Темы» + ссылка «Все N».
class _TopicsHeader extends StatelessWidget {
  const _TopicsHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Темы', style: AppTextStyles.title),
        GestureDetector(
          onTap: () => Get.find<HomeController>().openAndRefresh(Routes.topics),
          child: Text(
            'Все $count',
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

/// Карточка темы в списке Главной.
class _TopicTile extends StatelessWidget {
  const _TopicTile({required this.progress});

  final TopicProgress progress;

  @override
  Widget build(BuildContext context) {
    final locked = progress.isLocked;
    final fg = locked ? AppColors.textMuted : AppColors.textPrimary;

    return AppCard(
      onTap: locked ? null : () => _openTopic(progress),
      radius: AppDimens.radiusMd,
      color: AppColors.surface,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
            child: Center(
              child: AppIcon(AppIcons.book,
                  color: locked ? AppColors.textMuted : AppColors.textPrimary,
                  size: AppDimens.iconMd),
            ),
          ),
          const SizedBox(width: AppDimens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(progress.topic.title,
                    style: AppTextStyles.label.copyWith(color: fg)),
                const SizedBox(height: 2),
                Text(_subtitle(progress), style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.spaceSm),
          if (locked)
            AppIcon(AppIcons.lock, color: AppColors.textMuted)
          else
            _PercentBadge(percent: progress.percentInt),
        ],
      ),
    );
  }

  String _subtitle(TopicProgress tp) {
    switch (tp.status) {
      case TopicStatus.locked:
        return 'Откроется позже';
      case TopicStatus.available:
        return 'Новая тема · 0 / ${tp.totalWords} слов';
      case TopicStatus.inProgress:
      case TopicStatus.completed:
        return '${tp.learnedWords} / ${tp.totalWords} слов';
    }
  }
}

/// Кружок с процентом прогресса.
class _PercentBadge extends StatelessWidget {
  const _PercentBadge({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$percent%',
        style: AppTextStyles.caption.copyWith(color: AppColors.accent),
      ),
    );
  }
}

/// Круглая кнопка-иконка (поверхность + обводка).
class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

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
          width: 44,
          height: 44,
          child: Center(child: AppIcon(icon, size: AppDimens.iconMd)),
        ),
      ),
    );
  }
}

/// Открывает обзор темы; по возвращении тихо обновляет Главную.
void _openTopic(TopicProgress tp) {
  Get.find<HomeController>()
      .openAndRefresh(Routes.topicDetail, arguments: tp.topic);
}
