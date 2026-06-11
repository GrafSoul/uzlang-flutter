import 'package:get_storage/get_storage.dart';

import '../../domain/entities/enums.dart';

/// Запоминает позицию внутри блока «Учить» (слова и фразы).
///
/// Вышел посреди блока — при следующем входе продолжаешь с той же карточки,
/// а не с начала. Позиция сбрасывается, когда блок доучен (переход к тесту).
class LessonResumeStore {
  /// Создаёт хранилище поверх бокса [_box].
  LessonResumeStore(this._box);

  final GetStorage _box;

  String _key(CardKind kind, int topicId, int blockIndex) =>
      'lesson.resume.${kind.name}.$topicId.$blockIndex';

  /// Сохранённый индекс карточки, либо `null`, если блок не начат/доучен.
  int? readIndex(CardKind kind, int topicId, int blockIndex) =>
      _box.read<int>(_key(kind, topicId, blockIndex));

  /// Сохраняет индекс текущей карточки [index].
  Future<void> saveIndex(
    CardKind kind,
    int topicId,
    int blockIndex,
    int index,
  ) =>
      _box.write(_key(kind, topicId, blockIndex), index);

  /// Сбрасывает сохранённую позицию (блок доучен до конца).
  Future<void> clear(CardKind kind, int topicId, int blockIndex) =>
      _box.remove(_key(kind, topicId, blockIndex));
}
