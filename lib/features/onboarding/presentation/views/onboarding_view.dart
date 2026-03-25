import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nwdapp/features/auth/presentation/views/login_view.dart';
import 'package:nwdapp/features/auth/presentation/views/profile_setup_view.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/router.dart';
import '../../../../core/widgets/platform/platform_button.dart';
import '../../widgets/onboarding_page_one.dart';
import '../../widgets/onboarding_page_two.dart';
import '../../widgets/onboarding_page_three.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-cache all heavy onboarding images so Page 3 is instant
    precacheImage(const AssetImage("assets/image_sir.JPG"), context);
    precacheImage(const AssetImage("assets/image_2.webp"), context);
    precacheImage(const AssetImage("assets/mahima_ghalaut.jpg"), context);
    precacheImage(const AssetImage("assets/ramandeep.jpg"), context);
    precacheImage(const AssetImage("assets/dsc00113.jpg"), context);
    precacheImage(const AssetImage("assets/dsc00423.jpg"), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryRed,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: const [
              OnboardingPageOne(),
              OnboardingPageTwo(),
              OnboardingPageThree(),
            ],
          ),
          // Progress Dots
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) => _buildDot(index)),
            ),
          ),
          // Get Started / Next Button
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: PlatformButton(
              onPressed: () {
                LoginView.show(context);
                // if (_currentPage < 2) {
                //   _pageController.nextPage(
                //     duration: const Duration(milliseconds: 300),
                //     curve: Curves.easeInOut,
                //   );
                // } else {
                //   LoginView.show(context);
                // }
              },
              backgroundColor: Colors.white,
              child: Text(
                // _currentPage == 2 ? "Get Started" : "Continue",
                "Get Started",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryRed,
                ),
              ),
            ),
          ),
          // Debug Skip Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => LoginView.show(context),
                  child: const Text(
                    "Login (Debug)",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => ProfileSetupView.show(context),
                  child: const Text(
                    "Profile (Debug)",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go(AppRouter.home),
                  child: const Text(
                    "Home (Debug)",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    bool isActive = _currentPage == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
