import 'package:get/get.dart';

import '../../core/services/user_service.dart';
import '../../domain/services/topic_progress_service.dart';
import 'topics_controller.dart';

/// Биндинг экрана «Выбор темы».
class TopicsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TopicsController>(
      () => TopicsController(
        Get.find<UserService>(),
        Get.find<TopicProgressService>(),
      ),
    );
  }
}
