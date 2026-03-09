import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/onboarding/screens/onboarding_flow_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Course Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const OnboardingFlowScreen(),
    );
  }
}
