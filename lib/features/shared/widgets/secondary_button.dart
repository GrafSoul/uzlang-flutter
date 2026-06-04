import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import 'app_icon.dart';

/// Вторичная кнопка (поверхность с обводкой, без заливки акцентом).
///
/// Для второстепенных действий рядом с [PrimaryButton] («Пропустить», «Назад»).
class SecondaryButton extends StatelessWidget {
  /// Создаёт вторичную кнопку с подписью [label].
  const SecondaryButton({
    required this.label,
    required this.onPressed,
    this.iconName,
    this.expand = true,
    super.key,
  });

  /// Текст кнопки.
  final String label;

  /// Обработчик нажатия. `null` делает кнопку неактивной.
  final VoidCallback? onPressed;

  /// Имя SVG-иконки слева от текста (из [AppIcons]).
  final String? iconName;

  /// Растягивать на всю доступную ширину.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null;
    final Color fg = disabled ? AppColors.textMuted : AppColors.textPrimary;

    return SizedBox(
      width: expand ? double.infinity : null,
      height: AppDimens.buttonHeight,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (iconName != null) ...[
                  AppIcon(iconName!, size: AppDimens.iconMd, color: fg),
                  const SizedBox(width: AppDimens.spaceSm),
                ],
                Text(label, style: AppTextStyles.button.copyWith(color: fg)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
