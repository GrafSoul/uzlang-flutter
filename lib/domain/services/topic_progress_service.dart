import '../entities/topic_progress.dart';
import '../repositories/content_repository.dart';
import '../repositories/progress_repository.dart';

/// Сервис расчёта прогресса и статусов тем.
///
/// Единый источник логики разблокировки (тему открывает завершение
/// предыдущей). Используется Главной и экраном «Выбор темы», чтобы не
/// дублировать правила.
class TopicProgressService {
  /// Создаёт сервис поверх репозиториев контента и прогресса.
  const TopicProgressService(this._content, this._progress);

  final ContentRepository _content;
  final ProgressRepository _progress;

  /// Строит прогресс по всем темам по порядку для пользователя [userId].
  Future<List<TopicProgress>> buildAll(String userId) async {
    final topics = await _content.getTopics();
    final result = <TopicProgress>[];
    var prevCompleted = true; // первая тема всегда открыта
    for (final topic in topics) {
      final total = await _content.getWordCount(topic.id);
      final learned = await _progress.getLearnedWordCount(userId, topic.id);
      final isDone = total > 0 && learned >= total;

      final TopicStatus status;
      if (isDone) {
        status = TopicStatus.completed;
      } else if (prevCompleted) {
        status = learned > 0 ? TopicStatus.inProgress : TopicStatus.available;
      } else {
        status = TopicStatus.locked;
      }

      result.add(TopicProgress(
        topic: topic,
        learnedWords: learned,
        totalWords: total,
        status: status,
      ));
      prevCompleted = isDone;
    }
    return result;
  }
}
