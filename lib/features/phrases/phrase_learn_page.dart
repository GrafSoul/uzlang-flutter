import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/theme.dart';
import '../shared/widgets/widgets.dart';
import 'phrase_learn_controller.dart';

/// Экран «Фразы — Учить» — по макету Figma «09 · Фразы — Учить».
class PhraseLearnPage extends GetView<PhraseLearnController> {
  /// Создаёт экран.
  const PhraseLearnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value || controller.phrases.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              _TopBar(
                title:
                    'Фразы · ${controller.args.topic.title} · ${controller.index.value + 1} / ${controller.phrases.length}',
              ),
              const SizedBox(height: AppDimens.spaceMd),
              _Segments(
                total: controller.phrases.length,
                done: controller.index.value,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimens.spaceLg),
                  child: _PhraseCard(),
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
            child: Center(child: Text(title, style: AppTextStyles.label)),
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

class _PhraseCard extends GetView<PhraseLearnController> {
  @override
  Widget build(BuildContext context) {
    final p = controller.current;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.spaceXl),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.spaceMd,
              vertical: AppDimens.spaceXs,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusBadge),
            ),
            child: Text('ФРАЗА',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1,
                )),
          ),
          const SizedBox(height: AppDimens.spaceMd),
          Text(p.uz, style: AppTextStyles.word, textAlign: TextAlign.center),
          const SizedBox(height: AppDimens.spaceSm),
          Text('[ ${p.reading} ]',
              style: AppTextStyles.reading, textAlign: TextAlign.center),
          const SizedBox(height: AppDimens.spaceLg),
          Container(width: 40, height: 1, color: AppColors.line),
          const SizedBox(height: AppDimens.spaceLg),
          Text(p.ru, style: AppTextStyles.heading, textAlign: TextAlign.center),
          if (p.exampleUz != null) ...[
            const SizedBox(height: AppDimens.spaceLg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimens.spaceMd),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ПРИМЕР',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 1,
                      )),
                  const SizedBox(height: AppDimens.spaceXs),
                  Text(p.exampleUz!, style: AppTextStyles.label),
                  if (p.exampleRu != null) ...[
                    const SizedBox(height: 2),
                    Text(p.exampleRu!, style: AppTextStyles.caption),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: AppDimens.spaceLg),
          _ListenButton(onTap: controller.playAudio),
        ],
      ),
    );
  }
}

class _ListenButton extends StatelessWidget {
  const _ListenButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const StadiumBorder(side: BorderSide(color: AppColors.accent)),
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

class _Actions extends GetView<PhraseLearnController> {
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
