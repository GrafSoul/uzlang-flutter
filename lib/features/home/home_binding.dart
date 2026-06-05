import 'package:get/get.dart';

import '../../core/services/settings_service.dart';
import '../../core/services/user_service.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/services/topic_progress_service.dart';
import 'home_controller.dart';

/// Биндинг главного экрана: ленивая регистрация [HomeController].
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(
        Get.find<UserService>(),
        Get.find<ProgressRepository>(),
        Get.find<SettingsService>(),
        Get.find<TopicProgressService>(),
      ),
    );
  }
}
