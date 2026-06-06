import 'package:flutter_test/flutter_test.dart';
import 'package:uzlang_mobile/domain/entities/card_progress.dart';
import 'package:uzlang_mobile/domain/entities/enums.dart';
import 'package:uzlang_mobile/domain/entities/user_stats.dart';
import 'package:uzlang_mobile/domain/repositories/progress_repository.dart';
import 'package:uzlang_mobile/domain/services/gamification_service.dart';

/// Фейк прогресс-репозитория, хранящий статистику в памяти.
class _FakeProgress implements ProgressRepository {
  _FakeProgress(this._stats);

  UserStats _stats;

  @override
  Future<UserStats> getStats(String userId) async => _stats;

  @override
  Future<void> saveStats(String userId, UserStats stats) async =>
      _stats = stats;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());

  // Неиспользуемые методы интерфейса покрыты noSuchMethod.
  @override
  Future<CardProgress?> getProgress(String userId, CardKind kind, int cardId) =>
      throw UnimplementedError();
}

String _key(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

void main() {
  group('GamificationService', () {
    test('первый блок: XP +50, streak = 1', () async {
      final repo = _FakeProgress(UserStats.empty);
      final service = GamificationService(repo);
      final now = DateTime(2026, 1, 10);

      final s = await service.awardBlockCompletion('local', now: now);

      expect(s.xp, 50);
      expect(s.streakCurrent, 1);
      expect(s.streakBest, 1);
      expect(s.lastActiveDay, _key(now));
    });

    test('следующий день: streak +1, XP накапливается', () async {
      final now = DateTime(2026, 1, 10);
      final repo = _FakeProgress(UserStats(
        xp: 50,
        streakCurrent: 1,
        streakBest: 1,
        lastActiveDay: _key(now.subtract(const Duration(days: 1))),
      ));
      final service = GamificationService(repo);

      final s = await service.awardBlockCompletion('local', now: now);

      expect(s.xp, 100);
      expect(s.streakCurrent, 2);
      expect(s.streakBest, 2);
    });

    test('тот же день: streak не растёт, XP растёт', () async {
      final now = DateTime(2026, 1, 10);
      final repo = _FakeProgress(UserStats(
        xp: 50,
        streakCurrent: 3,
        streakBest: 5,
        lastActiveDay: _key(now),
      ));
      final service = GamificationService(repo);

      final s = await service.awardBlockCompletion('local', now: now);

      expect(s.xp, 100);
      expect(s.streakCurrent, 3);
      expect(s.streakBest, 5);
    });

    test('после пропуска дня: streak сбрасывается на 1', () async {
      final now = DateTime(2026, 1, 10);
      final repo = _FakeProgress(UserStats(
        xp: 200,
        streakCurrent: 7,
        streakBest: 7,
        lastActiveDay: _key(now.subtract(const Duration(days: 3))),
      ));
      final service = GamificationService(repo);

      final s = await service.awardBlockCompletion('local', now: now);

      expect(s.streakCurrent, 1);
      expect(s.streakBest, 7);
    });
  });
}
