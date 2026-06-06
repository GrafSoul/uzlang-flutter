import 'package:flutter_test/flutter_test.dart';
import 'package:uzlang_mobile/domain/entities/word.dart';
import 'package:uzlang_mobile/domain/entities/word_block.dart';
import 'package:uzlang_mobile/domain/services/learning_service.dart';

void main() {
  const service = LearningService();

  group('LearningService.buildBlocks (универсально для слов/фраз)', () {
    test('45 элементов → 3 блока 20/20/5', () {
      final blocks = service.buildBlocks(45, <int>{});

      expect(blocks.length, 3);
      expect(blocks[0].count, 20);
      expect(blocks[2].count, 5);
    });

    test('статусы: пройден → доступен → заперт', () {
      final blocks = service.buildBlocks(60, <int>{0});

      expect(blocks[0].status, BlockStatus.completed);
      expect(blocks[1].status, BlockStatus.available);
      expect(blocks[2].status, BlockStatus.locked);
    });
  });

  List<Word> makeWords(int count) => List.generate(
        count,
        (i) => Word(
          id: i + 1,
          topicId: 1,
          uz: 'uz$i',
          reading: 'r$i',
          ru: 'ru$i',
          level: 1,
          sortOrder: i,
        ),
      );

  group('LearningService.buildWordBlocks', () {
    test('45 слов делятся на блоки 20/20/5', () {
      final blocks = service.buildWordBlocks(1, makeWords(45), <int>{});

      expect(blocks.length, 3);
      expect(blocks[0].words.length, 20);
      expect(blocks[1].words.length, 20);
      expect(blocks[2].words.length, 5);
    });

    test('статусы: пройден → доступен следующий → остальные заперты', () {
      final blocks = service.buildWordBlocks(1, makeWords(60), <int>{0});

      expect(blocks[0].status, BlockStatus.completed);
      expect(blocks[1].status, BlockStatus.available);
      expect(blocks[2].status, BlockStatus.locked);
    });

    test('первый блок всегда доступен', () {
      final blocks = service.buildWordBlocks(1, makeWords(10), <int>{});

      expect(blocks.single.status, BlockStatus.available);
    });
  });

  group('LearningService.arePhrasesUnlocked', () {
    test('открыты, когда выучены все слова темы', () {
      expect(
          service.arePhrasesUnlocked(learnedWords: 20, totalWords: 20), isTrue);
    });

    test('закрыты, пока выучены не все', () {
      expect(service.arePhrasesUnlocked(learnedWords: 19, totalWords: 20),
          isFalse);
    });

    test('закрыты при отсутствии слов', () {
      expect(
          service.arePhrasesUnlocked(learnedWords: 0, totalWords: 0), isFalse);
    });
  });
}
