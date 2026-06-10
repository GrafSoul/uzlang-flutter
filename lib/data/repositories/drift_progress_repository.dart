import 'package:drift/drift.dart' show Value;

import '../../domain/entities/card_progress.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/user_stats.dart';
import '../../domain/repositories/progress_repository.dart';
import '../local/database/app_database.dart';
import '../local/database/daos/progress_dao.dart';
import '../local/database/mappers.dart';

/// Реализация [ProgressRepository] поверх Drift ([ProgressDao]).
class DriftProgressRepository implements ProgressRepository {
  /// Создаёт репозиторий поверх [_dao].
  DriftProgressRepository(this._dao);

  final ProgressDao _dao;

  @override
  Future<CardProgress?> getProgress(
    String userId,
    CardKind kind,
    int cardId,
  ) async {
    return (await _dao.getProgress(userId, kind, cardId))?.toDomain();
  }

  @override
  Future<void> saveProgress(String userId, CardProgress progress) {
    return _dao.upsertProgress(progress.toCompanion(userId));
  }

  @override
  Future<List<CardProgress>> getDueCards(
    String userId,
    CardKind kind,
    DateTime now,
  ) async {
    final rows = await _dao.getDueCards(
      userId,
      kind,
      now.toUtc().millisecondsSinceEpoch,
    );
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<UserStats> getStats(String userId) async {
    final row = await _dao.getStats(userId);
    if (row == null) return UserStats.empty;
    return UserStats(
      xp: row.xp,
      streakCurrent: row.streakCurrent,
      streakBest: row.streakBest,
      lastActiveDay: row.lastActiveDay,
      todayXp: row.todayXp,
      todayDate: row.todayDate,
    );
  }

  @override
  Future<int> getLearnedWordCount(String userId, int topicId) {
    return _dao.countLearnedWords(userId, topicId);
  }

  @override
  Future<Set<int>> getLearnedWordIds(String userId, int topicId) {
    return _dao.learnedWordIds(userId, topicId);
  }

  @override
  Future<Set<int>> getCompletedBlockIndices(
    String userId,
    int topicId,
    CardKind scope,
  ) async {
    final rows = await _dao.getBlocks(userId, topicId, scope);
    return rows
        .where((b) => b.completedAt != null)
        .map((b) => b.blockIndex)
        .toSet();
  }

  @override
  Future<void> completeBlock(
    String userId,
    int topicId,
    CardKind scope,
    int blockIndex,
    double accuracy,
  ) {
    return _dao.markBlockCompleted(
      userId,
      topicId,
      scope,
      blockIndex,
      accuracy,
      DateTime.now().toUtc().millisecondsSinceEpoch,
    );
  }

  @override
  Future<int> getTotalLearnedWords(String userId) =>
      _dao.countAllLearnedWords(userId);

  @override
  Future<double> getAverageAccuracy(String userId) =>
      _dao.averageAccuracy(userId);

  @override
  Future<void> saveStats(String userId, UserStats stats) {
    return _dao.upsertStats(
      UserStatsCompanion.insert(
        userId: userId,
        xp: Value(stats.xp),
        streakCurrent: Value(stats.streakCurrent),
        streakBest: Value(stats.streakBest),
        lastActiveDay: Value(stats.lastActiveDay),
        todayXp: Value(stats.todayXp),
        todayDate: Value(stats.todayDate),
      ),
    );
  }
}
