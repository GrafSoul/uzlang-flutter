import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Типографическая шкала UzLang — **1:1 с Figma text-styles `UzLang/*`**.
///
/// Значения (размер / line-height / начертание) выгружены из переменных файла
/// и зафиксированы точно. `height` = lineHeightPx / fontSize. Веса Inter:
/// Bold = w700, Semi Bold = w600, Medium = w500, Regular = w400. Цвет здесь —
/// разумный дефолт; на конкретных экранах перекрывается по слою.
abstract final class AppTextStyles {
  AppTextStyles._();

  /// Семейство шрифта по умолчанию для всего приложения.
  static const String fontFamily = 'Inter';

  /// Display / 44 Bold (lh 52). Крупные заголовки онбординга.
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 44,
    height: 52 / 44,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Word / 40 Bold (lh 48). Слово на карточке (узбекская латиница).
  static const TextStyle word = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    height: 48 / 40,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Title / 28 Bold (lh 34). Заголовок экрана.
  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Heading / 24 Bold (lh 30). Заголовок секции/карточки.
  static const TextStyle heading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 30 / 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Subheading / 22 Bold (lh 28).
  static const TextStyle subheading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Body / 16 Medium (lh 22). Основной текст.
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  /// Body / 15 Regular (lh 22). Вторичный абзац.
  static const TextStyle bodyRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Reading / 16 Regular (lh 22). Кириллица-чтение под словом.
  static const TextStyle reading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Label / 14 Semi Bold (lh 18). Подписи, теги.
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 18 / 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Label / 13 Semi Bold (lh 16). Мелкие подписи.
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 16 / 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Caption / 11 Bold (lh 14). Метаданные, счётчики, оверлайны.
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
  );

  /// Текст основной кнопки — Inter Bold 16 (как CTA в макете).
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1,
    fontWeight: FontWeight.w700,
    color: AppColors.onAccent,
  );
}
