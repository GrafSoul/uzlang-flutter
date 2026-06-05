/// Агрегированная статистика пользователя (read-model для UI).
class UserStats {
  /// Создаёт статистику.
  const UserStats({
    required this.xp,
    required this.streakCurrent,
    required this.streakBest,
    this.lastActiveDay,
  });

  /// Накопленный опыт.
  final int xp;

  /// Текущая серия дней.
  final int streakCurrent;

  /// Лучшая серия дней.
  final int streakBest;

  /// Последний активный день (`yyyy-MM-dd`).
  final String? lastActiveDay;

  /// Пустая статистика нового пользователя.
  static const UserStats empty =
      UserStats(xp: 0, streakCurrent: 0, streakBest: 0);
}
