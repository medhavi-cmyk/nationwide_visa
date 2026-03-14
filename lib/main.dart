import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'features/meetings/presentation/view_models/meetings_view_model.dart';
import 'core/app_colors.dart';
import 'core/router.dart';
import 'core/services/zego_chat_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Zego Chat
  final zegoService = ZegoChatService();
  await zegoService.init();

  // Mock login for MVP
  // In a real app, this would happen after authentication
  final String userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
  await zegoService.login(userId, 'Demo User');

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MeetingsViewModel())],
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
