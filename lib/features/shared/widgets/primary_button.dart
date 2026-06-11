import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import 'app_icon.dart';

/// Основная кнопка действия (акцент-оранж, заливка).
///
/// На всю ширину по умолчанию. Поддерживает SVG-иконку слева и состояние
/// загрузки (показывает спиннер и блокирует нажатие).
class PrimaryButton extends StatelessWidget {
  /// Создаёт основную кнопку с подписью [label].
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.iconName,
    this.isLoading = false,
    this.expand = true,
    super.key,
  });

  /// Текст кнопки.
  final String label;

  /// Обработчик нажатия. `null` делает кнопку неактивной.
  final VoidCallback? onPressed;

  /// Имя SVG-иконки слева от текста (из [AppIcons]).
  final String? iconName;

  /// Показывать спиннер вместо содержимого и блокировать нажатие.
  final bool isLoading;

  /// Растягивать на всю доступную ширину.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null || isLoading;

    final Widget child = isLoading
        ? SizedBox(
            width: AppDimens.iconMd,
            height: AppDimens.iconMd,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.onAccent,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconName != null) ...[
                AppIcon(iconName!,
                    size: AppDimens.iconMd, color: AppColors.onAccent),
                const SizedBox(width: AppDimens.spaceSm),
              ],
              Text(label, style: AppTextStyles.button),
            ],
          );

    return SizedBox(
      width: expand ? double.infinity : null,
      height: AppDimens.buttonHeight,
      child: Material(
        color: disabled
            ? AppColors.accent.withValues(alpha: 0.4)
            : AppColors.accent,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          child: Center(child: child),
        ),
      ),
    );
  }
}
