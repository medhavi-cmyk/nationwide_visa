import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/meetings/presentation/view_models/meetings_view_model.dart';
import 'features/auth/presentation/viewmodels/login_viewmodel.dart';
import 'features/auth/presentation/viewmodels/register_viewmodel.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'features/auth/presentation/viewmodels/profile_viewmodel.dart';
import 'features/profile/presentation/viewmodels/profile_viewmodel.dart';
import 'features/auth/presentation/viewmodels/email_verification_viewmodel.dart';
import 'core/app_colors.dart';
import 'core/router.dart';
import 'core/globals.dart';
import 'core/services/zego_chat_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Critical Initialization (Wait for these)
  await _initializeCriticalServices();
  
  // 2. Background Initialization (Don't wait for these to show UI)
  unawaited(_initializeBackgroundServices());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MeetingsViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => MainProfileViewModel()),
        ChangeNotifierProvider(create: (_) => EmailVerificationViewModel()),
      ],
      child: const MyApp(),
    ),
  );

  // Now that the app UI is built, allow the first frame to render
  WidgetsBinding.instance.allowFirstFrame();
}

/// Services that MUST be ready before the app can even start
Future<void> _initializeCriticalServices() async {
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyBQpZ_bZ_oHefJ_6c-Hl97h0D9R_BZH-Js",
          authDomain: "nationwidevisas-4de21.firebaseapp.com",
          projectId: "nationwidevisas-4de21",
          storageBucket: "nationwidevisas-4de21.firebasestorage.app",
          messagingSenderId: "765770707868",
          appId: "1:765770707868:web:ba17394d071f0d16200e59",
          measurementId: "G-HJQXJ1XPGY",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  // Pre-initialize SharedPreferences for instant routing
  try {
    await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint("SharedPreferences initialization failed: $e");
  }
}

/// Services that can finish in the background after the UI is ready
Future<void> _initializeBackgroundServices() async {
  try {
    // 1. Initialize Zego Chat
    final zegoService = ZegoChatService();
    await zegoService.init();

    // Mock login for MVP - Non-blocking
    final String userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    await zegoService.login(userId, 'Demo User');
  } catch (e) {
    debugPrint("Background Zego initialization error: $e");
  }

  // 2. Pre-load JSON data for RegisterViewModel
  try {
    await RegisterViewModel.preLoadData();
  } catch (e) {
    debugPrint("Background JSON pre-load error: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NationWide Visas',
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
        primaryColor: AppColors.primaryRed,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryRed,
          primary: AppColors.primaryRed,
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.primaryRed,
          selectionColor: AppColors.primaryRed.withValues(alpha: 0.3),
          selectionHandleColor: AppColors.primaryRed,
        ),
      ),
      routerConfig: AppRouter.router,
    );
  }
}
