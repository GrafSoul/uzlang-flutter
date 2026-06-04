import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Расширение темы для цветов UzLang, которых нет в [ColorScheme].
///
/// Material [ColorScheme] не покрывает все токены дизайн-системы
/// (приподнятая поверхность, тинты, статусные цвета), поэтому они живут здесь.
/// Доступ из виджетов: `Theme.of(context).extension<AppThemeExt>()!`.
@immutable
class AppThemeExt extends ThemeExtension<AppThemeExt> {
  /// Создаёт набор дополнительных цветов темы.
  const AppThemeExt({
    required this.surfaceRaised,
    required this.line,
    required this.accentTint,
    required this.successTint,
    required this.success,
    required this.info,
    required this.textSecondary,
    required this.textMuted,
  });

  /// Приподнятая поверхность (вложенные блоки, активные сегменты).
  final Color surfaceRaised;

  /// Цвет разделителей и тонких обводок.
  final Color line;

  /// Тёмная подложка под акцентом.
  final Color accentTint;

  /// Тёмная подложка под успехом.
  final Color successTint;

  /// Цвет успеха/прогресса.
  final Color success;

  /// Информативный синий.
  final Color info;

  /// Вторичный текст.
  final Color textSecondary;

  /// Приглушённый текст.
  final Color textMuted;

  /// Тёмная (основная) схема — значения из [AppColors].
  static const AppThemeExt dark = AppThemeExt(
    surfaceRaised: AppColors.surfaceRaised,
    line: AppColors.line,
    accentTint: AppColors.accentTint,
    successTint: AppColors.successTint,
    success: AppColors.success,
    info: AppColors.info,
    textSecondary: AppColors.textSecondary,
    textMuted: AppColors.textMuted,
  );

  @override
  AppThemeExt copyWith({
    Color? surfaceRaised,
    Color? line,
    Color? accentTint,
    Color? successTint,
    Color? success,
    Color? info,
    Color? textSecondary,
    Color? textMuted,
  }) {
    return AppThemeExt(
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      line: line ?? this.line,
      accentTint: accentTint ?? this.accentTint,
      successTint: successTint ?? this.successTint,
      success: success ?? this.success,
      info: info ?? this.info,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
    );
  }

  @override
  AppThemeExt lerp(covariant ThemeExtension<AppThemeExt>? other, double t) {
    if (other is! AppThemeExt) return this;
    return AppThemeExt(
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      line: Color.lerp(line, other.line, t)!,
      accentTint: Color.lerp(accentTint, other.accentTint, t)!,
      successTint: Color.lerp(successTint, other.successTint, t)!,
      success: Color.lerp(success, other.success, t)!,
      info: Color.lerp(info, other.info, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
    );
  }
}
