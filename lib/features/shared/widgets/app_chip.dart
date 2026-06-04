import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import 'app_icon.dart';

/// Компактный тег-чип (статус, фильтр, уровень).
///
/// В невыбранном состоянии — поверхность с обводкой; в выбранном — тинт с
/// акцентным текстом. Опциональная SVG-иконка слева.
class AppChip extends StatelessWidget {
  /// Создаёт чип с подписью [label].
  const AppChip({
    required this.label,
    this.iconName,
    this.selected = false,
    this.onTap,
    super.key,
  });

  /// Текст чипа.
  final String label;

  /// Имя SVG-иконки слева (из [AppIcons]).
  final String? iconName;

  /// Выбранное состояние (акцентный тинт).
  final bool selected;

  /// Обработчик нажатия.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color fg = selected ? AppColors.accent : AppColors.textSecondary;
    final Color bg = selected ? AppColors.accentTint : AppColors.surface;
    final Color border = selected ? AppColors.accent : AppColors.line;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.spaceMd,
            vertical: AppDimens.spaceSm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconName != null) ...[
                AppIcon(iconName!, size: AppDimens.iconSm, color: fg),
                const SizedBox(width: AppDimens.spaceXs),
              ],
              Text(label, style: AppTextStyles.caption.copyWith(color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}
