import 'package:get/get.dart';

import '../../features/home/home_binding.dart';
import '../../features/home/home_page.dart';
import '../../features/learn/learn_binding.dart';
import '../../features/learn/learn_page.dart';
import '../../features/learn/no_lives_page.dart';
import '../../features/learn/result_page.dart';
import '../../features/learn/review_binding.dart';
import '../../features/learn/review_page.dart';
import '../../features/learn/test_binding.dart';
import '../../features/learn/test_page.dart';
import '../../features/onboarding/onboarding_binding.dart';
import '../../features/onboarding/onboarding_page.dart';
import '../../features/topic_detail/topic_detail_binding.dart';
import '../../features/topic_detail/topic_detail_page.dart';
import '../../features/topics/topics_binding.dart';
import '../../features/topics/topics_page.dart';
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
    GetPage<dynamic>(
      name: Routes.topics,
      page: () => const TopicsPage(),
      binding: TopicsBinding(),
    ),
    GetPage<dynamic>(
      name: Routes.topicDetail,
      page: () => const TopicDetailPage(),
      binding: TopicDetailBinding(),
    ),
    GetPage<dynamic>(
      name: Routes.learn,
      page: () => const LearnPage(),
      binding: LearnBinding(),
    ),
    GetPage<dynamic>(
      name: Routes.test,
      page: () => const TestPage(),
      binding: TestBinding(),
    ),
    GetPage<dynamic>(
      name: Routes.result,
      page: () => const ResultPage(),
    ),
    GetPage<dynamic>(
      name: Routes.noLives,
      page: () => const NoLivesPage(),
    ),
    GetPage<dynamic>(
      name: Routes.review,
      page: () => const ReviewPage(),
      binding: ReviewBinding(),
    ),
  ];
}
