import 'package:flutter/material.dart';

/// Набор цветовых токенов одной темы.
class _Palette {
  const _Palette({
    required this.bg,
    required this.surface,
    required this.surfaceRaised,
    required this.line,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.success,
    required this.error,
    required this.info,
    required this.accentTint,
    required this.successTint,
    required this.onAccent,
  });

  final Color bg;
  final Color surface;
  final Color surfaceRaised;
  final Color line;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color success;
  final Color error;
  final Color info;
  final Color accentTint;
  final Color successTint;
  final Color onAccent;
}

/// Премиум-тёмная палитра — зеркало Figma-переменных `UzLang / Colors` 1:1.
const _Palette _dark = _Palette(
  bg: Color(0xFF0E0F13),
  surface: Color(0xFF1A1C22),
  surfaceRaised: Color(0xFF22252E),
  line: Color(0xFF2C2F38),
  textPrimary: Color(0xFFF4F5F7),
  textSecondary: Color(0xFF9AA0AB),
  textMuted: Color(0xFF5C616B),
  accent: Color(0xFFFF8A3D),
  success: Color(0xFF5BC46B),
  error: Color(0xFFFF5C5C),
  info: Color(0xFF5B9DFF),
  accentTint: Color(0xFF1F1710),
  successTint: Color(0xFF18291C),
  onAccent: Color(0xFF0E0F13),
);

/// Светлая палитра — производная от тёмной (в Figma светлой нет; собрана
/// по тем же ролям: акцент и контраст на акценте сохранены).
const _Palette _light = _Palette(
  bg: Color(0xFFF4F5F8),
  surface: Color(0xFFEAEDF2),
  surfaceRaised: Color(0xFFFFFFFF),
  line: Color(0xFFDCE0E8),
  textPrimary: Color(0xFF15171C),
  textSecondary: Color(0xFF5B6271),
  textMuted: Color(0xFF9AA1AD),
  accent: Color(0xFFFF8A3D),
  success: Color(0xFF3FA254),
  error: Color(0xFFE04E4E),
  info: Color(0xFF3D74D9),
  accentTint: Color(0xFFFFEDE0),
  successTint: Color(0xFFE4F4E7),
  onAccent: Color(0xFF0E0F13),
);

/// Цветовые токены UzLang с переключаемой темой.
///
/// Единственный источник правды по цветам: виджеты берут цвета только отсюда.
/// Активная палитра меняется через [apply] (выбор темы в профиле) — после
/// смены нужен полный ребилд дерева (`Get.forceAppUpdate`).
abstract final class AppColors {
  AppColors._();

  static _Palette _p = _dark;

  /// Активна ли тёмная палитра.
  static bool get isDark => identical(_p, _dark);

  /// Применяет палитру по режиму [mode]; для [ThemeMode.system] использует
  /// [platform] (яркость системы).
  static void apply(ThemeMode mode, {Brightness platform = Brightness.dark}) {
    final dark = switch (mode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => platform == Brightness.dark,
    };
    _p = dark ? _dark : _light;
  }

  // ── Поверхности ───────────────────────────────────────────────
  /// Фон приложения (самый глубокий слой).
  static Color get bg => _p.bg;

  /// Базовая поверхность карточек/листов.
  static Color get surface => _p.surface;

  /// Приподнятая поверхность (вложенные блоки, активные сегменты).
  static Color get surfaceRaised => _p.surfaceRaised;

  /// Цвет разделителей и тонких обводок.
  static Color get line => _p.line;

  // ── Текст ─────────────────────────────────────────────────────
  /// Основной текст (заголовки, слова).
  static Color get textPrimary => _p.textPrimary;

  /// Вторичный текст (подписи, чтение-кириллица).
  static Color get textSecondary => _p.textSecondary;

  /// Приглушённый текст (плейсхолдеры, неактивное).
  static Color get textMuted => _p.textMuted;

  // ── Акцент и статусы ──────────────────────────────────────────
  /// Терракота-оранж — основной акцент (узбекский колорит).
  static Color get accent => _p.accent;

  /// Тёплый травяной зелёный — успех/прогресс.
  static Color get success => _p.success;

  /// Ошибка/опасность (потеря жизни, неверный ответ).
  static Color get error => _p.error;

  /// Информативный синий (интервал «Лёгко» в SR, инфо-состояния).
  static Color get info => _p.info;

  // ── Тинты (подложки под статусами) ────────────────────────────
  /// Подложка под акцентом (бейджи, выделенные элементы).
  static Color get accentTint => _p.accentTint;

  /// Подложка под успехом.
  static Color get successTint => _p.successTint;

  // ── Контраст ──────────────────────────────────────────────────
  /// Текст/иконка поверх оранжевого акцента (тёмный в обеих темах).
  static Color get onAccent => _p.onAccent;
}
