/// Достижение (read-model для геймификации).
class Achievement {
  /// Создаёт достижение.
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.unlocked,
  });

  /// Стабильный идентификатор.
  final String id;

  /// Название.
  final String title;

  /// Условие/описание.
  final String description;

  /// Имя SVG-иконки (из набора `assets/icons`).
  final String iconName;

  /// Получено ли достижение.
  final bool unlocked;
}
