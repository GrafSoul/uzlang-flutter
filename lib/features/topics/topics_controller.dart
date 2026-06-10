import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
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
  ///
  /// [silent] — обновить список без спиннера (рефреш при возврате назад).
  Future<void> load({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    try {
      all.value = await _topicProgress.buildAll(_user.localUserId);
    } finally {
      isLoading.value = false;
    }
  }

  /// Открывает обзор темы и тихо обновляет список по возвращении.
  Future<void> openTopic(TopicProgress tp) async {
    await Get.toNamed<void>(Routes.topicDetail, arguments: tp.topic);
    await load(silent: true);
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
