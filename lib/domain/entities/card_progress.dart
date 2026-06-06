import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'card_progress.freezed.dart';

/// Доменное состояние интервального повторения карточки (слова или фразы).
///
/// Иммутабельно. Обновляется планировщиком `SrScheduler` и сохраняется
/// репозиторием прогресса.
@freezed
abstract class CardProgress with _$CardProgress {
  /// Создаёт состояние прогресса.
  const factory CardProgress({
    /// Тип карточки (слово/фраза).
    required CardKind kind,

    /// Идентификатор карточки в её таблице.
    required int cardId,

    /// Текущее состояние карточки.
    required SrState state,

    /// Когда подойдёт следующий повтор.
    required DateTime due,

    /// Когда повторяли в последний раз.
    DateTime? lastReviewed,

    /// FSRS: стабильность.
    double? stability,

    /// FSRS: сложность.
    double? difficulty,

    /// Текущий шаг обучения/переобучения.
    int? step,

    /// Число повторов.
    @Default(0) int reps,

    /// Число провалов.
    @Default(0) int lapses,
  }) = _CardProgress;
}

/// Создаёт начальный прогресс новой карточки (ещё не изучалась).
CardProgress freshCardProgress(CardKind kind, int cardId, {DateTime? now}) {
  return CardProgress(
    kind: kind,
    cardId: cardId,
    state: SrState.newCard,
    due: (now ?? DateTime.now()).toUtc(),
  );
}
