import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/services/settings_service.dart';
import '../core/theme/theme.dart';
import 'routes/app_pages.dart';

/// Корневой виджет приложения (GetMaterialApp).
///
/// Тема — из дизайн-системы; режим темы берётся из [SettingsService].
/// Глобальные зависимости регистрируются в `InitialBinding` на старте.
class UzLangApp extends StatelessWidget {
  /// Создаёт корневой виджет.
  const UzLangApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsService>();
    return GetMaterialApp(
      title: 'UzLang',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
