import 'package:get/get.dart';

import '../../core/services/user_service.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/topic.dart';
import '../../domain/entities/word_block.dart';
import '../../domain/repositories/content_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/services/learning_service.dart';
import '../learn/lesson_args.dart';

/// Контроллер экрана «Тема — обзор».
///
/// Грузит блоки слов темы (по 20), их статусы (пройден/активен/заперт) и
/// состояние разблокировки фраз.
class TopicDetailController extends GetxController {
  /// Создаёт контроллер.
  TopicDetailController(
    this._user,
    this._content,
    this._progress,
    this._learning,
  );

  final UserService _user;
  final ContentRepository _content;
  final ProgressRepository _progress;
  final LearningService _learning;

  /// Тема (передаётся аргументом маршрута).
  late final Topic topic;

  /// Блоки слов.
  final RxList<WordBlock> blocks = <WordBlock>[].obs;

  /// Блоки фраз (диапазоны + статусы).
  final RxList<BlockInfo> phraseBlocks = <BlockInfo>[].obs;

  /// Активная вкладка: 0 — Слова, 1 — Фразы.
  final RxInt activeTab = 0.obs;

  /// Выучено слов в теме.
  final RxInt learnedWords = 0.obs;

  /// Всего слов в теме.
  final RxInt totalWords = 0.obs;

  /// Всего фраз в теме.
  final RxInt totalPhrases = 0.obs;

  /// Открыты ли фразы темы.
  final RxBool phrasesUnlocked = false.obs;

  /// Текущая серия дней (для пилюли в шапке).
  final RxInt streak = 0.obs;

  /// Идёт ли загрузка.
  final RxBool isLoading = true.obs;

  /// Доля выученного (0..1).
  double get percent =>
      totalWords.value == 0 ? 0 : learnedWords.value / totalWords.value;

  /// Процент выученного (0..100).
  int get percentInt => (percent * 100).round();

  /// Активный блок слов (первый доступный), либо `null`.
  WordBlock? get activeBlock {
    for (final b in blocks) {
      if (b.status == BlockStatus.available) return b;
    }
    return null;
  }

  /// Активный блок фраз (первый доступный), либо `null`.
  BlockInfo? get activePhraseBlock {
    for (final b in phraseBlocks) {
      if (b.status == BlockStatus.available) return b;
    }
    return null;
  }

  /// Сколько слов осталось выучить для разблокировки фраз.
  int get remainingWords =>
      (totalWords.value - learnedWords.value).clamp(0, totalWords.value);

  /// Переключает вкладку.
  void setTab(int index) => activeTab.value = index;

  /// Сколько слов выучено внутри блока [block].
  int learnedInBlock(WordBlock block) {
    final before = block.index * LearningService.blockSize;
    return (learnedWords.value - before).clamp(0, block.words.length);
  }

  @override
  void onInit() {
    super.onInit();
    topic = Get.arguments as Topic;
    load();
  }

  /// Загружает данные обзора темы.
  ///
  /// [silent] — обновить значения без спиннера (рефреш после урока).
  Future<void> load({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    try {
      final userId = _user.localUserId;

      final words = await _content.getWords(topic.id);
      totalWords.value = words.length;
      learnedWords.value =
          await _progress.getLearnedWordCount(userId, topic.id);

      final completed = await _progress.getCompletedBlockIndices(
        userId,
        topic.id,
        CardKind.word,
      );
      blocks.value = _learning.buildWordBlocks(topic.id, words, completed);
      phrasesUnlocked.value = _learning.arePhrasesUnlocked(
        learnedWords: learnedWords.value,
        totalWords: words.length,
      );

      final phrases = await _content.getPhrases(topic.id);
      totalPhrases.value = phrases.length;
      final phraseCompleted = await _progress.getCompletedBlockIndices(
        userId,
        topic.id,
        CardKind.phrase,
      );
      phraseBlocks.value =
          _learning.buildBlocks(phrases.length, phraseCompleted);

      streak.value = (await _progress.getStats(userId)).streakCurrent;
    } finally {
      isLoading.value = false;
    }
  }

  /// Запускает урок по маршруту [route] для блока [blockIndex] и тихо
  /// обновляет обзор по возвращении (выход крестиком тоже меняет прогресс).
  Future<void> startBlock(String route, int blockIndex) async {
    await Get.toNamed<void>(
      route,
      arguments: LessonArgs(topic: topic, blockIndex: blockIndex),
    );
    await load(silent: true);
  }
}
