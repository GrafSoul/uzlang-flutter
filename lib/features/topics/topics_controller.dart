import 'package:get/get.dart';

import '../../core/services/user_service.dart';
import '../../domain/entities/topic_progress.dart';
import '../../domain/services/topic_progress_service.dart';

/// Контроллер экрана «Выбор темы».
///
/// Грузит темы с прогрессом и раскладывает по секциям: продолжаю, доступные,
/// закрытые.
class TopicsController extends GetxController {
  /// Создаёт контроллер.
  TopicsController(this._user, this._topicProgress);

  final UserService _user;
  final TopicProgressService _topicProgress;

  /// Все темы с прогрессом.
  final RxList<TopicProgress> all = <TopicProgress>[].obs;

  /// Идёт ли загрузка.
  final RxBool isLoading = true.obs;

  /// Темы «продолжаю» (начатые и пройденные).
  List<TopicProgress> get inProgress => all
      .where((t) =>
          t.status == TopicStatus.inProgress ||
          t.status == TopicStatus.completed)
      .toList();

  /// Доступные темы (можно начать).
  List<TopicProgress> get available =>
      all.where((t) => t.status == TopicStatus.available).toList();

  /// Закрытые темы.
  List<TopicProgress> get locked =>
      all.where((t) => t.status == TopicStatus.locked).toList();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  /// Загружает темы.
  Future<void> load() async {
    isLoading.value = true;
    all.value = await _topicProgress.buildAll(_user.localUserId);
    isLoading.value = false;
  }

  /// Подпись для закрытой темы [topic] (первой нужно завершить предыдущую).
  String lockReason(TopicProgress topic) {
    final index = all.indexWhere((t) => t.topic.id == topic.topic.id);
    final isFirstLocked = index > 0 && !all[index - 1].isLocked;
    if (isFirstLocked) {
      return 'Открой «${all[index - 1].topic.title}», чтобы начать';
    }
    return 'Откроется позже';
  }
}
