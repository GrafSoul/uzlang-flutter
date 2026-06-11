import '../../domain/entities/phrase.dart';
import '../../domain/entities/topic.dart';
import '../../domain/entities/word.dart';
import '../../domain/repositories/content_repository.dart';
import '../local/database/daos/content_dao.dart';
import '../local/database/mappers.dart';

/// Реализация [ContentRepository] поверх Drift ([ContentDao]).
class DriftContentRepository implements ContentRepository {
  /// Создаёт репозиторий поверх [_dao].
  DriftContentRepository(this._dao);

  final ContentDao _dao;

  @override
  Future<List<Topic>> getTopics() async {
    final rows = await _dao.getAllTopics();
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<Topic?> getTopicByKey(String key) async {
    return (await _dao.getTopicByKey(key))?.toDomain();
  }

  @override
  Future<List<Word>> getWords(int topicId) async {
    final rows = await _dao.getWordsByTopic(topicId);
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<int> getWordCount(int topicId) => _dao.countWordsByTopic(topicId);

  @override
  Future<Map<int, int>> getWordCountsPerTopic() => _dao.countWordsPerTopic();

  @override
  Future<List<Word>> getWordsByIds(List<int> ids) async {
    final rows = await _dao.getWordsByIds(ids);
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<List<Phrase>> getPhrases(int topicId) async {
    final rows = await _dao.getPhrasesByTopic(topicId);
    return rows.map((r) => r.toDomain()).toList();
  }
}
