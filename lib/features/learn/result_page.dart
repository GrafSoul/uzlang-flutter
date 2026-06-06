import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/theme/theme.dart';
import '../shared/widgets/widgets.dart';
import '../topic_detail/topic_detail_controller.dart';
import 'result_args.dart';

/// Экран «Результат блока» — по макету Figma «07 · Результат блока».
class ResultPage extends StatelessWidget {
  /// Создаёт экран.
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as ResultArgs;
    final quality = args.accuracy >= 1.0
        ? 'идеально'
        : (args.accuracy >= 0.8
            ? 'отлично'
            : '${args.accuracyPercent}% точность');

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimens.spaceLg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _CheckBadge(),
                      const SizedBox(height: AppDimens.spaceLg),
                      Text('Блок пройден!', style: AppTextStyles.title),
                      const SizedBox(height: AppDimens.spaceSm),
                      Text(
                        '${args.topic.title} · Блок ${args.blockNumber} · $quality',
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimens.spaceXl),
                      _StatsRow(args: args),
                      if (args.unlockedNext) ...[
                        const SizedBox(height: AppDimens.spaceLg),
                        _UnlockBanner(blockNumber: args.blockNumber + 1),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimens.spaceLg),
              child: Column(
                children: [
                  if (args.unlockedNext && args.nextArgs != null)
                    PrimaryButton(
                      label: 'Следующий блок',
                      onPressed: () => Get.offNamed<void>(
                        args.isPhrase ? Routes.phraseLearn : Routes.learn,
                        arguments: args.nextArgs,
                      ),
                    ),
                  const SizedBox(height: AppDimens.spaceMd),
                  GestureDetector(
                    onTap: _backToTopic,
                    child: Text(
                      'Вернуться в тему',
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _backToTopic() {
    Get.until((route) => route.settings.name == Routes.topicDetail);
    if (Get.isRegistered<TopicDetailController>()) {
      Get.find<TopicDetailController>().load();
    }
  }
}

/// Большой кружок-галочка с подсветкой.
class _CheckBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accentTint,
        border: Border.all(color: AppColors.accent, width: 2),
      ),
      child: Center(
        child: Container(
          width: 68,
          height: 68,
          decoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: AppIcon(AppIcons.check, color: AppColors.bg, size: 32),
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.args});

  final ResultArgs args;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: AppIcons.star,
            iconColor: AppColors.accent,
            value: '+${args.xpEarned}',
            label: 'XP',
          ),
        ),
        const SizedBox(width: AppDimens.spaceMd),
        Expanded(
          child: _StatCard(
            icon: AppIcons.target,
            iconColor: AppColors.success,
            value: '${args.accuracyPercent}%',
            label: 'точность',
          ),
        ),
        const SizedBox(width: AppDimens.spaceMd),
        Expanded(
          child: _StatCard(
            icon: AppIcons.flame,
            iconColor: AppColors.accent,
            value: '${args.streak}',
            label: 'дней',
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

class _UnlockBanner extends StatelessWidget {
  const _UnlockBanner({required this.blockNumber});

  final int blockNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spaceLg,
        vertical: AppDimens.spaceMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.successTint,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.success),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppIcon(AppIcons.check,
              color: AppColors.success, size: AppDimens.iconMd),
          const SizedBox(width: AppDimens.spaceSm),
          Text(
            'Открыт Блок $blockNumber',
            style: AppTextStyles.label.copyWith(color: AppColors.success),
          ),
        ],
      ),
    );
  }
}
