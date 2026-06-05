import '../entities/card_progress.dart';
import '../entities/enums.dart';
import '../entities/user_stats.dart';

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

  /// Статистика пользователя (пустая, если ещё нет записи).
  Future<UserStats> getStats(String userId);

  /// Сколько слов темы выучено пользователем.
  Future<int> getLearnedWordCount(String userId, int topicId);

  /// Индексы завершённых блоков темы в заданной области (слова/фразы).
  Future<Set<int>> getCompletedBlockIndices(
    String userId,
    int topicId,
    CardKind scope,
  );
}
