import 'package:get_storage/get_storage.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/user_profile.dart';
import 'settings_service.dart';

/// Идентичность пользователя (в V1 — локальная анонимная).
///
/// Хранит стабильный `localUserId` (генерится при первом запуске) и имя.
/// Это шов под авторизацию: позже `localUserId` привяжется к аккаунту.
class UserService {
  /// Создаёт сервис; при первом запуске генерирует `localUserId`.
  UserService(this._box, this._settings) {
    if (_box.read<String>(_kId) == null) {
      _box.write(_kId, 'local-${DateTime.now().microsecondsSinceEpoch}');
    }
  }

  final GetStorage _box;
  final SettingsService _settings;

  static const String _kId = 'user.localId';
  static const String _kName = 'user.name';

  /// Стабильный анонимный идентификатор пользователя.
  String get localUserId => _box.read<String>(_kId)!;

  /// Имя пользователя (пустое, пока не введено в онбординге).
  String get name => _box.read<String>(_kName) ?? '';

  /// Введено ли имя.
  bool get hasName => name.isNotEmpty;

  /// Сохраняет имя.
  Future<void> setName(String value) => _box.write(_kName, value.trim());

  /// Текущий профиль (композиция идентичности и настроек).
  UserProfile get profile => UserProfile(
        localUserId: localUserId,
        name: name,
        scriptMode: _settings.scriptMode,
        dailyGoalMinutes: _settings.dailyGoalMinutes,
      );

  /// Изменяет режим письменности профиля.
  Future<void> setScriptMode(ScriptMode mode) => _settings.setScriptMode(mode);
}
