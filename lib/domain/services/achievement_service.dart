import '../entities/achievement.dart';
import '../entities/user_stats.dart';

/// Вычисляет достижения пользователя из статистики (XP, серия дней).
///
/// Чистый сервис: список достижений фиксирован, флаг `unlocked` считается по
/// порогам. Хранить ничего не нужно — состояние выводится из [UserStats].
class AchievementService {
  /// Создаёт сервис.
  const AchievementService();

  /// Возвращает все достижения с актуальным статусом для статистики [s].
  List<Achievement> evaluate(UserStats s) {
    return [
      Achievement(
        id: 'first_block',
        title: 'Первый шаг',
        description: 'Пройди первый блок',
        iconName: 'play',
        unlocked: s.xp >= 50,
      ),
      Achievement(
        id: 'xp_100',
        title: 'Сотня',
        description: 'Набери 100 XP',
        iconName: 'star',
        unlocked: s.xp >= 100,
      ),
      Achievement(
        id: 'xp_500',
        title: 'Знаток',
        description: 'Набери 500 XP',
        iconName: 'star',
        unlocked: s.xp >= 500,
      ),
      Achievement(
        id: 'streak_3',
        title: 'Втянулся',
        description: '3 дня подряд',
        iconName: 'flame',
        unlocked: s.streakBest >= 3,
      ),
      Achievement(
        id: 'streak_7',
        title: 'Неделя',
        description: '7 дней подряд',
        iconName: 'flame',
        unlocked: s.streakBest >= 7,
      ),
    ];
  }

  /// Сколько достижений получено.
  int unlockedCount(UserStats s) => evaluate(s).where((a) => a.unlocked).length;
}
