import 'package:flutter/material.dart' show ThemeMode;
import 'package:get_storage/get_storage.dart';

import '../../domain/entities/enums.dart';

/// Пользовательские настройки поверх GetStorage.
///
/// Письменность, дневная цель, звук, тема, флаг пройденного онбординга.
/// Требует `await GetStorage.init()` на старте.
class SettingsService {
  /// Создаёт сервис поверх бокса [_box].
  SettingsService(this._box);

  final GetStorage _box;

  static const String _kScript = 'settings.scriptMode';
  static const String _kGoal = 'settings.dailyGoalMinutes';
  static const String _kSound = 'settings.soundEnabled';
  static const String _kTheme = 'settings.themeMode';
  static const String _kOnboarding = 'settings.onboardingCompleted';
  static const String _kReminders = 'settings.remindersEnabled';

  /// Режим письменности (по умолчанию кириллица).
  ScriptMode get scriptMode =>
      ScriptMode.values[_box.read<int>(_kScript) ?? ScriptMode.cyrillic.index];

  /// Сохраняет режим письменности.
  Future<void> setScriptMode(ScriptMode mode) =>
      _box.write(_kScript, mode.index);

  /// Дневная цель в минутах (по умолчанию 10).
  int get dailyGoalMinutes => _box.read<int>(_kGoal) ?? 10;

  /// Сохраняет дневную цель.
  Future<void> setDailyGoalMinutes(int minutes) => _box.write(_kGoal, minutes);

  /// Включён ли звук (по умолчанию да).
  bool get soundEnabled => _box.read<bool>(_kSound) ?? true;

  /// Переключает звук.
  Future<void> setSoundEnabled(bool enabled) => _box.write(_kSound, enabled);

  /// Режим темы (по умолчанию тёмная).
  ThemeMode get themeMode =>
      ThemeMode.values[_box.read<int>(_kTheme) ?? ThemeMode.dark.index];

  /// Сохраняет режим темы.
  Future<void> setThemeMode(ThemeMode mode) => _box.write(_kTheme, mode.index);

  /// Включены ли напоминания (по умолчанию да).
  bool get remindersEnabled => _box.read<bool>(_kReminders) ?? true;

  /// Переключает напоминания.
  Future<void> setRemindersEnabled(bool enabled) =>
      _box.write(_kReminders, enabled);

  /// Пройден ли онбординг.
  bool get onboardingCompleted => _box.read<bool>(_kOnboarding) ?? false;

  /// Помечает онбординг как пройденный/нет.
  Future<void> setOnboardingCompleted(bool done) =>
      _box.write(_kOnboarding, done);
}
