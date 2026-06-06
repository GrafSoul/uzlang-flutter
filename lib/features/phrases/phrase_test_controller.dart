import 'dart:math';

import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/user_service.dart';
import '../../domain/entities/phrase.dart';
import '../../domain/repositories/content_repository.dart';
import '../../domain/services/gamification_service.dart';
import '../../domain/services/learning_service.dart';
import '../../domain/services/lesson_service.dart';
import '../learn/lesson_args.dart';
import '../learn/result_args.dart';

/// Вопрос теста фраз: перевод на русский и набор слов для сборки.
class PhraseQuestion {
  /// Создаёт вопрос.
  const PhraseQuestion({
    required this.phrase,
    required this.correctTokens,
    required this.bank,
  });

  /// Фраза.
  final Phrase phrase;

  /// Правильный порядок слов (узбекская латиница).
  final List<String> correctTokens;

  /// Банк слов (перемешан, с дистракторами).
  final List<String> bank;
}

/// Контроллер экрана «Фразы — Тест» («Собери фразу»).
///
/// 10 вопросов (или сколько фраз в блоке), 3 жизни. Игрок собирает узбекский
/// перевод из слов-чипов. Прохождение завершает блок фраз.
class PhraseTestController extends GetxController {
  /// Создаёт контроллер.
  PhraseTestController(this._content, this._user, this._audio, this._lesson);

  final ContentRepository _content;
  final UserService _user;
  final AudioService _audio;
  final LessonService _lesson;

  static const int _maxQuestions = 10;
  static const int _maxLives = 3;

  /// Аргументы сессии.
  late final LessonArgs args;

  /// Вопросы теста.
  final List<PhraseQuestion> questions = [];

  /// Индекс текущего вопроса.
  final RxInt index = 0.obs;

  /// Оставшиеся жизни.
  final RxInt lives = _maxLives.obs;

  /// Число верных ответов.
  final RxInt correct = 0.obs;

  /// Собранный ответ — индексы слов из банка в порядке.
  final RxList<int> answer = <int>[].obs;

  /// Показан ли результат проверки.
  final RxBool revealed = false.obs;

  /// Верен ли собранный ответ (после проверки).
  final RxBool isCorrect = false.obs;

  /// Идёт ли загрузка.
  final RxBool isLoading = true.obs;

  /// Текущий вопрос.
  PhraseQuestion get question => questions[index.value];

  /// Использовано ли слово банка с индексом [i].
  bool isUsed(int i) => answer.contains(i);

  /// Можно ли проверять (все слоты заполнены и ещё не проверено).
  bool get canCheck =>
      !revealed.value && answer.length == question.correctTokens.length;

  /// Собранная строка ответа.
  String get assembled => answer.map((i) => question.bank[i]).join(' ');

  @override
  void onInit() {
    super.onInit();
    args = Get.arguments as LessonArgs;
    load();
  }

  /// Загружает фразы блока и строит вопросы.
  Future<void> load() async {
    isLoading.value = true;
    final all = await _content.getPhrases(args.topic.id);
    final start = args.blockIndex * LearningService.blockSize;
    final end = (start + LearningService.blockSize).clamp(0, all.length);
    final block = start < all.length ? all.sublist(start, end) : <Phrase>[];

    final rnd = Random();
    // Пул слов-дистракторов из всех фраз блока.
    final pool = <String>{
      for (final p in block) ...p.uz.split(RegExp(r'\s+')),
    }.toList();

    final chosen = [...block]..shuffle(rnd);
    for (final p in chosen.take(min(_maxQuestions, block.length))) {
      final tokens = p.uz.split(RegExp(r'\s+'));
      final distractors = (pool.where((t) => !tokens.contains(t)).toList()
            ..shuffle(rnd))
          .take(3)
          .toList();
      final bank = [...tokens, ...distractors]..shuffle(rnd);
      questions.add(PhraseQuestion(
        phrase: p,
        correctTokens: tokens,
        bank: bank,
      ));
    }
    isLoading.value = false;
  }

  /// Озвучивает текущую фразу.
  Future<void> playAudio() => _audio.playWord(question.phrase.uz);

  /// Добавляет слово банка в ответ.
  void pickWord(int bankIndex) {
    if (revealed.value || answer.contains(bankIndex)) return;
    answer.add(bankIndex);
  }

  /// Убирает слово из ответа по позиции.
  void removeWord(int position) {
    if (revealed.value) return;
    answer.removeAt(position);
  }

  /// Проверяет собранный ответ.
  void check() {
    if (!canCheck) return;
    revealed.value = true;
    isCorrect.value = assembled == question.phrase.uz;
    if (isCorrect.value) {
      correct.value++;
    } else {
      lives.value--;
    }
  }

  /// Переход к следующему вопросу или завершение.
  Future<void> next() async {
    if (lives.value <= 0) {
      await Get.offNamed<void>(Routes.noLives, arguments: args);
      return;
    }
    if (index.value < questions.length - 1) {
      index.value++;
      answer.clear();
      revealed.value = false;
      isCorrect.value = false;
      return;
    }
    await _finish();
  }

  Future<void> _finish() async {
    final accuracy = questions.isEmpty ? 1.0 : correct.value / questions.length;
    final stats = await _lesson.completePhraseBlock(
      userId: _user.localUserId,
      topicId: args.topic.id,
      blockIndex: args.blockIndex,
      accuracy: accuracy,
    );

    final total = await _content.getPhrases(args.topic.id);
    final totalBlocks = LearningService().blockCount(total.length);
    final unlockedNext = args.blockIndex + 1 < totalBlocks;

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
        isPhrase: true,
      ),
    );
  }
}
