import 'package:get_storage/get_storage.dart';

import '../../data/local/seed/content_seeder.dart';

/// Реализация [SeedVersionStore] поверх GetStorage.
///
/// Хранит версию засеянного контента в key-value боксе. Требует
/// предварительного `await GetStorage.init()` на старте приложения.
class GetStorageSeedVersionStore implements SeedVersionStore {
  /// Создаёт хранилище поверх переданного [_box].
  GetStorageSeedVersionStore(this._box);

  final GetStorage _box;

  static const String _key = 'content.seededVersion';

  @override
  int? get seededVersion => _box.read<int>(_key);

  @override
  Future<void> setSeededVersion(int version) => _box.write(_key, version);
}
