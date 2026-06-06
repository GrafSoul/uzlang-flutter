import '../entities/enums.dart';
import '../entities/user_stats.dart';
import '../repositories/progress_repository.dart';
import 'gamification_service.dart';

/// Завершение учебного блока: фиксация прохождения + награда.
///
/// Оркестрирует доменные шаги: отмечает блок пройденным и начисляет XP/streak.
class LessonService {
  /// Создаёт сервис.
  const LessonService(this._progress, this._gamification);

  final ProgressRepository _progress;
  final GamificationService _gamification;

  /// Завершает блок слов: помечает пройденным и начисляет награду.
  /// Возвращает обновлённую статистику для экрана результата.
  Future<UserStats> completeWordBlock({
    required String userId,
    required int topicId,
    required int blockIndex,
    required double accuracy,
  }) async {
    await _progress.completeBlock(
      userId,
      topicId,
      CardKind.word,
      blockIndex,
      accuracy,
    );
    return _gamification.awardBlockCompletion(userId);
  }
}
