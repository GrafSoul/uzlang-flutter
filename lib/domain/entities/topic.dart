import 'package:freezed_annotation/freezed_annotation.dart';

part 'topic.freezed.dart';

/// Доменная сущность темы (иммутабельна, не зависит от Drift).
@freezed
abstract class Topic with _$Topic {
  /// Создаёт тему.
  const factory Topic({
    /// Идентификатор.
    required int id,

    /// Стабильный ключ (например `store`).
    required String key,

    /// Заголовок (ru).
    required String title,

    /// Описание (ru).
    required String description,

    /// Порядок отображения.
    required int sortOrder,

    /// Платная ли тема (в V1 игнорируется).
    @Default(false) bool isPremium,
  }) = _Topic;
}
