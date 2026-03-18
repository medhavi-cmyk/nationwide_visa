import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/onboarding/presentation/views/onboarding_view.dart';
import '../features/home/presentation/views/home_view.dart';
import '../features/auth/presentation/views/login_view.dart';
import '../features/auth/presentation/views/register_view.dart';
import '../features/auth/presentation/views/account_exists_view.dart';
import '../features/auth/presentation/views/otp_verification_view.dart';
import '../features/auth/presentation/views/profile_setup_view.dart';

class AppRouter {
  static const String onboarding = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String accountExists = '/account-exists';
  static const String otp = '/otp';
  static const String profileSetup = '/profile-setup';
  
  static final GoRouter router = GoRouter(
    initialLocation: onboarding,
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final bool isLoggingIn = state.matchedLocation == onboarding ||
          state.matchedLocation == login ||
          state.matchedLocation == register ||
          state.matchedLocation == accountExists ||
          state.matchedLocation == otp;

      if (user != null) {
        // If already logged in, don't show onboarding/login screens
        if (isLoggingIn) return home;
      } else {
        // If not logged in and trying to access home/profile-setup, force login
        if (state.matchedLocation == home || state.matchedLocation == profileSetup) {
          return onboarding;
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingView(),
      ),
      GoRoute(
        path: home,
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: register,
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return RegisterView(email: email);
        },
      ),
      GoRoute(
        path: accountExists,
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return AccountExistsView(email: email);
        },
      ),
      GoRoute(
        path: otp,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return OtpVerificationView(
            email: data['email'] ?? '',
            password: data['password'] ?? '',
            name: data['name'] ?? '',
            phoneNumber: data['phoneNumber'] ?? '',
            country: data['country'] ?? '',
          );
        },
      ),
      GoRoute(
        path: profileSetup,
        builder: (context, state) => const ProfileSetupView(),
      ),
    ],
  );
}
