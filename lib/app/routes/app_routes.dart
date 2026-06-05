/// Имена маршрутов приложения.
///
/// Константы вместо строковых литералов — единый источник правды для навигации.
abstract final class Routes {
  Routes._();

  /// Онбординг (первый запуск).
  static const String onboarding = '/onboarding';

  /// Главный экран (список тем).
  static const String home = '/home';
}
