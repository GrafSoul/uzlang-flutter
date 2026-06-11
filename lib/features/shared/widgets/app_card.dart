import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';

/// Базовая карточка-поверхность UzLang.
///
/// Скруглённая поверхность с опциональной обводкой и нажатием. Используется как
/// контейнер для тем, блоков, элементов списков.
class AppCard extends StatelessWidget {
  /// Создаёт карточку с содержимым [child].
  const AppCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppDimens.spaceLg),
    this.radius = AppDimens.radiusLg,
    this.color,
    this.bordered = true,
    super.key,
  });

  /// Содержимое карточки.
  final Widget child;

  /// Обработчик нажатия. Если `null` — карточка не интерактивна.
  final VoidCallback? onTap;

  /// Внутренние отступы.
  final EdgeInsetsGeometry padding;

  /// Радиус скругления.
  final double radius;

  /// Цвет поверхности (по умолчанию — [AppColors.surface]).
  final Color? color;

  /// Рисовать ли тонкую обводку линией.
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(radius);

    return Material(
      color: color ?? AppColors.surface,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: bordered ? Border.all(color: AppColors.line) : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
