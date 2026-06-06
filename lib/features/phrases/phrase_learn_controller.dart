import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/user_service.dart';
import '../../domain/entities/card_progress.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/phrase.dart';
import '../../domain/repositories/content_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/services/learning_service.dart';
import '../../domain/services/sr_scheduler.dart';
import '../learn/lesson_args.dart';

/// Контроллер экрана «Фразы — Учить» (свайп-карточки блока фраз).
///
/// Аналог обучения словам, но для фраз: оценка «Знаю»/«Ещё учу» пишется во
/// FSRS (cardKind=phrase). После блока ведёт на тест «Собери фразу».
class PhraseLearnController extends GetxController {
  /// Создаёт контроллер.
  PhraseLearnController(
    this._content,
    this._progress,
    this._scheduler,
    this._user,
    this._audio,
  );

  final ContentRepository _content;
  final ProgressRepository _progress;
  final SrScheduler _scheduler;
  final UserService _user;
  final AudioService _audio;

  /// Аргументы сессии.
  late final LessonArgs args;

  /// Фразы блока.
  final RxList<Phrase> phrases = <Phrase>[].obs;

  /// Индекс текущей карточки.
  final RxInt index = 0.obs;

  /// Идёт ли загрузка.
  final RxBool isLoading = true.obs;

  /// Текущая фраза.
  Phrase get current => phrases[index.value];

  @override
  void onInit() {
    super.onInit();
    args = Get.arguments as LessonArgs;
    load();
  }

  /// Загружает фразы блока.
  Future<void> load() async {
    isLoading.value = true;
    final all = await _content.getPhrases(args.topic.id);
    final start = args.blockIndex * LearningService.blockSize;
    final end = (start + LearningService.blockSize).clamp(0, all.length);
    phrases.value = start < all.length ? all.sublist(start, end) : [];
    isLoading.value = false;
  }

  /// Озвучивает текущую фразу.
  Future<void> playAudio() => _audio.playWord(current.uz);

  /// Отмечает фразу и переходит дальше.
  Future<void> mark({required bool known}) async {
    final userId = _user.localUserId;
    final existing = await _progress.getProgress(
          userId,
          CardKind.phrase,
          current.id,
        ) ??
        freshCardProgress(CardKind.phrase, current.id);
    final updated = _scheduler.review(
      existing,
      known ? Rating.good : Rating.again,
    );
    await _progress.saveProgress(userId, updated);
    _advance();
  }

  void _advance() {
    if (index.value < phrases.length - 1) {
      index.value++;
    } else {
      Get.offNamed<void>(Routes.phraseTest, arguments: args);
    }
  }
}
