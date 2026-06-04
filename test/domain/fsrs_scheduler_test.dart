import 'package:flutter_test/flutter_test.dart';
import 'package:uzlang_mobile/domain/entities/card_progress.dart';
import 'package:uzlang_mobile/domain/entities/enums.dart';
import 'package:uzlang_mobile/domain/services/fsrs_scheduler.dart';

void main() {
  final scheduler = FsrsScheduler();
  final now = DateTime.utc(2026, 1, 1, 12);

  CardProgress newWord() => CardProgress(
        kind: CardKind.word,
        cardId: 1,
        state: SrState.newCard,
        due: now,
      );

  group('FsrsScheduler', () {
    test('оценка «good» назначает интервал, стабильность и инкремент reps', () {
      final after = scheduler.review(newWord(), Rating.good, now: now);

      expect(after.reps, 1);
      expect(after.stability, isNotNull);
      expect(after.difficulty, isNotNull);
      expect(after.due.isAfter(now), isTrue);
      expect(after.lastReviewed, isNotNull);
      expect(after.state, isNot(SrState.newCard));
    });

    test('оценка «again» увеличивает счётчик провалов', () {
      final after = scheduler.review(newWord(), Rating.again, now: now);

      expect(after.reps, 1);
      expect(after.lapses, 1);
    });

    test('«easy» даёт интервал не короче, чем «hard»', () {
      final easy = scheduler.review(newWord(), Rating.easy, now: now);
      final hard = scheduler.review(newWord(), Rating.hard, now: now);

      expect(
        easy.due.isAfter(hard.due) || easy.due.isAtSameMomentAs(hard.due),
        isTrue,
      );
    });

    test('повторная оценка двигает карточку дальше во времени', () {
      final first = scheduler.review(newWord(), Rating.good, now: now);
      final second = scheduler.review(first, Rating.good, now: first.due);

      expect(second.reps, 2);
      expect(second.due.isAfter(first.due), isTrue);
    });
  });
}
