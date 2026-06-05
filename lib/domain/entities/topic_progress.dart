import 'topic.dart';

/// Статус темы в учебном потоке.
enum TopicStatus {
  /// Уже начата (есть прогресс, но не завершена).
  inProgress,

  /// Доступна для старта (предыдущая пройдена), ещё не начата.
  available,

  /// Заблокирована (предыдущая тема не пройдена).
  locked,

  /// Полностью пройдена.
  completed,
}

/// Прогресс по теме (read-model для Главной и Выбора темы).
class TopicProgress {
  /// Создаёт прогресс темы.
  const TopicProgress({
    required this.topic,
    required this.learnedWords,
    required this.totalWords,
    required this.status,
  });

  /// Тема.
  final Topic topic;

  /// Сколько слов выучено.
  final int learnedWords;

  /// Всего слов в теме.
  final int totalWords;

  /// Статус темы.
  final TopicStatus status;

  /// Доля выученного (0..1).
  double get percent => totalWords == 0 ? 0 : learnedWords / totalWords;

  /// Процент выученного (0..100).
  int get percentInt => (percent * 100).round();

  /// Заблокирована ли тема.
  bool get isLocked => status == TopicStatus.locked;
}
