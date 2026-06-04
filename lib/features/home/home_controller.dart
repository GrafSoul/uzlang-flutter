import 'package:get/get.dart';

import '../../domain/entities/topic.dart';
import '../../domain/repositories/content_repository.dart';

/// Контроллер главного экрана.
///
/// Тонкий: держит реактивное состояние и дёргает [ContentRepository].
/// Бизнес-логики и обращения к БД напрямую — нет.
class HomeController extends GetxController {
  /// Создаёт контроллер поверх репозитория контента.
  HomeController(this._content);

  final ContentRepository _content;

  /// Список тем.
  final RxList<Topic> topics = <Topic>[].obs;

  /// Идёт ли загрузка.
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadTopics();
  }

  /// Загружает темы из репозитория.
  Future<void> loadTopics() async {
    isLoading.value = true;
    topics.value = await _content.getTopics();
    isLoading.value = false;
  }
}
