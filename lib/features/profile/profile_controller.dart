import 'package:flutter/material.dart' show Brightness, ThemeMode;
import 'package:get/get.dart';

import '../../core/services/settings_service.dart';
import '../../core/theme/theme.dart';
import '../../core/services/user_service.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/user_stats.dart';
import '../../domain/repositories/progress_repository.dart';

/// Контроллер экрана «Профиль» и настроек.
class ProfileController extends GetxController {
  /// Создаёт контроллер.
  ProfileController(this._user, this._settings, this._progress);

  final UserService _user;
  final SettingsService _settings;
  final ProgressRepository _progress;

  /// Имя.
  final RxString name = ''.obs;

  /// Подпись даты регистрации.
  final RxString joinedLabel = ''.obs;

  /// Статистика (для мини-статов).
  final Rx<UserStats> stats = UserStats.empty.obs;

  /// Всего слов выучено.
  final RxInt learnedWords = 0.obs;

  /// Письменность.
  final Rx<ScriptMode> scriptMode = ScriptMode.cyrillic.obs;

  /// Дневная цель (минуты).
  final RxInt dailyGoal = 10.obs;

  /// Звук в карточках.
  final RxBool soundEnabled = true.obs;

  /// Напоминания.
  final RxBool remindersEnabled = true.obs;

  /// Режим темы.
  final Rx<ThemeMode> themeMode = ThemeMode.dark.obs;

  /// Идёт ли загрузка.
  final RxBool isLoading = true.obs;

  /// Подпись текущей письменности.
  String get scriptLabel => switch (scriptMode.value) {
        ScriptMode.cyrillic => 'Кириллица',
        ScriptMode.latin => 'Латиница',
        ScriptMode.both => 'Оба варианта',
      };

  /// Подпись текущей темы.
  String get themeLabel => switch (themeMode.value) {
        ThemeMode.dark => 'Тёмная',
        ThemeMode.light => 'Светлая',
        ThemeMode.system => 'Системная',
      };

  @override
  void onInit() {
    super.onInit();
    load();
  }

  /// Загружает профиль и настройки.
  Future<void> load() async {
    isLoading.value = true;
    try {
      name.value = _user.name;
      joinedLabel.value = _user.joinedLabel;
      stats.value = await _progress.getStats(_user.localUserId);
      learnedWords.value =
          await _progress.getTotalLearnedWords(_user.localUserId);
      scriptMode.value = _settings.scriptMode;
      dailyGoal.value = _settings.dailyGoalMinutes;
      soundEnabled.value = _settings.soundEnabled;
      remindersEnabled.value = _settings.remindersEnabled;
      themeMode.value = _settings.themeMode;
    } finally {
      isLoading.value = false;
    }
  }

  /// Сохраняет имя.
  Future<void> setName(String value) async {
    await _user.setName(value);
    name.value = value.trim();
  }

  /// Меняет письменность.
  Future<void> setScriptMode(ScriptMode mode) async {
    await _settings.setScriptMode(mode);
    scriptMode.value = mode;
  }

  /// Меняет дневную цель.
  Future<void> setDailyGoal(int minutes) async {
    await _settings.setDailyGoalMinutes(minutes);
    dailyGoal.value = minutes;
  }

  /// Меняет тему и сразу применяет её: палитра + системные бары +
  /// полный ребилд дерева (цвета берутся из активной палитры).
  Future<void> setThemeMode(ThemeMode mode) async {
    await _settings.setThemeMode(mode);
    themeMode.value = mode;
    AppColors.apply(
      mode,
      platform: Get.mediaQuery.platformBrightness == Brightness.dark
          ? Brightness.dark
          : Brightness.light,
    );
    applySystemBars();
    await Get.forceAppUpdate();
  }

  /// Переключает звук.
  Future<void> setSoundEnabled(bool enabled) async {
    await _settings.setSoundEnabled(enabled);
    soundEnabled.value = enabled;
  }

  /// Переключает напоминания.
  Future<void> setRemindersEnabled(bool enabled) async {
    await _settings.setRemindersEnabled(enabled);
    remindersEnabled.value = enabled;
  }
}
