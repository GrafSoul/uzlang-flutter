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

  /// Делит [itemCount] элементов на блоки по [blockSize] и считает их статусы.
  ///
  /// Статус: пройден, если индекс в [completedBlockIndices]; доступен, если это
  /// первый блок или предыдущий пройден; иначе заблокирован. Подходит и словам,
  /// и фразам (зависит только от количества и завершённых индексов).
  List<BlockInfo> buildBlocks(int itemCount, Set<int> completedBlockIndices) {
    final blocks = <BlockInfo>[];
    for (var start = 0, index = 0;
        start < itemCount;
        start += blockSize, index++) {
      final end =
          (start + blockSize) < itemCount ? start + blockSize : itemCount;
      final isCompleted = completedBlockIndices.contains(index);
      final prevCompleted =
          index == 0 || completedBlockIndices.contains(index - 1);
      blocks.add(
        BlockInfo(
          index: index,
          start: start,
          end: end,
          status: isCompleted
              ? BlockStatus.completed
              : (prevCompleted ? BlockStatus.available : BlockStatus.locked),
        ),
      );
    }
    return blocks;
  }

  /// Делит упорядоченные [words] темы [topicId] на блоки слов.
  List<WordBlock> buildWordBlocks(
    int topicId,
    List<Word> words,
    Set<int> completedBlockIndices,
  ) {
    return buildBlocks(words.length, completedBlockIndices)
        .map((b) => WordBlock(
              topicId: topicId,
              index: b.index,
              words: words.sublist(b.start, b.end),
              status: b.status,
            ))
        .toList();
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
