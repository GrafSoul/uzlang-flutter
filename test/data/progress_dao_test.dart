import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uzlang_mobile/data/local/database/app_database.dart';
import 'package:uzlang_mobile/domain/entities/enums.dart';

/// Регрессия бага «фриз на повторном прохождении»: апсерты должны целиться
/// в составной уникальный ключ, а не в PK `id` — иначе вторая запись по той
/// же карточке/блоку падает с `UNIQUE constraint failed (2067)`.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    // FK на topics: нужна тема, чтобы вставлять block_progress.
    await db.contentDao.insertTopic(
      TopicsCompanion.insert(
        key: 't1',
        title: 'Тест',
        description: '',
        sortOrder: 0,
      ),
    );
  });

  tearDown(() async => db.close());

  CardProgressCompanion card({required int reps}) =>
      CardProgressCompanion.insert(
        userId: const Value('local'),
        cardKind: CardKind.word,
        cardId: 41,
        due: const Value(1000),
        reps: Value(reps),
      );

  group('ProgressDao.upsertProgress', () {
    test('повторный апсерт той же карточки обновляет, а не падает', () async {
      await db.progressDao.upsertProgress(card(reps: 1));
      // До фикса вторая вставка кидала SqliteException(2067).
      await db.progressDao.upsertProgress(card(reps: 2));

      final row = await db.progressDao.getProgress('local', CardKind.word, 41);
      expect(row, isNotNull);
      expect(row!.reps, 2);
    });
  });

  group('ProgressDao.markBlockCompleted', () {
    test('повторное завершение блока обновляет, а не падает', () async {
      await db.progressDao
          .markBlockCompleted('local', 1, CardKind.word, 0, 0.8, 111);
      // До фикса перепрохождение блока кидало SqliteException(2067).
      await db.progressDao
          .markBlockCompleted('local', 1, CardKind.word, 0, 1.0, 222);

      final blocks = await db.progressDao.getBlocks('local', 1, CardKind.word);
      expect(blocks.length, 1);
      expect(blocks.single.accuracy, 1.0);
      expect(blocks.single.completedAt, 222);
    });
  });
}
