import 'dart:math';

import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/lives_service.dart';
import '../../core/services/user_service.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/word.dart';
import '../../domain/repositories/content_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/services/gamification_service.dart';
import '../../domain/services/learning_service.dart';
import '../../domain/services/lesson_service.dart';
import 'lesson_args.dart';
import 'result_args.dart';

/// Один вопрос теста: слово и варианты перевода.
class TestQuestion {
  /// Создаёт вопрос.
  const TestQuestion({
    required this.word,
    required this.options,
    required this.correct,
  });

  /// Слово вопроса.
  final Word word;

  /// Варианты перевода (перемешаны).
  final List<String> options;

  /// Правильный перевод.
  final String correct;
}

/// Контроллер экрана «Слова — Тест».
///
/// 10 вопросов (или сколько слов в блоке), 3 жизни. Верный ответ — дальше,
/// неверный — минус жизнь. Прохождение завершает блок (XP + разблокировка).
class TestController extends GetxController {
  /// Создаёт контроллер.
  TestController(
    this._content,
    this._user,
    this._audio,
    this._lesson,
    this._progress,
    this._lives,
  );

  final ContentRepository _content;
  final UserService _user;
  final AudioService _audio;
  final LessonService _lesson;
  final ProgressRepository _progress;
  final LivesService _lives;

  static const int _maxQuestions = 10;

  /// Аргументы сессии.
  late final LessonArgs args;

  /// Вопросы теста.
  final List<TestQuestion> questions = [];

  /// Индекс текущего вопроса.
  final RxInt index = 0.obs;

  /// Оставшиеся жизни (дневной пул, восстанавливается в полночь).
  late final RxInt lives = _lives.lives.obs;

  /// Число верных ответов.
  final RxInt correct = 0.obs;

  /// Выбранный вариант (после ответа), либо `null`.
  final RxnString selected = RxnString();

  /// Показан ли результат ответа.
  final RxBool revealed = false.obs;

  /// Идёт ли загрузка.
  final RxBool isLoading = true.obs;

  /// Текущий вопрос.
  TestQuestion get question => questions[index.value];

  @override
  void onInit() {
    super.onInit();
    args = Get.arguments as LessonArgs;
    if (lives.value <= 0) {
      // Жизни на сегодня кончились — сразу на экран «Нет жизней».
      Future<void>.microtask(
        () => Get.offNamed<void>(Routes.noLives, arguments: args),
      );
      return;
    }
    load();
  }

  /// Загружает слова блока и строит вопросы.
  Future<void> load() async {
    isLoading.value = true;
    try {
      final all = await _content.getWords(args.topic.id);
      final start = args.blockIndex * LearningService.blockSize;
      final end = (start + LearningService.blockSize).clamp(0, all.length);
      final blockWords =
          start < all.length ? all.sublist(start, end) : <Word>[];

      final rnd = Random();
      // Уникальные переводы: дубль ru в блоке дал бы два одинаковых варианта,
      // один из которых считался бы «неверным».
      final pool = blockWords.map((w) => w.ru).toSet().toList();
      final count = min(_maxQuestions, blockWords.length);
      final chosen = [...blockWords]..shuffle(rnd);

      for (final w in chosen.take(count)) {
        final distractors = (pool.where((r) => r != w.ru).toList()
              ..shuffle(rnd))
            .take(3)
            .toList();
        final options = [w.ru, ...distractors]..shuffle(rnd);
        questions.add(TestQuestion(word: w, options: options, correct: w.ru));
      }
    } finally {
      isLoading.value = false;
    }
    // Нет вопросов (битый индекс/контент) — выходим, а не висим на спиннере.
    if (questions.isEmpty) Get.back<void>();
  }

  /// Озвучивает текущее слово.
  Future<void> playAudio() => _audio.playWord(question.word.uz);

  /// Обрабатывает выбор варианта [option].
  void select(String option) {
    if (revealed.value) return;
    selected.value = option;
    revealed.value = true;
    if (option == question.correct) {
      correct.value++;
    } else {
      lives.value--;
      _lives.consume();
    }
  }

  /// Защита от двойного тапа «Продолжить»: завершение блока пишет XP/прогресс
  /// и должно выполниться ровно один раз.
  bool _busy = false;

  /// Переход к следующему вопросу или завершение.
  Future<void> next() async {
    if (_busy) return;
    _busy = true;
    try {
      await _next();
    } finally {
      _busy = false;
    }
  }

  Future<void> _next() async {
    if (lives.value <= 0) {
      await Get.offNamed<void>(Routes.noLives, arguments: args);
      return;
    }
    if (index.value < questions.length - 1) {
      index.value++;
      selected.value = null;
      revealed.value = false;
      return;
    }
    await _finish();
  }

  Future<void> _finish() async {
    final accuracy = questions.isEmpty ? 1.0 : correct.value / questions.length;
    final stats = await _lesson.completeWordBlock(
      userId: _user.localUserId,
      topicId: args.topic.id,
      blockIndex: args.blockIndex,
      accuracy: accuracy,
    );

    final all = await _content.getWordCount(args.topic.id);
    final totalBlocks = const LearningService().blockCount(all);
    // «Открыт Блок N+1» — только если следующий блок существует и не был
    // пройден раньше (перепрохождение старого блока ничего не открывает).
    final completed = await _progress.getCompletedBlockIndices(
      _user.localUserId,
      args.topic.id,
      CardKind.word,
    );
    final next = args.blockIndex + 1;
    final unlockedNext = next < totalBlocks && !completed.contains(next);

    await Get.offNamed<void>(
      Routes.result,
      arguments: ResultArgs(
        topic: args.topic,
        blockNumber: args.blockNumber,
        xpEarned: GamificationService.blockXp,
        accuracy: accuracy,
        streak: stats.streakCurrent,
        unlockedNext: unlockedNext,
        nextArgs: unlockedNext ? args.next() : null,
      ),
    );
  }
}
