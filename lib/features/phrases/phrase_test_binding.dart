import 'package:get/get.dart';

import '../../core/services/audio_service.dart';
import '../../core/services/lives_service.dart';
import '../../core/services/user_service.dart';
import '../../domain/repositories/content_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/services/lesson_service.dart';
import 'phrase_test_controller.dart';

/// Биндинг экрана «Фразы — Тест».
class PhraseTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PhraseTestController>(
      () => PhraseTestController(
        Get.find<ContentRepository>(),
        Get.find<UserService>(),
        Get.find<AudioService>(),
        Get.find<LessonService>(),
        Get.find<ProgressRepository>(),
        Get.find<LivesService>(),
      ),
    );
  }
}
