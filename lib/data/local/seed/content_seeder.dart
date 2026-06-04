import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/daos/content_dao.dart';
import 'content_bundle.dart';

/// Хранилище версии засеянного контента (шов под GetStorage / тесты).
///
/// Позволяет сидеру решать, нужен ли пере-сидинг, не завися от конкретной
/// реализации key-value хранилища.
abstract interface class SeedVersionStore {
  /// Версия уже засеянного контента, либо `null`, если ещё не сеяли.
  int? get seededVersion;

  /// Сохраняет версию засеянного контента.
  Future<void> setSeededVersion(int version);
}

/// Результат попытки сидинга.
enum SeedOutcome {
  /// Контент засеян впервые.
  seeded,

  /// Контент пересеян из-за смены версии.
  reseeded,

  /// Сидинг не требовался (актуальная версия уже в базе).
  skipped,
}

/// Засевает учебный контент в БД при первом запуске / смене версии.
///
/// Идемпотентен: повторный вызов с той же версией ничего не делает. Вставка
/// атомарна (в транзакции). Сам JSON загружает вызывающая сторона (см.
/// [parse]); это держит сидер тестируемым без `rootBundle`.
class ContentSeeder {
  /// Создаёт сидер поверх [_dao] и хранилища версии [_versionStore].
  ContentSeeder(this._dao, this._versionStore);

  final ContentDao _dao;
  final SeedVersionStore _versionStore;

  /// Разбирает JSON-строку контента в [ContentBundle].
  static ContentBundle parse(String jsonContent) {
    return ContentBundle.fromJson(
      jsonDecode(jsonContent) as Map<String, dynamic>,
    );
  }

  /// Гарантирует, что контент актуальной версии засеян.
  ///
  /// Возвращает, что именно произошло. Если версия в базе совпадает с версией
  /// пакета и темы есть — пропускает. При несовпадении версии — чистит и сеет
  /// заново.
  Future<SeedOutcome> ensureSeeded(String jsonContent) async {
    final bundle = parse(jsonContent);
    final stored = _versionStore.seededVersion;
    final hasContent = await _dao.countTopics() > 0;

    if (stored == bundle.version && hasContent) {
      return SeedOutcome.skipped;
    }

    final isReseed = hasContent;
    await _dao.attachedDatabase.transaction(() async {
      if (hasContent) {
        await _dao.clearContent();
      }
      await _insert(bundle);
    });
    await _versionStore.setSeededVersion(bundle.version);

    return isReseed ? SeedOutcome.reseeded : SeedOutcome.seeded;
  }

  /// Вставляет темы, затем слова и фразы с разрешением `topicKey → topicId`.
  Future<void> _insert(ContentBundle bundle) async {
    final Map<String, int> topicIdByKey = {};
    for (final t in bundle.topics) {
      final id = await _dao.insertTopic(
        TopicsCompanion.insert(
          key: t.key,
          title: t.title,
          description: t.description,
          sortOrder: t.sortOrder,
        ),
      );
      topicIdByKey[t.key] = id;
    }

    await _dao.insertWords([
      for (final w in bundle.words)
        WordsCompanion.insert(
          topicId: topicIdByKey[w.topicKey]!,
          uz: w.uz,
          reading: w.reading,
          ru: w.ru,
          level: w.level,
          sortOrder: w.sortOrder,
        ),
    ]);

    await _dao.insertPhrases([
      for (final p in bundle.phrases)
        PhrasesCompanion.insert(
          topicId: topicIdByKey[p.topicKey]!,
          uz: p.uz,
          reading: p.reading,
          ru: p.ru,
          sortOrder: p.sortOrder,
          exampleUz: Value(p.exampleUz),
          exampleRu: Value(p.exampleRu),
          imageUrl: Value(p.imageUrl),
        ),
    ]);
  }
}
