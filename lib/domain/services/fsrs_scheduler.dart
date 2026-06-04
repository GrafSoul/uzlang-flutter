import 'package:fsrs/fsrs.dart' as fsrs;

import '../entities/card_progress.dart';
import '../entities/enums.dart';
import 'sr_scheduler.dart';

/// Реализация [SrScheduler] на пакете FSRS.
///
/// Конвертирует доменный [CardProgress] в `fsrs.Card`, прогоняет через
/// `fsrs.Scheduler` и возвращает обновлённый домен. Сам ведёт счётчики
/// [CardProgress.reps] / [CardProgress.lapses] (их пакет не хранит).
class FsrsScheduler implements SrScheduler {
  /// Создаёт планировщик; можно передать настроенный [fsrs.Scheduler].
  FsrsScheduler({fsrs.Scheduler? scheduler})
      : _scheduler = scheduler ?? fsrs.Scheduler();

  final fsrs.Scheduler _scheduler;

  @override
  CardProgress review(CardProgress current, Rating rating, {DateTime? now}) {
    final reviewTime = (now ?? DateTime.now()).toUtc();

    final card = fsrs.Card(
      cardId: current.cardId,
      state: _toFsrsState(current.state),
      step: current.step,
      stability: current.stability,
      difficulty: current.difficulty,
      due: current.due.toUtc(),
      lastReview: current.lastReviewed?.toUtc(),
    );

    final result = _scheduler.reviewCard(
      card,
      _toFsrsRating(rating),
      reviewDateTime: reviewTime,
    );
    final updated = result.card;

    return current.copyWith(
      state: _fromFsrsState(updated.state),
      step: updated.step,
      stability: updated.stability,
      difficulty: updated.difficulty,
      due: updated.due,
      lastReviewed: updated.lastReview,
      reps: current.reps + 1,
      lapses: current.lapses + (rating == Rating.again ? 1 : 0),
    );
  }

  /// Доменное состояние → состояние FSRS (новая карточка стартует в learning).
  fsrs.State _toFsrsState(SrState state) {
    switch (state) {
      case SrState.newCard:
      case SrState.learning:
        return fsrs.State.learning;
      case SrState.review:
        return fsrs.State.review;
      case SrState.relearning:
        return fsrs.State.relearning;
    }
  }

  /// Состояние FSRS → доменное состояние.
  SrState _fromFsrsState(fsrs.State state) {
    switch (state) {
      case fsrs.State.learning:
        return SrState.learning;
      case fsrs.State.review:
        return SrState.review;
      case fsrs.State.relearning:
        return SrState.relearning;
    }
  }

  /// Доменный рейтинг → рейтинг FSRS (порядок совпадает).
  fsrs.Rating _toFsrsRating(Rating rating) {
    switch (rating) {
      case Rating.again:
        return fsrs.Rating.again;
      case Rating.hard:
        return fsrs.Rating.hard;
      case Rating.good:
        return fsrs.Rating.good;
      case Rating.easy:
        return fsrs.Rating.easy;
    }
  }
}
