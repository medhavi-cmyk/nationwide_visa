import 'package:go_router/go_router.dart';
import '../features/onboarding/presentation/views/onboarding_view.dart';
import '../features/home/presentation/views/home_view.dart';

class AppRouter {
  static const String onboarding = '/';
  static const String home = '/home';
  
  static final GoRouter router = GoRouter(
    initialLocation: onboarding,
    routes: [
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingView(),
      ),
      GoRoute(
        path: home,
        builder: (context, state) => const HomeView(),
      ),
    ],
  );
}
