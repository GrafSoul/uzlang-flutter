import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/theme.dart';
import '../shared/widgets/widgets.dart';
import 'phrase_test_controller.dart';

/// Экран «Фразы — Тест» — по макету Figma «10 · Фразы — Тест (собери фразу)».
class PhraseTestPage extends GetView<PhraseTestController> {
  /// Создаёт экран.
  const PhraseTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value || controller.questions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              _TopBar(
                index: controller.index.value + 1,
                total: controller.questions.length,
                lives: controller.lives.value,
              ),
              const SizedBox(height: AppDimens.spaceMd),
              _Segments(
                total: controller.questions.length,
                done: controller.index.value +
                    (controller.revealed.value ? 1 : 0),
              ),
              const SizedBox(height: AppDimens.spaceLg),
              Text('Переведи на узбекский', style: AppTextStyles.caption),
              const SizedBox(height: AppDimens.spaceMd),
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppDimens.spaceLg),
                  children: [
                    _PromptCard(),
                    const SizedBox(height: AppDimens.spaceLg),
                    _Label('ТВОЙ ОТВЕТ'),
                    const SizedBox(height: AppDimens.spaceSm),
                    _AnswerArea(),
                    const SizedBox(height: AppDimens.spaceLg),
                    _Label('СЛОВА'),
                    const SizedBox(height: AppDimens.spaceSm),
                    _WordBank(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimens.spaceLg),
                child: PrimaryButton(
                  label: controller.revealed.value ? 'Продолжить' : 'Проверить',
                  onPressed: controller.revealed.value
                      ? controller.next
                      : (controller.canCheck ? controller.check : null),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.index,
    required this.total,
    required this.lives,
  });

  final int index;
  final int total;
  final int lives;

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
              child: Text('Собери фразу · $index / $total',
                  style: AppTextStyles.label),
            ),
          ),
          Container(
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
                const AppIcon(AppIcons.heart,
                    color: AppColors.error, size: AppDimens.iconSm),
                const SizedBox(width: AppDimens.spaceXs),
                Text('$lives', style: AppTextStyles.label),
              ],
            ),
          ),
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
              height: 6,
              margin: EdgeInsets.only(right: i == total - 1 ? 0 : 4),
              decoration: BoxDecoration(
                color: i < done ? AppColors.success : AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.caption
          .copyWith(color: AppColors.textMuted, letterSpacing: 1),
    );
  }
}

class _PromptCard extends GetView<PhraseTestController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.spaceXl),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      ),
      child: Column(
        children: [
          Text(controller.question.phrase.ru,
              style: AppTextStyles.heading, textAlign: TextAlign.center),
          const SizedBox(height: AppDimens.spaceMd),
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

class _AnswerArea extends GetView<PhraseTestController> {
  @override
  Widget build(BuildContext context) {
    final remaining =
        controller.question.correctTokens.length - controller.answer.length;
    final borderColor = controller.revealed.value
        ? (controller.isCorrect.value ? AppColors.success : AppColors.error)
        : AppColors.line;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.all(AppDimens.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: borderColor),
      ),
      child: Wrap(
        spacing: AppDimens.spaceSm,
        runSpacing: AppDimens.spaceSm,
        children: [
          for (var pos = 0; pos < controller.answer.length; pos++)
            _Chip(
              label: controller.question.bank[controller.answer[pos]],
              filled: true,
              onTap: () => controller.removeWord(pos),
            ),
          for (var i = 0; i < remaining; i++) const _EmptySlot(),
        ],
      ),
    );
  }
}

class _WordBank extends GetView<PhraseTestController> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimens.spaceSm,
      runSpacing: AppDimens.spaceSm,
      children: [
        for (var i = 0; i < controller.question.bank.length; i++)
          _Chip(
            label: controller.question.bank[i],
            used: controller.isUsed(i),
            onTap: () => controller.pickWord(i),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.onTap,
    this.filled = false,
    this.used = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;
  final bool used;

  @override
  Widget build(BuildContext context) {
    final bg = filled ? AppColors.surfaceRaised : AppColors.surface;
    final fg = used ? AppColors.textMuted : AppColors.textPrimary;
    return Opacity(
      opacity: used ? 0.4 : 1,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        child: InkWell(
          onTap: used ? null : onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.spaceMd,
              vertical: AppDimens.spaceSm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              border: Border.all(color: AppColors.line),
            ),
            child: Text(label, style: AppTextStyles.label.copyWith(color: fg)),
          ),
        ),
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        border: Border.all(
          color: AppColors.line,
          style: BorderStyle.solid,
          width: 1,
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
