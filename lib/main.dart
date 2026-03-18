import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/meetings/presentation/view_models/meetings_view_model.dart';
import 'features/auth/presentation/viewmodels/login_viewmodel.dart';
import 'features/auth/presentation/viewmodels/register_viewmodel.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'features/auth/presentation/viewmodels/profile_viewmodel.dart';
import 'features/profile/presentation/viewmodels/profile_viewmodel.dart';
import 'core/app_colors.dart';
import 'core/router.dart';
import 'core/globals.dart';
import 'core/services/zego_chat_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
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
    // Handle initialization error (e.g., missing configuration files)
  }

  // Initialize Zego Chat
  final zegoService = ZegoChatService();
  await zegoService.init();

  // Mock login for MVP
  // In a real app, this would happen after authentication
  final String userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
  await zegoService.login(userId, 'Demo User');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MeetingsViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => MainProfileViewModel()),
      ],
      child: const MyApp(),
    ),
  );
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
