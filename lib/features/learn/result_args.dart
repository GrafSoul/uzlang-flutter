import '../../domain/entities/topic.dart';
import 'lesson_args.dart';

/// Аргументы экрана результата блока.
class ResultArgs {
  /// Создаёт аргументы результата.
  const ResultArgs({
    required this.topic,
    required this.blockNumber,
    required this.xpEarned,
    required this.accuracy,
    required this.streak,
    required this.unlockedNext,
    this.nextArgs,
    this.isPhrase = false,
  });

  /// Тема.
  final Topic topic;

  /// Номер пройденного блока (1-based).
  final int blockNumber;

  /// Заработанный XP.
  final int xpEarned;

  /// Точность (0..1).
  final double accuracy;

  /// Текущая серия дней.
  final int streak;

  /// Разблокирован ли следующий блок.
  final bool unlockedNext;

  /// Аргументы следующего блока (если разблокирован).
  final LessonArgs? nextArgs;

  /// Это результат блока фраз (иначе — слов).
  final bool isPhrase;

  /// Точность в процентах.
  int get accuracyPercent => (accuracy * 100).round();
}
