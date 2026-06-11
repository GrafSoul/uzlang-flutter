import 'package:get_storage/get_storage.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/user_profile.dart';
import 'settings_service.dart';

/// Идентичность пользователя (в V1 — локальная анонимная).
///
/// Хранит стабильный `localUserId` (генерится при первом запуске) и имя.
/// Это шов под авторизацию: позже `localUserId` привяжется к аккаунту.
class UserService {
  /// Создаёт сервис; при первом запуске фиксирует `localUserId` и дату входа.
  UserService(this._box, this._settings) {
    if (_box.read<String>(_kId) == null) {
      _box.write(_kId, 'local-${DateTime.now().microsecondsSinceEpoch}');
    }
    if (_box.read<String>(_kJoin) == null) {
      _box.write(_kJoin, DateTime.now().toIso8601String());
    }
  }

  final GetStorage _box;
  final SettingsService _settings;

  static const String _kId = 'user.localId';
  static const String _kName = 'user.name';
  static const String _kJoin = 'user.joinedAt';

  static const List<String> _monthsGenitive = [
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];

  /// Дата регистрации (первый запуск).
  DateTime get joinedAt =>
      DateTime.tryParse(_box.read<String>(_kJoin) ?? '') ?? DateTime.now();

  /// Подпись «с {месяц} {год}».
  String get joinedLabel {
    final d = joinedAt;
    return 'с ${_monthsGenitive[d.month - 1]} ${d.year}';
  }

  /// Стабильный анонимный идентификатор пользователя.
  ///
  /// Если хранилище потеряло запись (сбой GetStorage на первом запуске),
  /// генерирует новый id вместо краша всех контроллеров.
  String get localUserId {
    final id = _box.read<String>(_kId);
    if (id != null) return id;
    final fresh = 'local-${DateTime.now().microsecondsSinceEpoch}';
    _box.write(_kId, fresh);
    return fresh;
  }

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
