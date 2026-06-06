import 'package:get/get.dart';

import '../../core/services/audio_service.dart';
import '../../core/services/user_service.dart';
import '../../domain/repositories/content_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/services/sr_scheduler.dart';
import 'phrase_learn_controller.dart';

/// Биндинг экрана «Фразы — Учить».
class PhraseLearnBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PhraseLearnController>(
      () => PhraseLearnController(
        Get.find<ContentRepository>(),
        Get.find<ProgressRepository>(),
        Get.find<SrScheduler>(),
        Get.find<UserService>(),
        Get.find<AudioService>(),
      ),
    );
  }
}
