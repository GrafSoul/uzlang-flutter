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
    return s.todayDate == _todayKey()
        ? GamificationService.minutesFromXp(s.todayXp)
        : 0;
  }

  /// Полоса дней недели (Пн…Вс) с состоянием серии.
  List<DayCell> get weekDays {
    final today = DateTime.now().weekday; // 1..7
    final streak = stats.value.streakCurrent;
    return List.generate(7, (i) {
      final dayNum = i + 1; // 1..7
      final isToday = dayNum == today;
      // День засчитан, если он в пределах текущей серии до сегодняшнего дня.
      final isDone = dayNum < today && (today - dayNum) < streak;
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
    } finally {
      isLoading.value = false;
    }
  }

  String _todayKey() {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
