import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uzlang_mobile/data/local/database/app_database.dart';
import 'package:uzlang_mobile/data/local/seed/content_seeder.dart';

/// In-memory реализация [SeedVersionStore] для тестов.
class _FakeVersionStore implements SeedVersionStore {
  int? _version;

  @override
  int? get seededVersion => _version;

  @override
  Future<void> setSeededVersion(int version) async => _version = version;
}

void main() {
  late AppDatabase db;
  late _FakeVersionStore store;
  late ContentSeeder seeder;
  late String contentJson;

  setUpAll(() {
    // Реальный сид-контент читаем напрямую с диска (cwd = корень пакета).
    contentJson = File('assets/seed/content.json').readAsStringSync();
  });

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    store = _FakeVersionStore();
    seeder = ContentSeeder(db.contentDao, store);
  });

  tearDown(() async => db.close());

  group('ContentSeeder', () {
    test('сеет полный контент при первом запуске', () async {
      final outcome = await seeder.ensureSeeded(contentJson);

      expect(outcome, SeedOutcome.seeded);
      expect(await db.contentDao.countTopics(), 17);
      expect(await db.contentDao.countWords(), 2922);
      expect(await db.contentDao.countPhrases(), 255);
      expect(store.seededVersion, 1);
    });

    test('идемпотентен: повторный вызов пропускается', () async {
      await seeder.ensureSeeded(contentJson);
      final second = await seeder.ensureSeeded(contentJson);

      expect(second, SeedOutcome.skipped);
      // Дубликатов не появилось.
      expect(await db.contentDao.countTopics(), 17);
      expect(await db.contentDao.countWords(), 2922);
    });

    test('пере-сеет при смене версии контента', () async {
      await seeder.ensureSeeded(contentJson);
      // Подменяем версию на меньшую, имитируя устаревший контент в базе.
      await store.setSeededVersion(0);

      final outcome = await seeder.ensureSeeded(contentJson);

      expect(outcome, SeedOutcome.reseeded);
      expect(await db.contentDao.countTopics(), 17);
      expect(await db.contentDao.countWords(), 2922);
    });
  });

  group('ContentDao', () {
    setUp(() async => seeder.ensureSeeded(contentJson));

    test('темы возвращаются по порядку sortOrder', () async {
      final topics = await db.contentDao.getAllTopics();

      expect(topics.length, 17);
      expect(topics.first.key, 'store');
      for (var i = 1; i < topics.length; i++) {
        expect(topics[i].sortOrder >= topics[i - 1].sortOrder, isTrue);
      }
    });

    test('поиск темы по ключу', () async {
      final topic = await db.contentDao.getTopicByKey('bazaar');

      expect(topic, isNotNull);
      expect(topic!.title, 'Базар: овощи и фрукты');
    });

    test('слова и фразы привязаны к существующей теме', () async {
      final store = await db.contentDao.getTopicByKey('store');
      final words = await db.contentDao.getWordsByTopic(store!.id);
      final phrases = await db.contentDao.getPhrasesByTopic(store.id);

      expect(words, isNotEmpty);
      expect(phrases, isNotEmpty);
      expect(words.every((w) => w.topicId == store.id), isTrue);
      expect(phrases.every((p) => p.topicId == store.id), isTrue);
    });
  });
}
