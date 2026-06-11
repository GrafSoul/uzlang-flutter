import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/app.dart';
import 'app/bindings/initial_binding.dart';
import 'core/services/get_storage_seed_version_store.dart';
import 'core/theme/theme.dart';
import 'data/local/database/app_database.dart';
import 'data/local/seed/content_seeder.dart';
import 'data/local/seed/seed_assets.dart';

/// Точка входа: инициализация хранилища, БД, сидинг контента, DI, запуск.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Глобальные обработчики: необработанная ошибка логируется, а не роняет
  // приложение молча.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught: $error\n$stack');
    return true; // обработано — процесс живёт
  };

  // В релизе вместо серого ящика Flutter — аккуратная заглушка в цветах DS.
  ErrorWidget.builder = (details) => Container(
        color: AppColors.bg,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: const Text(
          'Что-то пошло не так',
          textDirection: TextDirection.ltr,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
      );

  // Системные бары под тёмную тему DS (низ Android — тёмный, иконки светлые).
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0x00000000),
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.bg,
      systemNavigationBarDividerColor: AppColors.bg,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

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
