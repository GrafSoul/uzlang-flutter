import 'package:get/get.dart';

import '../../core/services/user_service.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/user_stats.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/services/achievement_service.dart';
import '../../domain/services/gamification_service.dart';

/// Ячейка дня недели в полосе серии.
class DayCell {
  /// Создаёт ячейку.
  const DayCell(
      {required this.label, required this.isToday, required this.isDone});

  /// Подпись (Пн…Вс).
  final String label;

  /// Сегодняшний день.
  final bool isToday;

  /// День засчитан в серию.
  final bool isDone;
}

/// Контроллер экрана «Прогресс».
class ProgressController extends GetxController {
  /// Создаёт контроллер.
  ProgressController(this._user, this._progress, this._achievements);

  final UserService _user;
  final ProgressRepository _progress;
  final AchievementService _achievements;

  static const List<String> _weekLabels = [
    'Пн',
    'Вт',
    'Ср',
    'Чт',
    'Пт',
    'Сб',
    'Вс',
  ];

  /// Статистика.
  final Rx<UserStats> stats = UserStats.empty.obs;

  /// Всего слов выучено.
  final RxInt learnedWords = 0.obs;

  /// Средняя точность (0..1).
  final RxDouble accuracy = 0.0.obs;

  /// Достижения.
  final RxList<Achievement> achievements = <Achievement>[].obs;

  /// Минуты по дням текущей недели (Пн…Вс) из истории активности.
  final RxList<int> weekMinutes = List.filled(7, 0).obs;

  /// Идёт ли загрузка.
  final RxBool isLoading = true.obs;

  /// Есть ли вообще прогресс (иначе — пустое состояние).
  bool get hasProgress => stats.value.xp > 0;

  /// Точность в процентах.
  int get accuracyPercent => (accuracy.value * 100).round();

  /// Оценка минут в приложении (из общего XP).
  int get totalMinutes => GamificationService.minutesFromXp(stats.value.xp);

  /// Подпись времени «Xч Ym».
  String get timeLabel {
    final m = totalMinutes;
    return m >= 60 ? '${m ~/ 60}ч ${m % 60}м' : '$m мин';
  }

  /// Минуты за сегодня (для недельного графика).
  int get todayMinutes {
    final s = stats.value;
    return s.todayDate == GamificationService.dayKey(DateTime.now())
        ? GamificationService.minutesFromXp(s.todayXp)
        : 0;
  }

  /// Полоса дней недели (Пн…Вс) с состоянием серии.
  List<DayCell> get weekDays {
    final today = DateTime.now().weekday; // 1..7
    final streak = stats.value.streakCurrent;
    final activeToday =
        stats.value.lastActiveDay == GamificationService.dayKey(DateTime.now());
    return List.generate(7, (i) {
      final dayNum = i + 1; // 1..7
      final isToday = dayNum == today;
      // День засчитан, если он в пределах текущей серии; сегодняшний —
      // если активность уже была сегодня.
      final isDone = isToday
          ? activeToday
          : dayNum < today && (today - dayNum) < streak;
      return DayCell(label: _weekLabels[i], isToday: isToday, isDone: isDone);
    });
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  /// Загружает данные прогресса.
  Future<void> load() async {
    isLoading.value = true;
    try {
      final userId = _user.localUserId;
      final s = await _progress.getStats(userId);
      stats.value = s;
      learnedWords.value = await _progress.getTotalLearnedWords(userId);
      accuracy.value = await _progress.getAverageAccuracy(userId);
      achievements.value = _achievements.evaluate(s);

      // Неделя: XP по дням с понедельника → минуты на каждый день.
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final xpByDay = await _progress.getXpByDaySince(
        userId,
        GamificationService.dayKey(monday),
      );
      weekMinutes.value = List.generate(7, (i) {
        final day = GamificationService.dayKey(monday.add(Duration(days: i)));
        return GamificationService.minutesFromXp(xpByDay[day] ?? 0);
      });
    } finally {
      isLoading.value = false;
    }
  }

}
