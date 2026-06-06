import 'package:get/get.dart';

import '../../core/services/audio_service.dart';
import '../../core/services/user_service.dart';
import '../../domain/entities/card_progress.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/word.dart';
import '../../domain/repositories/content_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/services/sr_scheduler.dart';

/// Контроллер экрана «Слова — Повтор» (интервальное повторение due-карточек).
///
/// Грузит карточки, у которых подошёл срок (FSRS), показывает слово+перевод и
/// принимает оценку (Снова/Трудно/Хорошо/Лёгко), планируя следующий повтор.
class ReviewController extends GetxController {
  /// Создаёт контроллер.
  ReviewController(
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

  /// Due-карточки.
  final RxList<CardProgress> due = <CardProgress>[].obs;

  /// Слова по id.
  final Map<int, Word> _wordsById = {};

  /// Индекс текущей карточки.
  final RxInt index = 0.obs;

  /// Идёт ли загрузка.
  final RxBool isLoading = true.obs;

  /// Текущая карточка прогресса.
  CardProgress get currentProgress => due[index.value];

  /// Текущее слово.
  Word? get currentWord => _wordsById[currentProgress.cardId];

  /// Есть ли что повторять.
  bool get hasCards => due.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  /// Загружает карточки к повтору.
  Future<void> load() async {
    isLoading.value = true;
    final userId = _user.localUserId;
    final cards = await _progress.getDueCards(
      userId,
      CardKind.word,
      DateTime.now(),
    );
    final ids = cards.map((c) => c.cardId).toList();
    final words = await _content.getWordsByIds(ids);
    _wordsById
      ..clear()
      ..addEntries(words.map((w) => MapEntry(w.id, w)));
    due.value = cards.where((c) => _wordsById.containsKey(c.cardId)).toList();
    isLoading.value = false;
  }

  /// Озвучивает текущее слово.
  Future<void> playAudio() async {
    final w = currentWord;
    if (w != null) await _audio.playWord(w.uz);
  }

  /// Применяет оценку и переходит к следующей карточке.
  Future<void> rate(Rating rating) async {
    final updated = _scheduler.review(currentProgress, rating);
    await _progress.saveProgress(_user.localUserId, updated);
    if (index.value < due.length - 1) {
      index.value++;
    } else {
      Get.back<void>();
    }
  }
}
