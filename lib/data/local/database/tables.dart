import 'package:drift/drift.dart';

import '../../../domain/entities/enums.dart';

/// Темы (магазин, базар, город…). Ключ [key] стабилен между релизами контента.
@DataClassName('TopicRow')
class Topics extends Table {
  /// Внутренний автоинкрементный идентификатор.
  IntColumn get id => integer().autoIncrement()();

  /// Стабильный строковый ключ темы (например `store`).
  TextColumn get key => text().unique()();

  /// Заголовок темы (ru).
  TextColumn get title => text()();

  /// Краткое описание темы (ru).
  TextColumn get description => text()();

  /// Порядок отображения.
  IntColumn get sortOrder => integer()();

  /// Платная ли тема (шов под будущий premium; в V1 игнорируется).
  BoolColumn get isPremium => boolean().withDefault(const Constant(false))();
}

/// Слова темы: узбекская латиница + кириллица-чтение + перевод.
@DataClassName('WordRow')
class Words extends Table {
  /// Идентификатор.
  IntColumn get id => integer().autoIncrement()();

  /// Тема, к которой относится слово.
  IntColumn get topicId =>
      integer().references(Topics, #id, onDelete: KeyAction.cascade)();

  /// Узбекская латиница (официальная, для TTS).
  TextColumn get uz => text()();

  /// Кириллица-чтение (помощь новичку).
  TextColumn get reading => text()();

  /// Перевод на русский.
  TextColumn get ru => text()();

  /// Уровень сложности (из исходного контента).
  IntColumn get level => integer()();

  /// Порядок внутри набора (для блоков по 20).
  IntColumn get sortOrder => integer()();
}

/// Фразы темы: закрепление из выученных слов, с примером и иллюстрацией.
@DataClassName('PhraseRow')
class Phrases extends Table {
  /// Идентификатор.
  IntColumn get id => integer().autoIncrement()();

  /// Тема фразы.
  IntColumn get topicId =>
      integer().references(Topics, #id, onDelete: KeyAction.cascade)();

  /// Узбекская латиница.
  TextColumn get uz => text()();

  /// Кириллица-чтение.
  TextColumn get reading => text()();

  /// Перевод на русский.
  TextColumn get ru => text()();

  /// Пример употребления (uz), если есть.
  TextColumn get exampleUz => text().nullable()();

  /// Пример употребления (ru), если есть.
  TextColumn get exampleRu => text().nullable()();

  /// Путь/ссылка на иллюстрацию (опционально).
  TextColumn get imageUrl => text().nullable()();

  /// Порядок внутри набора.
  IntColumn get sortOrder => integer()();
}

/// Прогресс интервального повторения по карточке (слово или фраза).
///
/// Полиморфна: ссылка на карточку = ([cardKind], [cardId]). Поля FSRS
/// ([stability], [difficulty], [due]…) обновляются планировщиком. [userId] —
/// шов под мультипользовательность (в V1 всегда `local`).
@DataClassName('CardProgressRow')
class CardProgress extends Table {
  /// Идентификатор записи прогресса.
  IntColumn get id => integer().autoIncrement()();

  /// Владелец прогресса (анонимный `local` в V1).
  TextColumn get userId => text().withDefault(const Constant('local'))();

  /// Тип карточки (слово/фраза).
  IntColumn get cardKind => intEnum<CardKind>()();

  /// Идентификатор карточки в её таблице ([Words] или [Phrases]).
  IntColumn get cardId => integer()();

  /// FSRS: стабильность памяти (дни). `null` у новой карточки.
  RealColumn get stability => real().nullable()();

  /// FSRS: сложность карточки. `null` у новой карточки.
  RealColumn get difficulty => real().nullable()();

  /// FSRS: текущий шаг обучения/переобучения. `null` в состоянии review.
  IntColumn get step => integer().nullable()();

  /// Момент следующего повтора (epoch ms).
  IntColumn get due => integer().withDefault(const Constant(0))();

  /// Момент последнего повтора (epoch ms), если был.
  IntColumn get lastReviewed => integer().nullable()();

  /// Текущее состояние карточки.
  IntColumn get state =>
      intEnum<SrState>().withDefault(Constant(SrState.newCard.index))();

  /// Число повторов.
  IntColumn get reps => integer().withDefault(const Constant(0))();

  /// Число провалов.
  IntColumn get lapses => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {userId, cardKind, cardId},
      ];
}

/// Агрегированная статистика пользователя (геймификация).
@DataClassName('UserStatRow')
class UserStats extends Table {
  /// Владелец статистики.
  TextColumn get userId => text()();

  /// Накопленный опыт.
  IntColumn get xp => integer().withDefault(const Constant(0))();

  /// Текущая серия дней.
  IntColumn get streakCurrent => integer().withDefault(const Constant(0))();

  /// Лучшая серия дней.
  IntColumn get streakBest => integer().withDefault(const Constant(0))();

  /// Последний активный день (`yyyy-MM-dd`).
  TextColumn get lastActiveDay => text().nullable()();

  /// Дневная цель в минутах.
  IntColumn get dailyGoalMinutes => integer().withDefault(const Constant(10))();

  /// XP, заработанный за текущий день (для прогресса дневной цели).
  IntColumn get todayXp => integer().withDefault(const Constant(0))();

  /// День, к которому относится [todayXp] (`yyyy-MM-dd`).
  TextColumn get todayDate => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {userId};
}

/// Дневная активность: заработанный XP по дням (история для графиков).
@DataClassName('DailyActivityRow')
class DailyActivity extends Table {
  /// Идентификатор.
  IntColumn get id => integer().autoIncrement()();

  /// Владелец.
  TextColumn get userId => text()();

  /// День в формате `YYYY-MM-DD`.
  TextColumn get day => text()();

  /// XP, заработанный за день.
  IntColumn get xp => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {userId, day},
      ];
}

/// Прогресс по блокам (20 карточек): завершение, точность, разблокировка.
@DataClassName('BlockProgressRow')
class BlockProgress extends Table {
  /// Идентификатор.
  IntColumn get id => integer().autoIncrement()();

  /// Владелец.
  TextColumn get userId => text().withDefault(const Constant('local'))();

  /// Тема блока.
  IntColumn get topicId =>
      integer().references(Topics, #id, onDelete: KeyAction.cascade)();

  /// Область блока: слова или фразы.
  IntColumn get scope => intEnum<CardKind>()();

  /// Индекс блока внутри темы (0-based).
  IntColumn get blockIndex => integer()();

  /// Точность прохождения теста блока (0..1).
  RealColumn get accuracy => real().withDefault(const Constant(0))();

  /// Момент завершения (epoch ms), если завершён.
  IntColumn get completedAt => integer().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {userId, topicId, scope, blockIndex},
      ];
}
