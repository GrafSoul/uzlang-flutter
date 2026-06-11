import 'package:flutter_test/flutter_test.dart';
import 'package:uzlang_mobile/domain/entities/card_progress.dart';
import 'package:uzlang_mobile/domain/entities/enums.dart';
import 'package:uzlang_mobile/domain/entities/phrase.dart';
import 'package:uzlang_mobile/domain/entities/topic.dart';
import 'package:uzlang_mobile/domain/entities/topic_progress.dart';
import 'package:uzlang_mobile/domain/entities/user_stats.dart';
import 'package:uzlang_mobile/domain/entities/word.dart';
import 'package:uzlang_mobile/domain/repositories/content_repository.dart';
import 'package:uzlang_mobile/domain/repositories/progress_repository.dart';
import 'package:uzlang_mobile/domain/services/topic_progress_service.dart';

/// Фейковый контент-репозиторий: темы + число слов.
class _FakeContent implements ContentRepository {
  _FakeContent(this.topics, this.counts);

  final List<Topic> topics;
  final Map<int, int> counts;

  @override
  Future<List<Topic>> getTopics() async => topics;

  @override
  Future<int> getWordCount(int topicId) async => counts[topicId] ?? 0;

  @override
  Future<Map<int, int>> getWordCountsPerTopic() async => counts;

  @override
  Future<Topic?> getTopicByKey(String key) => throw UnimplementedError();

  @override
  Future<List<Word>> getWords(int topicId) => throw UnimplementedError();

  @override
  Future<List<Phrase>> getPhrases(int topicId) => throw UnimplementedError();

  @override
  Future<List<Word>> getWordsByIds(List<int> ids) => throw UnimplementedError();
}

/// Фейковый прогресс-репозиторий: число выученных слов по теме.
class _FakeProgress implements ProgressRepository {
  _FakeProgress(this.learned);

  final Map<int, int> learned;

  @override
  Future<int> getLearnedWordCount(String userId, int topicId) async =>
      learned[topicId] ?? 0;

  @override
  Future<Set<int>> getLearnedWordIds(String userId, int topicId) =>
      throw UnimplementedError();

  @override
  Future<Map<int, int>> getLearnedWordCountsPerTopic(String userId) async =>
      learned;

  @override
  Future<void> addDailyXp(String userId, String day, int xp) =>
      throw UnimplementedError();

  @override
  Future<Map<String, int>> getXpByDaySince(String userId, String fromDay) =>
      throw UnimplementedError();

  @override
  Future<UserStats> getStats(String userId) async => UserStats.empty;

  @override
  Future<Set<int>> getCompletedBlockIndices(
          String userId, int topicId, CardKind scope) =>
      throw UnimplementedError();

  @override
  Future<CardProgress?> getProgress(String userId, CardKind kind, int cardId) =>
      throw UnimplementedError();

  @override
  Future<void> saveProgress(String userId, CardProgress progress) =>
      throw UnimplementedError();

  @override
  Future<List<CardProgress>> getDueCards(
          String userId, CardKind kind, DateTime now) =>
      throw UnimplementedError();

  @override
  Future<void> completeBlock(String userId, int topicId, CardKind scope,
          int blockIndex, double accuracy) =>
      throw UnimplementedError();

  @override
  Future<void> saveStats(String userId, UserStats stats) =>
      throw UnimplementedError();

  @override
  Future<int> getTotalLearnedWords(String userId) => throw UnimplementedError();

  @override
  Future<double> getAverageAccuracy(String userId) =>
      throw UnimplementedError();
}

Topic _topic(int id) => Topic(
      id: id,
      key: 't$id',
      title: 'Тема $id',
      description: '',
      sortOrder: id,
    );

void main() {
  final topics = [_topic(1), _topic(2), _topic(3)];
  const counts = {1: 20, 2: 18, 3: 15};

  Future<List<TopicProgress>> build(Map<int, int> learned) {
    final service = TopicProgressService(
      _FakeContent(topics, counts),
      _FakeProgress(learned),
    );
    return service.buildAll('local');
  }

  group('TopicProgressService разблокировка', () {
    test('новый пользователь: первая доступна, остальные заперты', () async {
      final r = await build({});

      expect(r[0].status, TopicStatus.available);
      expect(r[1].status, TopicStatus.locked);
      expect(r[2].status, TopicStatus.locked);
    });

    test('завершение темы открывает следующую', () async {
      final r = await build({1: 20});

      expect(r[0].status, TopicStatus.completed);
      expect(r[1].status, TopicStatus.available);
      expect(r[2].status, TopicStatus.locked);
    });

    test('частичный прогресс = inProgress, проценты верны', () async {
      final r = await build({1: 20, 2: 9});

      expect(r[0].status, TopicStatus.completed);
      expect(r[1].status, TopicStatus.inProgress);
      expect(r[1].percentInt, 50);
      expect(r[2].status, TopicStatus.locked);
    });
  });
}
