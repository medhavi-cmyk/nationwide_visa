import 'package:go_router/go_router.dart';
import '../features/onboarding/presentation/views/onboarding_view.dart';

class AppRouter {
  static const String onboarding = '/';
  
  static final GoRouter router = GoRouter(
    initialLocation: onboarding,
    routes: [
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingView(),
      ),
    ],
  );
}
