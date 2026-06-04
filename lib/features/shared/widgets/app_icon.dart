import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';

/// SVG line-иконка из набора дизайн-системы (`assets/icons/*.svg`).
///
/// Иконки экспортированы из Figma-DS (24×24 в кадре 28, stroke 2). Цвет
/// перекрашивается через [ColorFilter] — по умолчанию [AppColors.textPrimary].
/// Имена брать из [AppIcons], чтобы не опечататься.
class AppIcon extends StatelessWidget {
  /// Создаёт иконку по имени файла [name] (без расширения).
  const AppIcon(
    this.name, {
    this.size = AppDimens.iconMd,
    this.color,
    super.key,
  });

  /// Имя SVG-файла без пути и расширения (например `chevron_right`).
  final String name;

  /// Размер стороны иконки.
  final double size;

  /// Цвет перекраски. `null` → [AppColors.textPrimary].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/$name.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
        color ?? AppColors.textPrimary,
        BlendMode.srcIn,
      ),
    );
  }
}

/// Имена доступных иконок набора (зеркало `assets/icons/*.svg`).
abstract final class AppIcons {
  AppIcons._();

  static const String book = 'book';
  static const String cart = 'cart';
  static const String chart = 'chart';
  static const String check = 'check';
  static const String chevronLeft = 'chevron_left';
  static const String chevronRight = 'chevron_right';
  static const String clock = 'clock';
  static const String close = 'close';
  static const String flame = 'flame';
  static const String heart = 'heart';
  static const String info = 'info';
  static const String lock = 'lock';
  static const String moon = 'moon';
  static const String pencil = 'pencil';
  static const String play = 'play';
  static const String refresh = 'refresh';
  static const String settings = 'settings';
  static const String star = 'star';
  static const String target = 'target';
  static const String user = 'user';
  static const String volume = 'volume';
}
