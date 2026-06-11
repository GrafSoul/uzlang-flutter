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
  ///
  /// Три запроса суммарно (темы + счётчики слов + счётчики выученного),
  /// а не пара запросов на каждую тему.
  Future<List<TopicProgress>> buildAll(String userId) async {
    final topics = await _content.getTopics();
    final totals = await _content.getWordCountsPerTopic();
    final learnedByTopic = await _progress.getLearnedWordCountsPerTopic(userId);
    final result = <TopicProgress>[];
    var prevCompleted = true; // первая тема всегда открыта
    for (final topic in topics) {
      final total = totals[topic.id] ?? 0;
      final learned = learnedByTopic[topic.id] ?? 0;
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
