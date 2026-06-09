import 'package:get/get.dart';

import '../../core/services/user_service.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/services/achievement_service.dart';
import 'progress_controller.dart';

/// Биндинг экрана «Прогресс».
class ProgressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProgressController>(
      () => ProgressController(
        Get.find<UserService>(),
        Get.find<ProgressRepository>(),
        Get.find<AchievementService>(),
      ),
    );
  }
}
