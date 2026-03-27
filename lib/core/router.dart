import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'globals.dart';
import '../features/onboarding/presentation/views/onboarding_view.dart';
import '../features/home/presentation/views/home_view.dart';
import '../features/auth/presentation/views/login_view.dart';
import '../features/auth/presentation/views/register_view.dart';
import '../features/auth/presentation/views/account_exists_view.dart';
import '../features/auth/presentation/views/otp_verification_view.dart';
import '../features/auth/presentation/views/email_verification_view.dart';
import '../features/auth/data/auth_service.dart';

class AppRouter {
  static const String onboarding = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String accountExists = '/account-exists';
  static const String otp = '/otp';
  static const String emailVerification = '/email-verification';

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: onboarding,
    refreshListenable: Listenable.merge([
      GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
      routerNotifier,
    ]),
    redirect: (context, state) async {
      final user = FirebaseAuth.instance.currentUser;
      debugPrint("ROUTER: Redirect check - User: ${user?.email}, Location: ${state.matchedLocation}");

      final bool isLoggingIn =
          state.matchedLocation == onboarding ||
          state.matchedLocation == login ||
          state.matchedLocation == register ||
          state.matchedLocation == accountExists ||
          state.matchedLocation == emailVerification ||
          state.matchedLocation == otp;

      if (user != null) {
        // 1. Check Profile Completeness
        final isComplete = await AuthService().isUserComplete(user.uid);
        debugPrint("ROUTER: User completeness: $isComplete");

        // 2. If NOT complete, stay on Auth/Onboarding pages
        if (!isComplete) {
          if (isLoggingIn) return null; // Already on an auth page, stay there
          return onboarding; // Force back to onboarding if they try to access home
        }

        // 3. User is complete. If on Auth page, go HOME
        if (isLoggingIn) {
          debugPrint("ROUTER: User is finished. Redirecting to home.");
          return home;
        }
      } else {
        if (state.matchedLocation == home) {
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
      GoRoute(path: home, builder: (context, state) => const HomeView()),
      GoRoute(path: login, builder: (context, state) => const LoginView()),
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
            city: data['city'] ?? '',
            nationality: data['nationality'] ?? '',
            studyCountry: data['studyCountry'] ?? '',
          );
        },
      ),
      GoRoute(
        path: emailVerification,
        builder: (context, state) => const EmailVerificationView(),
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
