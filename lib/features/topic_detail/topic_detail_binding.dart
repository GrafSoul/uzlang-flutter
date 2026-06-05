import 'package:get/get.dart';

import '../../core/services/user_service.dart';
import '../../domain/repositories/content_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/services/learning_service.dart';
import 'topic_detail_controller.dart';

/// Биндинг экрана «Тема — обзор».
class TopicDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TopicDetailController>(
      () => TopicDetailController(
        Get.find<UserService>(),
        Get.find<ContentRepository>(),
        Get.find<ProgressRepository>(),
        Get.find<LearningService>(),
      ),
    );
  }
}
