import 'package:flutter/services.dart' show rootBundle;

/// Путь к встроенному файлу сид-контента.
const String seedContentAssetPath = 'assets/seed/content.json';

/// Загружает встроенный JSON контента из ассетов (продакшн-путь).
///
/// В тестах файл читается напрямую с диска, чтобы не зависеть от `rootBundle`.
Future<String> loadBundledContentJson() {
  return rootBundle.loadString(seedContentAssetPath);
}
