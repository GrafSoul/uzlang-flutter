import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../domain/entities/achievement.dart';
import '../shared/widgets/app_bottom_nav.dart';
import '../shared/widgets/widgets.dart';
import 'progress_controller.dart';

/// Экран «Прогресс» — по макету Figma (13 данные / 13b пусто).
class ProgressPage extends GetView<ProgressController> {
  /// Создаёт экран.
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppBottomNav(current: AppTab.progress),
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!controller.hasProgress) {
            return const _EmptyState();
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.spaceLg,
              AppDimens.spaceLg,
              AppDimens.spaceLg,
              AppDimens.spaceXl,
            ),
            children: [
              Text('Прогресс', style: AppTextStyles.title),
              const SizedBox(height: AppDimens.spaceLg),
              const _StreakHero(),
              const SizedBox(height: AppDimens.spaceMd),
              const _StatsGrid(),
              const SizedBox(height: AppDimens.spaceXl),
              const _SectionLabel('АКТИВНОСТЬ ЗА НЕДЕЛЮ · минуты'),
              const SizedBox(height: AppDimens.spaceMd),
              const _WeekChart(),
              const SizedBox(height: AppDimens.spaceXl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Достижения', style: AppTextStyles.title),
                  Text('Все ${controller.achievements.length}',
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: AppDimens.spaceMd),
              const _AchievementsRow(),
            ],
          );
        }),
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
          .copyWith(color: AppColors.textMuted, letterSpacing: 0.5),
    );
  }
}

class _StreakHero extends GetView<ProgressController> {
  const _StreakHero();

  @override
  Widget build(BuildContext context) {
    final s = controller.stats.value;
    return Container(
      padding: const EdgeInsets.all(AppDimens.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accentTint,
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                ),
                child: const Center(
                  child: AppIcon(AppIcons.flame,
                      color: AppColors.accent, size: AppDimens.iconLg),
                ),
              ),
              const SizedBox(width: AppDimens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${s.streakCurrent} дней подряд',
                        style: AppTextStyles.heading),
                    Text('Лучшая серия: ${s.streakBest} дней',
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceLg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final d in controller.weekDays) _DayDot(cell: d),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({required this.cell});

  final DayCell cell;

  @override
  Widget build(BuildContext context) {
    if (cell.isDone) {
      return Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
            color: AppColors.accent, shape: BoxShape.circle),
        child: const Center(
          child: AppIcon(AppIcons.check, color: AppColors.bg, size: 16),
        ),
      );
    }
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: cell.isToday ? AppColors.accent : AppColors.line,
          width: cell.isToday ? 2 : 1,
        ),
      ),
      child: Center(
        child: Text(cell.label[0],
            style: AppTextStyles.caption.copyWith(
              color: cell.isToday ? AppColors.accent : AppColors.textMuted,
            )),
      ),
    );
  }
}

class _StatsGrid extends GetView<ProgressController> {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    final s = controller.stats.value;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: AppIcons.book,
                iconColor: AppColors.accent,
                value: '${controller.learnedWords.value}',
                label: 'слов выучено',
              ),
            ),
            const SizedBox(width: AppDimens.spaceMd),
            Expanded(
              child: _StatCard(
                icon: AppIcons.target,
                iconColor: AppColors.success,
                value: '${controller.accuracyPercent}%',
                label: 'точность',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.spaceMd),
        Row(
          children: [
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
                icon: AppIcons.chart,
                iconColor: AppColors.info,
                value: controller.timeLabel,
                label: 'в приложении',
              ),
            ),
          ],
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
      padding: const EdgeInsets.all(AppDimens.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Row(
        children: [
          AppIcon(icon, color: iconColor, size: AppDimens.iconMd),
          const SizedBox(width: AppDimens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: AppTextStyles.heading),
                Text(label, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekChart extends GetView<ProgressController> {
  const _WeekChart();

  @override
  Widget build(BuildContext context) {
    final days = controller.weekDays;
    final todayIdx = DateTime.now().weekday - 1;
    final todayMin = controller.todayMinutes;
    final maxMin = todayMin < 10 ? 10 : todayMin;
    return Container(
      height: 140,
      padding: const EdgeInsets.all(AppDimens.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 8 + (i == todayIdx ? (todayMin / maxMin) * 70 : 0),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color:
                          i == todayIdx ? AppColors.accent : AppColors.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: AppDimens.spaceSm),
                  Text(days[i].label,
                      style: AppTextStyles.caption.copyWith(
                        color: i == todayIdx
                            ? AppColors.accent
                            : AppColors.textMuted,
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AchievementsRow extends GetView<ProgressController> {
  const _AchievementsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final a in controller.achievements) ...[
          _AchievementBadge(achievement: a),
          if (a != controller.achievements.last)
            const SizedBox(width: AppDimens.spaceMd),
        ],
      ],
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.unlocked;
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: unlocked ? AppColors.accentTint : AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(
              color: unlocked ? AppColors.accent : AppColors.line,
            ),
          ),
          child: Center(
            child: AppIcon(
              unlocked ? achievement.iconName : AppIcons.lock,
              color: unlocked ? AppColors.accent : AppColors.textMuted,
              size: AppDimens.iconLg,
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
    return Padding(
      padding: const EdgeInsets.all(AppDimens.spaceLg),
      child: Column(
        children: [
          const SizedBox(height: AppDimens.spaceLg),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Прогресс', style: AppTextStyles.title),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    ),
                    child: const Center(
                      child: AppIcon(AppIcons.chart,
                          color: AppColors.textMuted, size: 32),
                    ),
                  ),
                  const SizedBox(height: AppDimens.spaceLg),
                  Text('Здесь появится прогресс', style: AppTextStyles.title),
                  const SizedBox(height: AppDimens.spaceSm),
                  Text(
                    'Пройди первый урок — и увидишь свой\nstreak, точность, активность и достижения.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyRegular
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppDimens.spaceXl),
                  SizedBox(
                    width: 240,
                    child: PrimaryButton(
                      label: 'Начать первый урок',
                      iconName: AppIcons.book,
                      onPressed: () => Get.offAllNamed<void>(Routes.home),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
