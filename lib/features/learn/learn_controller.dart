import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/lesson_resume_store.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/user_service.dart';
import '../../domain/entities/card_progress.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/word.dart';
import '../../domain/repositories/content_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/services/learning_service.dart';
import '../../domain/services/sr_scheduler.dart';
import 'lesson_args.dart';

/// Контроллер экрана «Слова — Учить» (свайп-карточки блока).
///
/// Прогоняет слова блока по одному. «Знаю» → оценка good, «Ещё учу» → again;
/// каждая оценка пишется в прогресс через [SrScheduler]. После последнего слова
/// ведёт на тест блока.
class LearnController extends GetxController {
  /// Создаёт контроллер.
  LearnController(
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

  /// Слова блока.
  final RxList<Word> words = <Word>[].obs;

  /// Индекс текущей карточки.
  final RxInt index = 0.obs;

  /// Идёт ли загрузка.
  final RxBool isLoading = true.obs;

  /// Текущее слово.
  Word get current => words[index.value];

  @override
  void onInit() {
    super.onInit();
    args = Get.arguments as LessonArgs;
    load();
  }

  /// Загружает слова блока.
  Future<void> load() async {
    isLoading.value = true;
    try {
      final all = await _content.getWords(args.topic.id);
      final start = args.blockIndex * LearningService.blockSize;
      final end = (start + LearningService.blockSize).clamp(0, all.length);
      words.value = start < all.length ? all.sublist(start, end) : [];
      // Продолжаем с места, где остановились в прошлый раз.
      final saved =
          _resume.readIndex(CardKind.word, args.topic.id, args.blockIndex);
      if (saved != null && saved > 0 && saved < words.length) {
        index.value = saved;
      }
    } finally {
      isLoading.value = false;
    }
    // Пустой блок (битый индекс/контент) — выходим, а не висим на спиннере.
    if (words.isEmpty) Get.back<void>();
  }

  /// Озвучивает текущее слово.
  Future<void> playAudio() => _audio.playWord(current.uz);

  /// Защита от двойного тапа: пока пишется прогресс, повторный вызов
  /// игнорируется (иначе двойная запись FSRS по той же карточке).
  bool _busy = false;

  /// Отмечает текущее слово как «знаю»/«ещё учу» и переходит дальше.
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
          CardKind.word,
          current.id,
        ) ??
        freshCardProgress(CardKind.word, current.id);
    final updated = _scheduler.review(
      existing,
      known ? Rating.good : Rating.again,
    );
    await _progress.saveProgress(userId, updated);
    _advance();
  }

  void _advance() {
    if (index.value < words.length - 1) {
      index.value++;
      _resume.saveIndex(
        CardKind.word,
        args.topic.id,
        args.blockIndex,
        index.value,
      );
    } else {
      // Блок доучен — позиция больше не нужна.
      _resume.clear(CardKind.word, args.topic.id, args.blockIndex);
      Get.offNamed<void>(Routes.test, arguments: args);
    }
  }
}
