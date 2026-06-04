import 'word.dart';

/// Статус блока обучения.
enum BlockStatus {
  /// Заблокирован (предыдущий блок не пройден).
  locked,

  /// Доступен для прохождения.
  available,

  /// Пройден (тест сдан).
  completed,
}

/// Блок обучения — порция из ≤20 слов темы (модель «Учить → Повтор → Тест»).
///
/// Вычисляемый агрегат (в БД не хранится): формируется сервисом обучения из
/// упорядоченных слов темы и прогресса.
class WordBlock {
  /// Создаёт блок.
  const WordBlock({
    required this.topicId,
    required this.index,
    required this.words,
    required this.status,
  });

  /// Тема блока.
  final int topicId;

  /// Индекс блока внутри темы (0-based).
  final int index;

  /// Слова блока (≤20).
  final List<Word> words;

  /// Статус блока.
  final BlockStatus status;
}
