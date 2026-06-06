import '../entities/phrase.dart';
import '../entities/topic.dart';
import '../entities/word.dart';

/// Доступ к учебному контенту (абстракция).
///
/// Реализация — в слое данных (Drift). Через этот интерфейс позже подключается
/// облачный источник контента без изменений в домене/презентации.
abstract interface class ContentRepository {
  /// Все темы в порядке отображения.
  Future<List<Topic>> getTopics();

  /// Тема по стабильному ключу, либо `null`.
  Future<Topic?> getTopicByKey(String key);

  /// Слова темы по порядку.
  Future<List<Word>> getWords(int topicId);

  /// Количество слов в теме.
  Future<int> getWordCount(int topicId);

  /// Слова по списку идентификаторов.
  Future<List<Word>> getWordsByIds(List<int> ids);

  /// Фразы темы по порядку.
  Future<List<Phrase>> getPhrases(int topicId);
}
