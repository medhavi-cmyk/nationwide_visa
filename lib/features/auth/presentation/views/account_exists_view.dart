import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';
import 'login_view.dart';

class AccountExistsView extends StatelessWidget {
  final String email;

  const AccountExistsView({
    super.key,
    required this.email,
  });

  static void show(BuildContext context, String email) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AccountExistsView(email: email);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    
    final double vScale = screenHeight / 844.0;
    final double hScale = screenWidth / 390.0;
    
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
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24 * hScale.clamp(0.8, 1.2)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    "Your account exists",
                    style: TextStyle(
                      fontSize: (screenWidth < 350 ? 22 : 28) * vScale.clamp(0.8, 1.0),
                      fontWeight: FontWeight.w800,
                      color: AppColors.textBlack,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Please choose Continue with Google to log in and proceed.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: (screenWidth < 350 ? 14 : 16) * vScale.clamp(0.9, 1.0),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBlack,
                        height: 1.3,
                      ),
                    ),
                  ),
                  
                  Container(
                    width: (screenHeight < 700 ? 80 : 110) * vScale.clamp(0.7, 1.1),
                    height: (screenHeight < 700 ? 80 : 110) * vScale.clamp(0.7, 1.1),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: (screenHeight < 700 ? 50 : 70) * vScale.clamp(0.7, 1.1),
                      color: Colors.white,
                    ),
                  ),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.email_outlined, size: 20 * vScale.clamp(0.8, 1.1), color: AppColors.textBlack),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          email,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: (screenWidth < 350 ? 14 : 16) * vScale.clamp(0.9, 1.0),
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  Column(
                    children: [
                      _buildSocialButton(
                        context,
                        "Continue with Google",
                        iconWidget: Image.asset(
                          "assets/google_logo.png",
                          height: 22 * vScale.clamp(0.8, 1.1),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildSocialButton(
                        context,
                        "Continue with Apple",
                        icon: Icons.apple,
                      ),
                    ],
                  ),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Not you? ",
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 14 * vScale.clamp(0.9, 1.0),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          LoginView.show(context);
                        },
                        child: Text(
                          "Use another account",
                          style: TextStyle(
                            color: AppColors.textBlack,
                            fontSize: 14 * vScale.clamp(0.9, 1.0),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
    final double screenHeight = MediaQuery.of(context).size.height;
    final double vScale = (screenHeight / 844.0).clamp(0.8, 1.0);
    
    return Container(
      width: double.infinity,
      height: 54 * vScale,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textBlack.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconWidget != null) iconWidget else Icon(icon, size: 24 * vScale, color: Colors.black),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: (screenWidth < 350 ? 16 : 18) * vScale,
              fontWeight: FontWeight.w800,
              color: AppColors.textBlack,
            ),
          ),
        ],
      ),
    );
  }
}
