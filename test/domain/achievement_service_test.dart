import 'package:flutter_test/flutter_test.dart';
import 'package:uzlang_mobile/domain/entities/user_stats.dart';
import 'package:uzlang_mobile/domain/services/achievement_service.dart';

void main() {
  const service = AchievementService();

  bool unlocked(UserStats s, String id) =>
      service.evaluate(s).firstWhere((a) => a.id == id).unlocked;

  group('AchievementService', () {
    test('у нового пользователя ничего не получено', () {
      expect(service.unlockedCount(UserStats.empty), 0);
    });

    test('первый блок и 100 XP открываются по XP', () {
      const s = UserStats(xp: 100, streakCurrent: 1, streakBest: 1);

      expect(unlocked(s, 'first_block'), isTrue);
      expect(unlocked(s, 'xp_100'), isTrue);
      expect(unlocked(s, 'xp_500'), isFalse);
    });

    test('серии открываются по лучшей серии', () {
      const s = UserStats(xp: 50, streakCurrent: 2, streakBest: 7);

      expect(unlocked(s, 'streak_3'), isTrue);
      expect(unlocked(s, 'streak_7'), isTrue);
    });

    test('500 XP открывает «Знаток»', () {
      const s = UserStats(xp: 500, streakCurrent: 1, streakBest: 1);

      expect(unlocked(s, 'xp_500'), isTrue);
      expect(service.unlockedCount(s), 3); // first_block + xp_100 + xp_500
    });
  });
}
