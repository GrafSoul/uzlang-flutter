import 'package:drift/drift.dart';

import '../../../../domain/entities/enums.dart';
import '../app_database.dart';
import '../tables.dart';

part 'progress_dao.g.dart';

/// DAO прогресса повторения, статистики и блоков.
///
/// Тонкий слой: апсерты и выборки. Расчёт интервалов (FSRS) и геймификация —
/// в domain-сервисах, которые вызывают эти методы.
@DriftAccessor(tables: [CardProgress, UserStats, BlockProgress, Words])
class ProgressDao extends DatabaseAccessor<AppDatabase>
    with _$ProgressDaoMixin {
  /// Создаёт DAO, привязанный к базе [db].
  ProgressDao(super.db);

  /// Сколько слов темы выучено (карточки в состоянии review) у пользователя.
  Future<int> countLearnedWords(String userId, int topicId) async {
    final count = cardProgress.id.count();
    final query = selectOnly(cardProgress).join([
      innerJoin(words, words.id.equalsExp(cardProgress.cardId)),
    ])
      ..addColumns([count])
      ..where(cardProgress.userId.equals(userId) &
          cardProgress.cardKind.equalsValue(CardKind.word) &
          cardProgress.state.equalsValue(SrState.review) &
          words.topicId.equals(topicId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// Прогресс конкретной карточки, либо `null`, если ещё не изучалась.
  Future<CardProgressRow?> getProgress(
    String userId,
    CardKind kind,
    int cardId,
  ) {
    return (select(cardProgress)
          ..where((p) =>
              p.userId.equals(userId) &
              p.cardKind.equalsValue(kind) &
              p.cardId.equals(cardId)))
        .getSingleOrNull();
  }

  /// Карточки, у которых подошёл срок повтора ([CardProgress.due] ≤ [nowMs]).
  Future<List<CardProgressRow>> getDueCards(
    String userId,
    CardKind kind,
    int nowMs,
  ) {
    return (select(cardProgress)
          ..where((p) =>
              p.userId.equals(userId) &
              p.cardKind.equalsValue(kind) &
              p.due.isSmallerOrEqualValue(nowMs))
          ..orderBy([(p) => OrderingTerm(expression: p.due)]))
        .get();
  }

  /// Вставляет/обновляет прогресс карточки (по уникальному ключу).
  Future<void> upsertProgress(CardProgressCompanion progress) {
    return into(cardProgress).insertOnConflictUpdate(progress);
  }

  /// Статистика пользователя, либо `null`.
  Future<UserStatRow?> getStats(String userId) {
    return (select(userStats)..where((s) => s.userId.equals(userId)))
        .getSingleOrNull();
  }

  /// Вставляет/обновляет статистику пользователя.
  Future<void> upsertStats(UserStatsCompanion stats) {
    return into(userStats).insertOnConflictUpdate(stats);
  }

  /// Завершённые блоки темы в заданной области (слова/фразы).
  Future<List<BlockProgressRow>> getBlocks(
    String userId,
    int topicId,
    CardKind scope,
  ) {
    return (select(blockProgress)
          ..where((b) =>
              b.userId.equals(userId) &
              b.topicId.equals(topicId) &
              b.scope.equalsValue(scope)))
        .get();
  }

  /// Вставляет/обновляет прогресс блока.
  Future<void> upsertBlock(BlockProgressCompanion block) {
    return into(blockProgress).insertOnConflictUpdate(block);
  }
}
