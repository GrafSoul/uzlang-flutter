import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/lesson_resume_store.dart';
import '../../core/services/settings_service.dart';
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
    this._resume,
    this._settings,
  );

  final ContentRepository _content;
  final ProgressRepository _progress;
  final SrScheduler _scheduler;
  final UserService _user;
  final AudioService _audio;
  final LessonResumeStore _resume;
  final SettingsService _settings;

  /// Текущая письменность карточек (меняется на лету из «Настроек урока»).
  late final Rx<ScriptMode> scriptMode = _settings.scriptMode.obs;

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
    try {
      final all = await _content.getPhrases(args.topic.id);
      final start = args.blockIndex * LearningService.blockSize;
      final end = (start + LearningService.blockSize).clamp(0, all.length);
      phrases.value = start < all.length ? all.sublist(start, end) : [];
      // Продолжаем с места, где остановились в прошлый раз.
      final saved =
          _resume.readIndex(CardKind.phrase, args.topic.id, args.blockIndex);
      if (saved != null && saved > 0 && saved < phrases.length) {
        index.value = saved;
      }
    } finally {
      isLoading.value = false;
    }
    // Пустой блок (битый индекс/контент) — выходим, а не висим на спиннере.
    if (phrases.isEmpty) Get.back<void>();
  }

  /// Озвучивает текущую фразу.
  Future<void> playAudio() => _audio.playWord(current.uz);

  /// Защита от двойного тапа: пока пишется прогресс, повторный вызов
  /// игнорируется (иначе двойная запись FSRS по той же карточке).
  bool _busy = false;

  /// Отмечает фразу и переходит дальше.
  Future<void> mark({required bool known}) async {
    if (_busy) return;
    _busy = true;
    try {
      await _mark(known: known);
    } finally {
      _busy = false;
    }
  }

  Future<void> _mark({required bool known}) async {
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
      _resume.saveIndex(
        CardKind.phrase,
        args.topic.id,
        args.blockIndex,
        index.value,
      );
    } else {
      // Блок доучен — позиция больше не нужна.
      _resume.clear(CardKind.phrase, args.topic.id, args.blockIndex);
      Get.offNamed<void>(Routes.phraseTest, arguments: args);
    }
  }
}
