import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'content_dao.g.dart';

/// DAO доступа к учебному контенту (темы, слова, фразы).
///
/// Только чтение для UI + батч-вставка для сидинга. Бизнес-логики здесь нет —
/// она в domain-сервисах; DAO остаётся тонким слоем запросов.
@DriftAccessor(tables: [Topics, Words, Phrases])
class ContentDao extends DatabaseAccessor<AppDatabase> with _$ContentDaoMixin {
  /// Создаёт DAO, привязанный к базе [db].
  ContentDao(super.db);

  /// Все темы в порядке отображения.
  Future<List<TopicRow>> getAllTopics() {
    return (select(topics)
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get();
  }

  /// Тема по стабильному ключу, либо `null`.
  Future<TopicRow?> getTopicByKey(String key) {
    return (select(topics)..where((t) => t.key.equals(key))).getSingleOrNull();
  }

  /// Слова темы по порядку.
  Future<List<WordRow>> getWordsByTopic(int topicId) {
    return (select(words)
          ..where((w) => w.topicId.equals(topicId))
          ..orderBy([(w) => OrderingTerm(expression: w.sortOrder)]))
        .get();
  }

  /// Фразы темы по порядку.
  Future<List<PhraseRow>> getPhrasesByTopic(int topicId) {
    return (select(phrases)
          ..where((p) => p.topicId.equals(topicId))
          ..orderBy([(p) => OrderingTerm(expression: p.sortOrder)]))
        .get();
  }

  /// Количество тем (для проверки сидинга).
  Future<int> countTopics() => topics.count().getSingle();

  /// Количество слов.
  Future<int> countWords() => words.count().getSingle();

  /// Количество фраз.
  Future<int> countPhrases() => phrases.count().getSingle();

  /// Вставляет тему и возвращает её сгенерированный id.
  Future<int> insertTopic(TopicsCompanion topic) {
    return into(topics).insert(topic);
  }

  /// Батч-вставка слов.
  Future<void> insertWords(List<WordsCompanion> rows) {
    return batch((b) => b.insertAll(words, rows));
  }

  /// Батч-вставка фраз.
  Future<void> insertPhrases(List<PhrasesCompanion> rows) {
    return batch((b) => b.insertAll(phrases, rows));
  }

  /// Полная очистка контента (для пере-сидинга при смене версии).
  Future<void> clearContent() async {
    await delete(phrases).go();
    await delete(words).go();
    await delete(topics).go();
  }
}
