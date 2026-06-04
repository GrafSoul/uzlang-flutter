import 'package:get/get.dart';

import '../../domain/repositories/content_repository.dart';
import 'home_controller.dart';

/// Биндинг главного экрана: ленивая регистрация [HomeController].
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<ContentRepository>()),
    );
  }
}
