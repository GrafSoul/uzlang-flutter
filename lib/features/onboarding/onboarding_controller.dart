import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/user_service.dart';
import '../../domain/entities/enums.dart';

/// Контроллер онбординга (первый запуск).
///
/// Пошаговый поток по макету Figma: приветствие → имя → письменность → цель →
/// готово. По завершении сохраняет выбор и уходит на главный экран.
class OnboardingController extends GetxController {
  /// Создаёт контроллер поверх сервисов пользователя и настроек.
  OnboardingController(this._user, this._settings);

  final UserService _user;
  final SettingsService _settings;

  /// Всего шагов (страниц PageView).
  static const int stepCount = 5;

  /// Сколько точек-индикаторов прогресса (шаги после приветствия).
  static const int progressDots = 4;

  /// Контроллер страниц PageView.
  final PageController pageController = PageController();

  /// Поле ввода имени.
  final TextEditingController nameField = TextEditingController();

  /// Текущий шаг (0-based): 0 приветствие … 4 готово.
  final RxInt step = 0.obs;

  /// Выбранная письменность (по умолчанию кириллица + чтение).
  final Rx<ScriptMode> scriptMode = ScriptMode.cyrillic.obs;

  /// Выбранная дневная цель (минуты).
  final RxInt dailyGoal = 10.obs;

  /// Введено ли непустое имя (гейт кнопки «Дальше» на шаге имени).
  final RxBool nameEntered = false.obs;

  @override
  void onInit() {
    super.onInit();
    nameField.addListener(
      () => nameEntered.value = nameField.text.trim().isNotEmpty,
    );
  }

  @override
  void onClose() {
    pageController.dispose();
    nameField.dispose();
    super.onClose();
  }

  /// Переход к следующему шагу или завершение на последнем.
  Future<void> next() async {
    if (step.value >= stepCount - 1) {
      await _finish();
      return;
    }
    await _goTo(step.value + 1);
  }

  /// Возврат на предыдущий шаг.
  Future<void> back() async {
    if (step.value == 0) return;
    await _goTo(step.value - 1);
  }

  Future<void> _goTo(int target) async {
    step.value = target;
    await pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  /// Выбирает письменность.
  void selectScript(ScriptMode mode) => scriptMode.value = mode;

  /// Выбирает дневную цель.
  void selectGoal(int minutes) => dailyGoal.value = minutes;

  /// Имя (или пустая строка).
  String get name => nameField.text.trim();

  /// Сохраняет выбор пользователя (имя, письменность, цель) и помечает
  /// онбординг пройденным. Без навигации — для тестируемости.
  Future<void> persistChoices() async {
    await _user.setName(name);
    await _settings.setScriptMode(scriptMode.value);
    await _settings.setDailyGoalMinutes(dailyGoal.value);
    await _settings.setOnboardingCompleted(true);
  }

  /// Сохраняет выбор и уходит на главный экран.
  Future<void> _finish() async {
    await persistChoices();
    await Get.offAllNamed<void>(Routes.home);
  }
}
