import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../../domain/entities/enums.dart';
import 'daos/content_dao.dart';
import 'daos/progress_dao.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// Локальная база UzLang (SQLite через Drift).
///
/// Хранит учебный контент (сидинг при первом запуске) и прогресс пользователя.
/// Доступ к данным — только через [ContentDao] / [ProgressDao], презентация
/// в базу напрямую не ходит (см. репозитории в `data/repositories`).
@DriftDatabase(
  tables: [Topics, Words, Phrases, CardProgress, UserStats, BlockProgress],
  daos: [ContentDao, ProgressDao],
)
class AppDatabase extends _$AppDatabase {
  /// Боевая база (файл на устройстве). Имя файла — `uzlang`.
  AppDatabase() : super(driftDatabase(name: 'uzlang'));

  /// Конструктор для тестов: принимает произвольный исполнитель
  /// (например `NativeDatabase.memory()`).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        beforeOpen: (details) async {
          // Включаем внешние ключи (по умолчанию в SQLite выключены).
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
