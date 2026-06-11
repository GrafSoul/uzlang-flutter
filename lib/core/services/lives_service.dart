import 'package:get_storage/get_storage.dart';

import '../../domain/services/gamification_service.dart';

/// Дневной запас жизней для тестов.
///
/// 3 жизни на день; тратятся на неверные ответы в тестах (слова и фразы).
/// Восстанавливаются НЕ через 24 часа, а в полночь — с началом следующего дня.
class LivesService {
  /// Создаёт сервис поверх бокса [_box].
  LivesService(this._box);

  final GetStorage _box;

  static const String _kLives = 'lives.count';
  static const String _kDay = 'lives.day';

  /// Жизней в день.
  static const int maxLives = 3;

  /// Текущее число жизней (новый день — полный запас).
  int get lives {
    final today = GamificationService.dayKey(DateTime.now());
    if (_box.read<String>(_kDay) != today) return maxLives;
    return (_box.read<int>(_kLives) ?? maxLives).clamp(0, maxLives);
  }

  /// Тратит одну жизнь (не уходит ниже нуля).
  Future<void> consume() async {
    final today = GamificationService.dayKey(DateTime.now());
    final next = (lives - 1).clamp(0, maxLives);
    await _box.write(_kDay, today);
    await _box.write(_kLives, next);
  }

  /// Сколько осталось до восстановления (до ближайшей полуночи).
  static Duration untilRestore({DateTime? now}) {
    final n = now ?? DateTime.now();
    final midnight = DateTime(n.year, n.month, n.day + 1);
    return midnight.difference(n);
  }

  /// Подпись отсчёта «ЧЧ:ММ» до восстановления жизней.
  static String restoreLabel({DateTime? now}) {
    final d = untilRestore(now: now);
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }
}
