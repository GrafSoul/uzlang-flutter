import 'dart:math';

import '../entities/user_stats.dart';
import '../repositories/progress_repository.dart';

/// Геймификация: начисление XP и ведение серии дней (streak).
class GamificationService {
  /// Создаёт сервис.
  const GamificationService(this._progress);

  final ProgressRepository _progress;

  /// XP за пройденный блок.
  static const int blockXp = 50;

  /// Начисляет XP за блок и обновляет серию дней. Возвращает новую статистику.
  Future<UserStats> awardBlockCompletion(String userId, {DateTime? now}) async {
    final today = now ?? DateTime.now();
    final todayKey = _dayKey(today);
    final yesterdayKey = _dayKey(today.subtract(const Duration(days: 1)));

    final s = await _progress.getStats(userId);

    final int streak;
    if (s.lastActiveDay == todayKey) {
      streak = s.streakCurrent == 0 ? 1 : s.streakCurrent;
    } else if (s.lastActiveDay == yesterdayKey) {
      streak = s.streakCurrent + 1;
    } else {
      streak = 1;
    }

    final todayXp = (s.todayDate == todayKey ? s.todayXp : 0) + blockXp;

    final updated = UserStats(
      xp: s.xp + blockXp,
      streakCurrent: streak,
      streakBest: max(s.streakBest, streak),
      lastActiveDay: todayKey,
      todayXp: todayXp,
      todayDate: todayKey,
    );
    await _progress.saveStats(userId, updated);
    return updated;
  }

  /// Засчитывает учебную активность дня без начисления XP (например,
  /// завершённую сессию повтора): продлевает/начинает серию, чтобы streak
  /// не сгорал у того, кто занимается только повторами.
  Future<UserStats> markActivity(String userId, {DateTime? now}) async {
    final today = now ?? DateTime.now();
    final todayKey = _dayKey(today);
    final yesterdayKey = _dayKey(today.subtract(const Duration(days: 1)));

    final s = await _progress.getStats(userId);
    if (s.lastActiveDay == todayKey && s.streakCurrent > 0) return s;

    final streak = s.lastActiveDay == yesterdayKey ? s.streakCurrent + 1 : 1;

    final updated = UserStats(
      xp: s.xp,
      streakCurrent: streak,
      streakBest: max(s.streakBest, streak),
      lastActiveDay: todayKey,
      todayXp: s.todayDate == todayKey ? s.todayXp : 0,
      todayDate: todayKey,
    );
    await _progress.saveStats(userId, updated);
    return updated;
  }

  /// Целевой XP на день из дневной цели в минутах (≈10 XP за минуту).
  static int dailyGoalXp(int dailyGoalMinutes) => dailyGoalMinutes * 10;

  /// Оценка пройденных минут из заработанного XP (обратное к [dailyGoalXp]).
  static int minutesFromXp(int xp) => (xp / 10).round();

  String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
