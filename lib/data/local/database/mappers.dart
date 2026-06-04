import 'package:drift/drift.dart';

import '../../../domain/entities/card_progress.dart';
import '../../../domain/entities/phrase.dart';
import '../../../domain/entities/topic.dart';
import '../../../domain/entities/word.dart';
import 'app_database.dart';

/// Маппинг строк Drift в доменные сущности и обратно.
///
/// Держит зависимость от Drift внутри слоя данных: домен оперирует только
/// своими сущностями.

/// Преобразование строки темы в доменную [Topic].
extension TopicRowMapper on TopicRow {
  /// Доменная тема.
  Topic toDomain() => Topic(
        id: id,
        key: key,
        title: title,
        description: description,
        sortOrder: sortOrder,
        isPremium: isPremium,
      );
}

/// Преобразование строки слова в доменное [Word].
extension WordRowMapper on WordRow {
  /// Доменное слово.
  Word toDomain() => Word(
        id: id,
        topicId: topicId,
        uz: uz,
        reading: reading,
        ru: ru,
        level: level,
        sortOrder: sortOrder,
      );
}

/// Преобразование строки фразы в доменную [Phrase].
extension PhraseRowMapper on PhraseRow {
  /// Доменная фраза.
  Phrase toDomain() => Phrase(
        id: id,
        topicId: topicId,
        uz: uz,
        reading: reading,
        ru: ru,
        sortOrder: sortOrder,
        exampleUz: exampleUz,
        exampleRu: exampleRu,
        imageUrl: imageUrl,
      );
}

/// Преобразование строки прогресса в доменный [CardProgress].
extension CardProgressRowMapper on CardProgressRow {
  /// Доменное состояние повторения.
  CardProgress toDomain() => CardProgress(
        kind: cardKind,
        cardId: cardId,
        state: state,
        due: DateTime.fromMillisecondsSinceEpoch(due, isUtc: true),
        lastReviewed: lastReviewed == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(lastReviewed!, isUtc: true),
        stability: stability,
        difficulty: difficulty,
        step: step,
        reps: reps,
        lapses: lapses,
      );
}

/// Преобразование доменного прогресса в Drift-companion для сохранения.
extension CardProgressMapper on CardProgress {
  /// Companion для upsert под пользователем [userId].
  CardProgressCompanion toCompanion(String userId) =>
      CardProgressCompanion.insert(
        userId: Value(userId),
        cardKind: kind,
        cardId: cardId,
        stability: Value(stability),
        difficulty: Value(difficulty),
        step: Value(step),
        due: Value(due.toUtc().millisecondsSinceEpoch),
        lastReviewed: Value(lastReviewed?.toUtc().millisecondsSinceEpoch),
        state: Value(state),
        reps: Value(reps),
        lapses: Value(lapses),
      );
}
