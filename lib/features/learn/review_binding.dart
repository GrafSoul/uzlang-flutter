import 'package:get/get.dart';

import '../../core/services/audio_service.dart';
import '../../core/services/user_service.dart';
import '../../domain/repositories/content_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/services/gamification_service.dart';
import '../../domain/services/sr_scheduler.dart';
import 'review_controller.dart';

/// Биндинг экрана «Слова — Повтор».
class ReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReviewController>(
      () => ReviewController(
        Get.find<ContentRepository>(),
        Get.find<ProgressRepository>(),
        Get.find<SrScheduler>(),
        Get.find<UserService>(),
        Get.find<AudioService>(),
        Get.find<GamificationService>(),
      ),
    );
  }
}
