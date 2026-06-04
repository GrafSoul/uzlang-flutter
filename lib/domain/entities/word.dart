import 'package:freezed_annotation/freezed_annotation.dart';

part 'word.freezed.dart';

/// Доменная сущность слова.
@freezed
abstract class Word with _$Word {
  /// Создаёт слово.
  const factory Word({
    /// Идентификатор.
    required int id,

    /// Тема.
    required int topicId,

    /// Узбекская латиница.
    required String uz,

    /// Кириллица-чтение.
    required String reading,

    /// Перевод (ru).
    required String ru,

    /// Уровень.
    required int level,

    /// Порядок.
    required int sortOrder,
  }) = _Word;
}
