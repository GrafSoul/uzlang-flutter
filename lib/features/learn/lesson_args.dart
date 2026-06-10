import '../../domain/entities/topic.dart';

/// Аргументы учебной сессии блока (передаются между экранами Учить→Тест→Результат).
class LessonArgs {
  /// Создаёт аргументы сессии.
  const LessonArgs({
    required this.topic,
    required this.blockIndex,
    this.isPhrase = false,
  });

  /// Тема.
  final Topic topic;

  /// Индекс блока внутри темы (0-based).
  final int blockIndex;

  /// Это блок фраз (иначе — слов). Нужен экранам, продолжающим сессию
  /// (например, «Нет жизней» → «Повторить пройденное» ведёт в нужный поток).
  final bool isPhrase;

  /// Номер блока для отображения (1-based).
  int get blockNumber => blockIndex + 1;

  /// Аргументы следующего блока (тот же поток).
  LessonArgs next() => LessonArgs(
        topic: topic,
        blockIndex: blockIndex + 1,
        isPhrase: isPhrase,
      );
}
