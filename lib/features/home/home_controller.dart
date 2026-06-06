import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/user_service.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/topic_progress.dart';
import '../../domain/entities/user_stats.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/services/topic_progress_service.dart';

/// Контроллер главного экрана.
///
/// Тонкий: собирает данные для Главной (имя, статистика, темы с прогрессом)
/// через сервисы/репозитории. Логика разблокировки тем — в [TopicProgressService].
class HomeController extends GetxController {
  /// Создаёт контроллер.
  HomeController(
      this._user, this._progress, this._settings, this._topicProgress);

  final UserService _user;
  final ProgressRepository _progress;
  final SettingsService _settings;
  final TopicProgressService _topicProgress;

  /// Имя пользователя.
  final RxString userName = ''.obs;

  /// Статистика (XP, streak).
  final Rx<UserStats> stats = UserStats.empty.obs;

  /// Дневная цель (минуты).
  final RxInt dailyGoalMinutes = 10.obs;

  /// Минут пройдено сегодня (в V1 пока 0, наполнится в Фазе 8).
  final RxInt todayMinutes = 0.obs;

  /// Темы с прогрессом.
  final RxList<TopicProgress> topics = <TopicProgress>[].obs;

  /// Сколько карточек к повтору сегодня.
  final RxInt dueCount = 0.obs;

  /// Идёт ли загрузка.
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  /// Тема для карточки «Продолжить» — первая начатая или доступная.
  TopicProgress? get continueTopic {
    for (final t in topics) {
      if (t.status == TopicStatus.inProgress) return t;
    }
    for (final t in topics) {
      if (t.status == TopicStatus.available) return t;
    }
    return null;
  }

  /// Загружает данные Главной.
  Future<void> load() async {
    isLoading.value = true;
    final userId = _user.localUserId;

    userName.value = _user.name;
    dailyGoalMinutes.value = _settings.dailyGoalMinutes;
    stats.value = await _progress.getStats(userId);
    topics.value = await _topicProgress.buildAll(userId);
    dueCount.value =
        (await _progress.getDueCards(userId, CardKind.word, DateTime.now()))
            .length;
    isLoading.value = false;
  }

  /// Действие карточки «Продолжить»: если есть карточки к повтору — повтор,
  /// иначе переход к текущей теме.
  void openContinue() {
    if (dueCount.value > 0) {
      Get.toNamed<void>(Routes.review);
      return;
    }
    final tp = continueTopic;
    if (tp != null) {
      Get.toNamed<void>(Routes.topicDetail, arguments: tp.topic);
    }
  }
}
