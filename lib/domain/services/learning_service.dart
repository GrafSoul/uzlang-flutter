import '../entities/word.dart';
import '../entities/word_block.dart';

/// Логика учебного потока: блоки по 20 слов и разблокировка фраз.
///
/// Чистый сервис без состояния и зависимостей — на вход получает данные
/// (слова, завершённые блоки, счётчики), на выход даёт решения. Это делает его
/// тривиально тестируемым и независимым от БД/UI.
class LearningService {
  /// Создаёт сервис.
  const LearningService();

  /// Размер блока (как STEP_SIZE в исходном приложении).
  static const int blockSize = 20;

  /// Делит упорядоченные [words] темы [topicId] на блоки по [blockSize].
  ///
  /// Статус блока: пройден, если его индекс в [completedBlockIndices];
  /// доступен, если это первый блок или предыдущий пройден; иначе заблокирован.
  List<WordBlock> buildWordBlocks(
    int topicId,
    List<Word> words,
    Set<int> completedBlockIndices,
  ) {
    final blocks = <WordBlock>[];
    for (var start = 0, index = 0;
        start < words.length;
        start += blockSize, index++) {
      final end =
          (start + blockSize) < words.length ? start + blockSize : words.length;
      final isCompleted = completedBlockIndices.contains(index);
      final prevCompleted =
          index == 0 || completedBlockIndices.contains(index - 1);
      blocks.add(
        WordBlock(
          topicId: topicId,
          index: index,
          words: words.sublist(start, end),
          status: isCompleted
              ? BlockStatus.completed
              : (prevCompleted ? BlockStatus.available : BlockStatus.locked),
        ),
      );
    }
    return blocks;
  }

  /// Сколько блоков получится из [wordCount] слов.
  int blockCount(int wordCount) => (wordCount / blockSize).ceil();

  /// Открыты ли фразы темы: открываются, когда выучены ВСЕ слова темы.
  bool arePhrasesUnlocked({
    required int learnedWords,
    required int totalWords,
  }) {
    return totalWords > 0 && learnedWords >= totalWords;
  }
}
