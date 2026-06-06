import 'package:get/get.dart';

import '../../core/services/audio_service.dart';
import '../../core/services/user_service.dart';
import '../../domain/repositories/content_repository.dart';
import '../../domain/services/lesson_service.dart';
import 'test_controller.dart';

/// Биндинг экрана «Слова — Тест».
class TestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TestController>(
      () => TestController(
        Get.find<ContentRepository>(),
        Get.find<UserService>(),
        Get.find<AudioService>(),
        Get.find<LessonService>(),
      ),
    );
  }
}
