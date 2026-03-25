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
import '../features/auth/presentation/views/profile_setup_view.dart';
import '../features/auth/presentation/views/email_verification_view.dart';
import '../features/auth/data/auth_service.dart';

class AppRouter {
  static const String onboarding = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String accountExists = '/account-exists';
  static const String otp = '/otp';
  static const String profileSetup = '/profile-setup';
  static const String emailVerification = '/email-verification';

  static final GoRouter router = GoRouter(
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
        // --- NEW: Email Verification Guard ---
        bool requiresVerification =
            user.providerData.any((p) => p.providerId == 'password') &&
            !user.emailVerified;

        if (requiresVerification) {
          // Only redirect them to email verification if they are not already there
          if (state.matchedLocation == emailVerification) return null;
          return emailVerification;
        }

        // If logged in, check if profile is complete
        final isComplete = await AuthService().isUserComplete(user.uid);
        debugPrint("ROUTER: User is ${isComplete ? '' : 'NOT '}complete");

        if (!isComplete) {
          // If profile is incomplete, force them to the profile setup screen
          return (state.matchedLocation == profileSetup) ? null : profileSetup;
        }

        // If logged in and profile is complete, and we are on an auth/onboarding/profile-setup page, go HOME
        final bool isAuthPage = isLoggingIn || 
                               state.matchedLocation == onboarding || 
                               state.matchedLocation == profileSetup;

        if (isAuthPage) {
          debugPrint("ROUTER: User is logged in and complete. Redirecting to home.");
          return home;
        }
      } else {
        // If not logged in and trying to access home/profile-setup, force login
        if (state.matchedLocation == home ||
            state.matchedLocation == profileSetup) {
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
        path: profileSetup,
        builder: (context, state) => const ProfileSetupView(),
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
