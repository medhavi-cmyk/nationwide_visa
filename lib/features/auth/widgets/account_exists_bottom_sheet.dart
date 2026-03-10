import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class AccountExistsBottomSheet extends StatelessWidget {
  final String email;

  const AccountExistsBottomSheet({
    super.key,
    required this.email,
  });

  static void show(BuildContext context, String email) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AccountExistsBottomSheet(email: email);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      height: screenHeight * 0.6,
      width: screenWidth > 600 ? 500 : double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    "Your account exists",
                    style: TextStyle(
                      fontSize: screenWidth < 350 ? 24 : 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textBlack,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Please choose Continue with Google to log in and proceed.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth < 350 ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBlack,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Circular Profile Placeholder
                  Container(
                    width: screenHeight < 700 ? 100 : 120,
                    height: screenHeight < 700 ? 100 : 120,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: screenHeight < 700 ? 60 : 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Email Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.email_outlined, size: 20, color: AppColors.textBlack),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          email,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: screenWidth < 350 ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Social Buttons
                  _buildSocialButton(
                    context,
                    "Continue with Google",
                    iconWidget: Image.asset(
                      "assets/google_logo.png",
                      height: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSocialButton(
                    context,
                    "Continue with Apple",
                    icon: Icons.apple,
                  ),
                  const SizedBox(height: 32),
                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Not you? ",
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Use another account",
                          style: TextStyle(
                            color: AppColors.textBlack,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(BuildContext context, String text, {IconData? icon, Widget? iconWidget}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textBlack.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconWidget != null) iconWidget else Icon(icon, size: 24, color: Colors.black),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: screenWidth < 350 ? 16 : 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textBlack,
            ),
          ),
        ],
      ),
    );
  }
}
