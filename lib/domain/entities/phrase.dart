import 'package:freezed_annotation/freezed_annotation.dart';

part 'phrase.freezed.dart';

/// Доменная сущность фразы.
@freezed
abstract class Phrase with _$Phrase {
  /// Создаёт фразу.
  const factory Phrase({
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

    /// Порядок.
    required int sortOrder,

    /// Пример (uz).
    String? exampleUz,

    /// Пример (ru).
    String? exampleRu,

    /// Иллюстрация.
    String? imageUrl,
  }) = _Phrase;
}
