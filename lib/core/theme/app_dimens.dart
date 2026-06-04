/// Размерные токены UzLang: отступы, радиусы скругления, размеры иконок.
///
/// Отступы — на 4-pt сетке (как в Figma-DS). Используются вместо «магических
/// чисел» в экранах: `padding: EdgeInsets.all(AppDimens.spaceLg)`.
abstract final class AppDimens {
  AppDimens._();

  // ── Отступы (4-pt сетка) ──────────────────────────────────────
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceLg = 16;
  static const double spaceXl = 24;
  static const double spaceXxl = 32;

  // ── Радиусы скругления (значения из Figma-DS) ─────────────────
  /// Бейджи, оверлайны.
  static const double radiusBadge = 11;

  /// Чипы, мелкие элементы.
  static const double radiusSm = 14;

  /// Кнопки, карточки-строки тем (CTA = 18 в макете).
  static const double radiusMd = 18;

  /// Карточки (hero, стандартные блоки).
  static const double radiusLg = 20;

  /// Карточка слова, обложки.
  static const double radiusCard = 24;

  /// Крупные карточки/листы (большая карточка урока, bottom sheet).
  static const double radiusXl = 28;

  // ── Размеры иконок ────────────────────────────────────────────
  /// Мелкая иконка (инлайн в подписях).
  static const double iconSm = 20;

  /// Базовая иконка интерфейса (SVG line 24×24).
  static const double iconMd = 24;

  /// Увеличенная иконка (огонёк/звезда/мишень/звук).
  static const double iconLg = 26;

  // ── Прочее ────────────────────────────────────────────────────
  /// Высота основной кнопки.
  static const double buttonHeight = 56;

  /// Минимальная зона нажатия (accessibility).
  static const double hitTarget = 48;
}
