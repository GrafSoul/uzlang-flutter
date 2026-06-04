/// DTO-модели для разбора сид-контента (`assets/seed/content.json`).
///
/// Это внутренние модели слоя данных (не доменные сущности): их единственная
/// задача — типобезопасно распарсить JSON перед вставкой в Drift.
library;

/// Распарсенный пакет контента: версия + темы/слова/фразы.
class ContentBundle {
  /// Создаёт пакет контента.
  const ContentBundle({
    required this.version,
    required this.topics,
    required this.words,
    required this.phrases,
  });

  /// Версия контента (для пере-сидинга при обновлении).
  final int version;

  /// Темы.
  final List<SeedTopic> topics;

  /// Слова.
  final List<SeedWord> words;

  /// Фразы.
  final List<SeedPhrase> phrases;

  /// Разбирает пакет из декодированного JSON-объекта.
  factory ContentBundle.fromJson(Map<String, dynamic> json) {
    return ContentBundle(
      version: json['version'] as int,
      topics: (json['topics'] as List<dynamic>)
          .map((e) => SeedTopic.fromJson(e as Map<String, dynamic>))
          .toList(),
      words: (json['words'] as List<dynamic>)
          .map((e) => SeedWord.fromJson(e as Map<String, dynamic>))
          .toList(),
      phrases: (json['phrases'] as List<dynamic>)
          .map((e) => SeedPhrase.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Сид-тема.
class SeedTopic {
  /// Создаёт сид-тему.
  const SeedTopic({
    required this.key,
    required this.title,
    required this.description,
    required this.sortOrder,
  });

  /// Стабильный ключ темы.
  final String key;

  /// Заголовок.
  final String title;

  /// Описание.
  final String description;

  /// Порядок отображения.
  final int sortOrder;

  /// Разбор из JSON.
  factory SeedTopic.fromJson(Map<String, dynamic> json) => SeedTopic(
        key: json['key'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        sortOrder: json['sortOrder'] as int,
      );
}

/// Сид-слово.
class SeedWord {
  /// Создаёт сид-слово.
  const SeedWord({
    required this.topicKey,
    required this.uz,
    required this.reading,
    required this.ru,
    required this.level,
    required this.sortOrder,
  });

  /// Ключ темы, к которой относится слово.
  final String topicKey;

  /// Узбекская латиница.
  final String uz;

  /// Кириллица-чтение.
  final String reading;

  /// Перевод (ru).
  final String ru;

  /// Уровень.
  final int level;

  /// Порядок.
  final int sortOrder;

  /// Разбор из JSON.
  factory SeedWord.fromJson(Map<String, dynamic> json) => SeedWord(
        topicKey: json['topicKey'] as String,
        uz: json['uz'] as String,
        reading: json['reading'] as String,
        ru: json['ru'] as String,
        level: json['level'] as int,
        sortOrder: json['sortOrder'] as int,
      );
}

/// Сид-фраза.
class SeedPhrase {
  /// Создаёт сид-фразу.
  const SeedPhrase({
    required this.topicKey,
    required this.uz,
    required this.reading,
    required this.ru,
    required this.sortOrder,
    this.exampleUz,
    this.exampleRu,
    this.imageUrl,
  });

  /// Ключ темы.
  final String topicKey;

  /// Узбекская латиница.
  final String uz;

  /// Кириллица-чтение.
  final String reading;

  /// Перевод (ru).
  final String ru;

  /// Порядок.
  final int sortOrder;

  /// Пример (uz).
  final String? exampleUz;

  /// Пример (ru).
  final String? exampleRu;

  /// Иллюстрация.
  final String? imageUrl;

  /// Разбор из JSON.
  factory SeedPhrase.fromJson(Map<String, dynamic> json) => SeedPhrase(
        topicKey: json['topicKey'] as String,
        uz: json['uz'] as String,
        reading: json['reading'] as String,
        ru: json['ru'] as String,
        sortOrder: json['sortOrder'] as int,
        exampleUz: json['exampleUz'] as String?,
        exampleRu: json['exampleRu'] as String?,
        imageUrl: json['imageUrl'] as String?,
      );
}
