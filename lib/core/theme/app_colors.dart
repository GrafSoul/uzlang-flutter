import 'package:flutter/material.dart';

/// Цветовые токены UzLang (премиум-тёмная палитра).
///
/// Зеркало Figma-переменных `UzLang / Colors` (режим Dark) 1:1. Это
/// единственный источник правды по цветам: виджеты берут цвета только отсюда
/// либо через [Theme]/`AppThemeExt`, без хардкод-хексов в коде экранов.
abstract final class AppColors {
  AppColors._();

  // ── Поверхности ───────────────────────────────────────────────
  /// Фон приложения (самый тёмный слой).
  static const Color bg = Color(0xFF0E0F13);

  /// Базовая поверхность карточек/листов.
  static const Color surface = Color(0xFF1A1C22);

  /// Приподнятая поверхность (вложенные блоки, активные сегменты).
  static const Color surfaceRaised = Color(0xFF22252E);

  /// Цвет разделителей и тонких обводок.
  static const Color line = Color(0xFF2C2F38);

  // ── Текст ─────────────────────────────────────────────────────
  /// Основной текст (заголовки, слова).
  static const Color textPrimary = Color(0xFFF4F5F7);

  /// Вторичный текст (подписи, чтение-кириллица).
  static const Color textSecondary = Color(0xFF9AA0AB);

  /// Приглушённый текст (плейсхолдеры, неактивное).
  static const Color textMuted = Color(0xFF5C616B);

  // ── Акцент и статусы ──────────────────────────────────────────
  /// Терракота-оранж — основной акцент (узбекский колорит на тёмном).
  static const Color accent = Color(0xFFFF8A3D);

  /// Тёплый травяной зелёный — успех/прогресс.
  static const Color success = Color(0xFF5BC46B);

  /// Ошибка/опасность (потеря жизни, неверный ответ).
  static const Color error = Color(0xFFFF5C5C);

  /// Информативный синий (интервал «Лёгко» в SR, инфо-состояния).
  static const Color info = Color(0xFF5B9DFF);

  // ── Тинты (подложки под статусами) ────────────────────────────
  /// Тёмная подложка под акцентом (бейджи, выделенные элементы).
  static const Color accentTint = Color(0xFF1F1710);

  /// Тёмная подложка под успехом.
  static const Color successTint = Color(0xFF18291C);

  // ── Контраст ──────────────────────────────────────────────────
  /// Текст/иконка поверх оранжевого акцента (= [bg], как в макете).
  static const Color onAccent = bg;
}
