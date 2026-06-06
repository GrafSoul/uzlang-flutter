import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/theme/theme.dart';
import '../shared/widgets/widgets.dart';
import 'lesson_args.dart';

/// Экран «Нет жизней» — по макету Figma «14 · Нет жизней».
class NoLivesPage extends StatelessWidget {
  /// Создаёт экран.
  const NoLivesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as LessonArgs;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.spaceLg),
                child: _CircleBtn(
                  icon: AppIcons.close,
                  onTap: () => _exit(),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.spaceLg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          AppIcon(AppIcons.heart,
                              color: AppColors.textMuted, size: 28),
                          SizedBox(width: AppDimens.spaceMd),
                          AppIcon(AppIcons.heart,
                              color: AppColors.textMuted, size: 28),
                          SizedBox(width: AppDimens.spaceMd),
                          AppIcon(AppIcons.heart,
                              color: AppColors.textMuted, size: 28),
                        ],
                      ),
                      const SizedBox(height: AppDimens.spaceLg),
                      Text('Жизни закончились', style: AppTextStyles.title),
                      const SizedBox(height: AppDimens.spaceSm),
                      Text(
                        'В тесте можно ошибаться 3 раза.\nЖизни восстановятся со временем.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyRegular
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppDimens.spaceLg),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.spaceLg,
                          vertical: AppDimens.spaceMd,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusXl),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const AppIcon(AppIcons.clock,
                                color: AppColors.accent,
                                size: AppDimens.iconSm),
                            const SizedBox(width: AppDimens.spaceSm),
                            Text('Новая жизнь через 24:00',
                                style: AppTextStyles.label),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimens.spaceLg),
              child: Column(
                children: [
                  PrimaryButton(
                    label: 'Повторить пройденное',
                    iconName: AppIcons.refresh,
                    onPressed: () =>
                        Get.offNamed<void>(Routes.learn, arguments: args),
                  ),
                  const SizedBox(height: AppDimens.spaceMd),
                  GestureDetector(
                    onTap: _exit,
                    child: Text(
                      'Выйти из теста',
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

  void _exit() {
    Get.until((route) => route.settings.name == Routes.topicDetail);
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
