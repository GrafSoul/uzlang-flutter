import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_theme_ext.dart';

/// Сборка [ThemeData] для UzLang из токенов дизайн-системы.
///
/// Тёмная тема — основная. Светлая пока возвращает тёмную как явную заглушку
/// (палитра светлой темы — задача фазы 2-продукт; в профиле выбор уже нарисован).
abstract final class AppTheme {
  AppTheme._();

  /// Тёмная (основная) тема приложения.
  static ThemeData get dark {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      secondary: AppColors.info,
      onSecondary: AppColors.textPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: AppColors.textPrimary,
      outline: AppColors.line,
    );

    final textTheme = const TextTheme(
      displayLarge: AppTextStyles.display,
      titleLarge: AppTextStyles.title,
      titleMedium: AppTextStyles.heading,
      bodyLarge: AppTextStyles.body,
      bodyMedium: AppTextStyles.reading,
      labelLarge: AppTextStyles.label,
      bodySmall: AppTextStyles.caption,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: scheme,
      fontFamily: AppTextStyles.fontFamily,
      textTheme: textTheme,
      dividerColor: AppColors.line,
      splashColor: AppColors.accent.withValues(alpha: 0.12),
      highlightColor: AppColors.accent.withValues(alpha: 0.08),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.heading,
      ),
      extensions: const <ThemeExtension<dynamic>>[AppThemeExt.dark],
    );
  }

  /// Светлая тема — задел (пока зеркалит тёмную). Доводка в фазе 2-продукт.
  static ThemeData get light => dark;
}

/// Ergonomic-доступ к токенам темы из виджетов.
extension AppThemeContext on BuildContext {
  /// Дополнительные цвета DS: `context.colors.surfaceRaised`.
  AppThemeExt get colors => Theme.of(this).extension<AppThemeExt>()!;

  /// Активная [ColorScheme].
  ColorScheme get scheme => Theme.of(this).colorScheme;
}
