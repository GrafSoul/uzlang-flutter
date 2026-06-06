import '../../domain/entities/topic.dart';

/// Аргументы учебной сессии блока (передаются между экранами Учить→Тест→Результат).
class LessonArgs {
  /// Создаёт аргументы сессии.
  const LessonArgs({required this.topic, required this.blockIndex});

  /// Тема.
  final Topic topic;

  /// Индекс блока внутри темы (0-based).
  final int blockIndex;

  /// Номер блока для отображения (1-based).
  int get blockNumber => blockIndex + 1;

  /// Аргументы следующего блока.
  LessonArgs next() => LessonArgs(topic: topic, blockIndex: blockIndex + 1);
}
