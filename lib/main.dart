import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/app.dart';
import 'app/bindings/initial_binding.dart';
import 'core/services/get_storage_seed_version_store.dart';
import 'data/local/database/app_database.dart';
import 'data/local/seed/content_seeder.dart';
import 'data/local/seed/seed_assets.dart';

/// Точка входа: инициализация хранилища, БД, сидинг контента, DI, запуск.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Локальная БД — единственный экземпляр на сеанс.
  final db = AppDatabase();
  Get.put<AppDatabase>(db, permanent: true);

  // Сидинг встроенного контента при первом запуске / смене версии.
  final seeder = ContentSeeder(
    db.contentDao,
    GetStorageSeedVersionStore(GetStorage()),
  );
  await seeder.ensureSeeded(await loadBundledContentJson());

  // Композиционный корень: регистрируем глобальные сервисы.
  InitialBinding().dependencies();

  runApp(const UzLangApp());
}
