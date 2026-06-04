import '../entities/card_progress.dart';
import '../entities/enums.dart';

/// Доступ к прогрессу интервального повторения (абстракция).
///
/// Реализация — локальная (Drift). Через этот интерфейс позже подключается
/// облачный синхрон прогресса (offline-first) без изменений в домене.
abstract interface class ProgressRepository {
  /// Прогресс карточки, либо `null`, если ещё не изучалась.
  Future<CardProgress?> getProgress(String userId, CardKind kind, int cardId);

  /// Сохраняет (вставляет/обновляет) прогресс карточки.
  Future<void> saveProgress(String userId, CardProgress progress);

  /// Карточки, подошедшие к сроку повтора на момент [now].
  Future<List<CardProgress>> getDueCards(
    String userId,
    CardKind kind,
    DateTime now,
  );
}
