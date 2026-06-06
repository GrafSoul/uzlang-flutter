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
  }) {
    return _completeBlock(userId, topicId, CardKind.word, blockIndex, accuracy);
  }

  /// Завершает блок фраз: помечает пройденным и начисляет награду.
  Future<UserStats> completePhraseBlock({
    required String userId,
    required int topicId,
    required int blockIndex,
    required double accuracy,
  }) {
    return _completeBlock(
        userId, topicId, CardKind.phrase, blockIndex, accuracy);
  }

  Future<UserStats> _completeBlock(
    String userId,
    int topicId,
    CardKind scope,
    int blockIndex,
    double accuracy,
  ) async {
    await _progress.completeBlock(userId, topicId, scope, blockIndex, accuracy);
    return _gamification.awardBlockCompletion(userId);
  }
}
