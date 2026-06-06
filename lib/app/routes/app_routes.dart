/// Имена маршрутов приложения.
///
/// Константы вместо строковых литералов — единый источник правды для навигации.
abstract final class Routes {
  Routes._();

  /// Онбординг (первый запуск).
  static const String onboarding = '/onboarding';

  /// Главный экран.
  static const String home = '/home';

  /// Выбор темы (список тем по секциям).
  static const String topics = '/topics';

  /// Тема — обзор (блоки слов/фраз).
  static const String topicDetail = '/topic';

  /// Слова — Учить (свайп-карточки).
  static const String learn = '/learn';

  /// Слова — Тест (выбор перевода).
  static const String test = '/test';

  /// Результат блока.
  static const String result = '/result';

  /// Нет жизней.
  static const String noLives = '/no-lives';

  /// Слова — Повтор (FSRS due).
  static const String review = '/review';
}
