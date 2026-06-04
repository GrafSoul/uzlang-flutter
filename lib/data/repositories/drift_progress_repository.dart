import '../../domain/entities/card_progress.dart';
import '../../domain/entities/enums.dart';
import '../../domain/repositories/progress_repository.dart';
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
}
