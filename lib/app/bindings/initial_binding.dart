import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../core/services/access_service.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/flutter_tts_audio_service.dart';
import '../../core/services/lesson_resume_store.dart';
import '../../core/services/lives_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/user_service.dart';
import '../../data/local/database/app_database.dart';
import '../../data/repositories/drift_content_repository.dart';
import '../../data/repositories/drift_progress_repository.dart';
import '../../domain/repositories/content_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/services/achievement_service.dart';
import '../../domain/services/fsrs_scheduler.dart';
import '../../domain/services/gamification_service.dart';
import '../../domain/services/learning_service.dart';
import '../../domain/services/lesson_service.dart';
import '../../domain/services/sr_scheduler.dart';
import '../../domain/services/topic_progress_service.dart';

/// Композиционный корень приложения: регистрирует глобальные сервисы.
///
/// Вызывается на старте (после инициализации БД и сидинга). Все зависимости —
/// `permanent`: живут весь сеанс. Презентация получает их через `Get.find`,
/// зная только интерфейсы (репозитории, [SrScheduler], [AudioService]).
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final db = Get.find<AppDatabase>();
    final box = GetStorage();

    final settings = SettingsService(box);
    Get.put<SettingsService>(settings, permanent: true);
    Get.put<UserService>(UserService(box, settings), permanent: true);
    Get.put<AccessService>(const AccessService(), permanent: true);
    Get.put<LessonResumeStore>(LessonResumeStore(box), permanent: true);
    Get.put<LivesService>(LivesService(box), permanent: true);
    Get.put<NotificationService>(NotificationService(), permanent: true);
    Get.put<AudioService>(
      FlutterTtsAudioService(settings),
      permanent: true,
    );

    Get.put<ContentRepository>(
      DriftContentRepository(db.contentDao),
      permanent: true,
    );
    Get.put<ProgressRepository>(
      DriftProgressRepository(db.progressDao),
      permanent: true,
    );

    Get.put<SrScheduler>(FsrsScheduler(), permanent: true);
    Get.put<LearningService>(const LearningService(), permanent: true);
    Get.put<TopicProgressService>(
      TopicProgressService(
        Get.find<ContentRepository>(),
        Get.find<ProgressRepository>(),
      ),
      permanent: true,
    );

    final gamification = GamificationService(Get.find<ProgressRepository>());
    Get.put<GamificationService>(gamification, permanent: true);
    Get.put<AchievementService>(const AchievementService(), permanent: true);
    Get.put<LessonService>(
      LessonService(Get.find<ProgressRepository>(), gamification),
      permanent: true,
    );
  }
}
