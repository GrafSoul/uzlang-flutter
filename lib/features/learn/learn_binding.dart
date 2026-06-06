import 'package:get/get.dart';

import '../../core/services/audio_service.dart';
import '../../core/services/user_service.dart';
import '../../domain/repositories/content_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/services/sr_scheduler.dart';
import 'learn_controller.dart';

/// Биндинг экрана «Слова — Учить».
class LearnBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LearnController>(
      () => LearnController(
        Get.find<ContentRepository>(),
        Get.find<ProgressRepository>(),
        Get.find<SrScheduler>(),
        Get.find<UserService>(),
        Get.find<AudioService>(),
      ),
    );
  }
}
