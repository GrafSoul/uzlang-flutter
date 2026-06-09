import 'package:get/get.dart';

import '../../core/services/settings_service.dart';
import '../../core/services/user_service.dart';
import '../../domain/repositories/progress_repository.dart';
import 'profile_controller.dart';

/// Биндинг экрана «Профиль».
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        Get.find<UserService>(),
        Get.find<SettingsService>(),
        Get.find<ProgressRepository>(),
      ),
    );
  }
}
