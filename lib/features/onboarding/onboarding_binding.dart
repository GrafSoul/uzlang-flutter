import 'package:get/get.dart';

import '../../core/services/settings_service.dart';
import '../../core/services/user_service.dart';
import 'onboarding_controller.dart';

/// Биндинг онбординга: ленивая регистрация [OnboardingController].
class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(
      () => OnboardingController(
        Get.find<UserService>(),
        Get.find<SettingsService>(),
      ),
    );
  }
}
