import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uzlang_mobile/core/services/settings_service.dart';
import 'package:uzlang_mobile/core/services/user_service.dart';
import 'package:uzlang_mobile/domain/entities/enums.dart';
import 'package:uzlang_mobile/features/onboarding/onboarding_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Мок path_provider, чтобы GetStorage инициализировался в тестовой среде.
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => Directory.systemTemp.path,
    );
  });

  late SettingsService settings;
  late UserService user;
  late OnboardingController controller;

  setUp(() async {
    await GetStorage.init('onb');
    final box = GetStorage('onb');
    await box.erase();

    settings = SettingsService(box);
    user = UserService(box, settings);
    controller = OnboardingController(user, settings);
  });

  group('OnboardingController', () {
    test('по умолчанию: кириллица + 10 минут', () {
      expect(controller.scriptMode.value, ScriptMode.cyrillic);
      expect(controller.dailyGoal.value, 10);
    });

    test('selectScript / selectGoal обновляют выбор', () {
      controller.selectScript(ScriptMode.both);
      controller.selectGoal(20);

      expect(controller.scriptMode.value, ScriptMode.both);
      expect(controller.dailyGoal.value, 20);
    });

    test('выбор сохраняется и онбординг помечается пройденным', () async {
      controller.nameField.text = '  Jasur  ';
      controller.selectScript(ScriptMode.latin);
      controller.selectGoal(15);

      await controller.persistChoices();

      expect(user.name, 'Jasur');
      expect(settings.scriptMode, ScriptMode.latin);
      expect(settings.dailyGoalMinutes, 15);
      expect(settings.onboardingCompleted, isTrue);
    });
  });
}
