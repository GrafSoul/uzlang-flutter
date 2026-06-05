import 'package:get/get.dart';

import '../../core/services/user_service.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/topic.dart';
import '../../domain/entities/word_block.dart';
import '../../domain/repositories/content_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/services/learning_service.dart';

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

  /// Выучено слов в теме.
  final RxInt learnedWords = 0.obs;

  /// Всего слов в теме.
  final RxInt totalWords = 0.obs;

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

  /// Активный блок (первый доступный, не пройденный), либо `null`.
  WordBlock? get activeBlock {
    for (final b in blocks) {
      if (b.status == BlockStatus.available) return b;
    }
    return null;
  }

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
  Future<void> load() async {
    isLoading.value = true;
    final userId = _user.localUserId;

    final words = await _content.getWords(topic.id);
    totalWords.value = words.length;
    learnedWords.value = await _progress.getLearnedWordCount(userId, topic.id);

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
    streak.value = (await _progress.getStats(userId)).streakCurrent;

    isLoading.value = false;
  }
}
