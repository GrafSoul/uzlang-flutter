import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/theme.dart';
import '../shared/widgets/widgets.dart';
import 'home_controller.dart';

/// Главный экран: список учебных тем (данные из БД через репозиторий).
class HomePage extends GetView<HomeController> {
  /// Создаёт главный экран.
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UzLang')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final topics = controller.topics;
        return ListView.separated(
          padding: const EdgeInsets.all(AppDimens.spaceLg),
          itemCount: topics.length + 1,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppDimens.spaceMd),
          itemBuilder: (context, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.spaceXs),
                child: Text('Темы · ${topics.length}',
                    style: AppTextStyles.caption),
              );
            }
            final topic = topics[i - 1];
            return AppCard(
              onTap: () {},
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.accentTint,
                      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                    ),
                    child: const Center(
                      child: AppIcon(AppIcons.book,
                          color: AppColors.accent, size: AppDimens.iconMd),
                    ),
                  ),
                  const SizedBox(width: AppDimens.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(topic.title, style: AppTextStyles.label),
                        const SizedBox(height: 2),
                        Text(
                          topic.description,
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.spaceSm),
                  AppIcon(AppIcons.chevronRight,
                      color: context.colors.textMuted),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
