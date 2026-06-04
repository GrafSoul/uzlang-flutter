import '../entities/card_progress.dart';
import '../entities/enums.dart';

/// Планировщик интервального повторения (абстракция).
///
/// Скрывает конкретный алгоритм (FSRS) за интерфейсом: его можно заменить или
/// перенастроить, не трогая сервисы обучения и презентацию.
abstract interface class SrScheduler {
  /// Применяет оценку [rating] к текущему состоянию [current] и возвращает
  /// обновлённый прогресс (новые интервал, стабильность, сложность, состояние).
  CardProgress review(CardProgress current, Rating rating, {DateTime? now});
}
