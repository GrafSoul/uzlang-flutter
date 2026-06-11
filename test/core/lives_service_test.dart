import 'package:flutter_test/flutter_test.dart';
import 'package:uzlang_mobile/core/services/lives_service.dart';

void main() {
  group('LivesService отсчёт до восстановления', () {
    test('восстановление — в полночь, а не через 24 часа', () {
      expect(
        LivesService.untilRestore(now: DateTime(2026, 6, 11, 21, 30)),
        const Duration(hours: 2, minutes: 30),
      );
    });

    test('подпись ЧЧ:ММ', () {
      expect(LivesService.restoreLabel(now: DateTime(2026, 6, 11, 21, 30)),
          '02:30');
      expect(
          LivesService.restoreLabel(now: DateTime(2026, 6, 11, 0, 1)), '23:59');
    });
  });
}
