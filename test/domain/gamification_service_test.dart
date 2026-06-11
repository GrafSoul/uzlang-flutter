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

  /// История XP по дням (тестовый разрез).
  final Map<String, int> daily = {};

  @override
  Future<void> addDailyXp(String userId, String day, int xp) async =>
      daily[day] = (daily[day] ?? 0) + xp;

  @override
  Future<Map<String, int>> getXpByDaySince(
          String userId, String fromDay) async =>
      {for (final e in daily.entries) if (e.key.compareTo(fromDay) >= 0) e.key: e.value};

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

  group('GamificationService дневной XP', () {
    test('первый блок дня: todayXp = 50', () async {
      final now = DateTime(2026, 1, 10);
      final repo = _FakeProgress(UserStats.empty);
      final service = GamificationService(repo);

      final s = await service.awardBlockCompletion('local', now: now);

      expect(s.todayXp, 50);
      expect(s.todayDate, _key(now));
    });

    test('второй блок в тот же день: todayXp накапливается', () async {
      final now = DateTime(2026, 1, 10);
      final repo = _FakeProgress(UserStats(
        xp: 50,
        streakCurrent: 1,
        streakBest: 1,
        lastActiveDay: _key(now),
        todayXp: 50,
        todayDate: _key(now),
      ));
      final service = GamificationService(repo);

      final s = await service.awardBlockCompletion('local', now: now);

      expect(s.todayXp, 100);
    });

    test('новый день: todayXp сбрасывается', () async {
      final now = DateTime(2026, 1, 10);
      final repo = _FakeProgress(UserStats(
        xp: 200,
        streakCurrent: 1,
        streakBest: 3,
        lastActiveDay: _key(now.subtract(const Duration(days: 1))),
        todayXp: 150,
        todayDate: _key(now.subtract(const Duration(days: 1))),
      ));
      final service = GamificationService(repo);

      final s = await service.awardBlockCompletion('local', now: now);

      expect(s.todayXp, 50);
    });
  });

  group('GamificationService.markActivity (повтор без XP)', () {
    test('первая активность: streak = 1, XP не меняется', () async {
      final repo = _FakeProgress(UserStats.empty);
      final service = GamificationService(repo);
      final now = DateTime(2026, 1, 10);

      final s = await service.markActivity('local', now: now);

      expect(s.xp, 0);
      expect(s.streakCurrent, 1);
      expect(s.streakBest, 1);
      expect(s.lastActiveDay, _key(now));
    });

    test('повтор на следующий день продлевает серию без XP', () async {
      final now = DateTime(2026, 1, 10);
      final repo = _FakeProgress(UserStats(
        xp: 300,
        streakCurrent: 4,
        streakBest: 4,
        lastActiveDay: _key(now.subtract(const Duration(days: 1))),
      ));
      final service = GamificationService(repo);

      final s = await service.markActivity('local', now: now);

      expect(s.xp, 300);
      expect(s.streakCurrent, 5);
      expect(s.streakBest, 5);
    });

    test('тот же день: ничего не меняется (идемпотентно)', () async {
      final now = DateTime(2026, 1, 10);
      final initial = UserStats(
        xp: 300,
        streakCurrent: 4,
        streakBest: 6,
        lastActiveDay: _key(now),
        todayXp: 100,
        todayDate: _key(now),
      );
      final repo = _FakeProgress(initial);
      final service = GamificationService(repo);

      final s = await service.markActivity('local', now: now);

      expect(s, initial);
    });

    test('после пропуска дня: серия начинается заново с 1', () async {
      final now = DateTime(2026, 1, 10);
      final repo = _FakeProgress(UserStats(
        xp: 300,
        streakCurrent: 4,
        streakBest: 6,
        lastActiveDay: _key(now.subtract(const Duration(days: 3))),
      ));
      final service = GamificationService(repo);

      final s = await service.markActivity('local', now: now);

      expect(s.streakCurrent, 1);
      expect(s.streakBest, 6);
      expect(s.xp, 300);
    });
  });
}
