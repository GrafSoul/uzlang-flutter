import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_theme_ext.dart';

/// Сборка [ThemeData] для UzLang из токенов дизайн-системы.
///
/// Тема строится из АКТИВНОЙ палитры [AppColors] (тёмной или светлой).
/// Переключение: `AppColors.apply(...)` → [applySystemBars] →
/// `Get.forceAppUpdate()` (полный ребилд дерева).
abstract final class AppTheme {
  AppTheme._();

  /// Тема из активной палитры [AppColors].
  static ThemeData get current {
    final scheme = ColorScheme(
      brightness: AppColors.isDark ? Brightness.dark : Brightness.light,
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

    final textTheme = TextTheme(
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
      brightness: scheme.brightness,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: scheme,
      fontFamily: AppTextStyles.fontFamily,
      textTheme: textTheme,
      dividerColor: AppColors.line,
      splashColor: AppColors.accent.withValues(alpha: 0.12),
      highlightColor: AppColors.accent.withValues(alpha: 0.08),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.heading,
      ),
      extensions: <ThemeExtension<dynamic>>[AppThemeExt.current],
    );
  }
}

/// Красит системные бары (статус и навигацию) под активную палитру.
void applySystemBars() {
  final iconBrightness =
      AppColors.isDark ? Brightness.light : Brightness.dark;
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: const Color(0x00000000),
      statusBarIconBrightness: iconBrightness,
      statusBarBrightness:
          AppColors.isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: AppColors.bg,
      systemNavigationBarDividerColor: AppColors.bg,
      systemNavigationBarIconBrightness: iconBrightness,
    ),
  );
}
