import 'package:get/get.dart';

import '../../features/home/home_binding.dart';
import '../../features/home/home_page.dart';
import '../../features/onboarding/onboarding_binding.dart';
import '../../features/onboarding/onboarding_page.dart';
import 'app_routes.dart';

/// Реестр страниц приложения (маршрут → страница + биндинг).
abstract final class AppPages {
  AppPages._();

  /// Стартовый маршрут.
  static const String initial = Routes.home;

  /// Все страницы приложения.
  static final List<GetPage<dynamic>> routes = <GetPage<dynamic>>[
    GetPage<dynamic>(
      name: Routes.onboarding,
      page: () => const OnboardingPage(),
      binding: OnboardingBinding(),
    ),
    GetPage<dynamic>(
      name: Routes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
  ];
}
