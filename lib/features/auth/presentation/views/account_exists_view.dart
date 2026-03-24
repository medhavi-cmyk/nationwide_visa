import 'package:flutter/material.dart';
import 'package:nwdapp/features/auth/presentation/views/forgot_password_view.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/platform/platform_button.dart';
import '../../../../core/widgets/platform/platform_text_field.dart';
import '../../../../core/widgets/platform/platform_indicator.dart';
import '../viewmodels/login_viewmodel.dart';
import 'login_view.dart';
import 'register_view.dart';
import '../../data/auth_service.dart';
import 'dart:io' show Platform;

class AccountExistsView extends StatelessWidget {
  final String email;

  const AccountExistsView({super.key, required this.email});

  static void show(BuildContext context, String email) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ChangeNotifierProvider(
          create: (_) => LoginViewModel()..emailController.text = email,
          child: AccountExistsView(email: email),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    final double vScale = screenHeight / 844.0;
    final double hScale = screenWidth / 390.0;

    return Container(
      height: screenHeight * 0.75,
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
          if (viewModel.isLoading)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Platform.isIOS
                  ? const PlatformIndicator()
                  : const LinearProgressIndicator(color: AppColors.primaryRed),
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24 * hScale.clamp(0.8, 1.2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    "Your account exists",
                    style: TextStyle(
                      fontSize:
                          (screenWidth < 350 ? 22 : 28) *
                          vScale.clamp(0.8, 1.0),
                      fontWeight: FontWeight.w800,
                      color: AppColors.textBlack,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Please enter your password or use Google to log in.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize:
                            (screenWidth < 350 ? 14 : 15) *
                            vScale.clamp(0.9, 1.0),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGrey,
                        height: 1.3,
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 20 * vScale.clamp(0.8, 1.1),
                        color: AppColors.textBlack,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          email,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize:
                                (screenWidth < 350 ? 14 : 16) *
                                vScale.clamp(0.9, 1.0),
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBlack,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (viewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Password Field
                  PlatformTextField(
                    controller: viewModel.passwordController,
                    obscureText: viewModel.obscurePassword,
                    validator: viewModel.validatePassword,
                    labelText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        viewModel.obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textGrey,
                      ),
                      onPressed: () => viewModel.togglePasswordVisibility(),
                    ),
                  ),

                  // Forgot Password Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : () {
                              ForgotPasswordView.show(context);
                            },
                      child: Text(
                        "Forgot password?",
                        style: TextStyle(
                          color: AppColors.primaryRed,
                          fontSize: 14 * vScale.clamp(0.9, 1.0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: PlatformButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : () async {
                              bool success = await viewModel.signInWithEmail(
                                viewModel.passwordController.text.trim(),
                              );
                              if (success && context.mounted) {
                                Navigator.pop(context);
                                context.go(AppRouter.home);
                              } else if (!success && context.mounted) {
                                if (viewModel.errorMessage != null) {
                                  CustomSnackbar.showError(
                                    viewModel.errorMessage ?? "Sign in failed",
                                  );
                                } else {
                                  // User is authenticated but incomplete
                                  final user = AuthService().currentUser;
                                  if (user != null) {
                                    final parentContext = Navigator.of(
                                      context,
                                    ).context;
                                    Navigator.pop(context);

                                    RegisterView.show(
                                      parentContext,
                                      email: user.email ?? "",
                                      isGoogleOnboarding:
                                          true, // Hide password field
                                      initialName: user.displayName,
                                    );
                                  }
                                }
                              }
                            },
                      child: viewModel.isLoading
                          ? const PlatformIndicator(
                              color: Colors.white,
                              radius: 10,
                            )
                          : const Text(
                              "Log In",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),

                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "or",
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(child: Divider()),
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
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                                bool success = await viewModel
                                    .signInWithGoogle();
                                if (success && context.mounted) {
                                  Navigator.pop(context);
                                  context.go(AppRouter.home);
                                } else if (!success && context.mounted) {
                                  if (viewModel.errorMessage != null) {
                                    CustomSnackbar.showError(
                                      viewModel.errorMessage!,
                                    );
                                  } else {
                                    // User is authenticated but incomplete
                                    final user = AuthService().currentUser;
                                    if (user != null) {
                                      final parentContext = Navigator.of(
                                        context,
                                      ).context;
                                      Navigator.pop(context);

                                      RegisterView.show(
                                        parentContext,
                                        email: user.email ?? "",
                                        isGoogleOnboarding: true,
                                        initialName: user.displayName,
                                      );
                                    }
                                  }
                                }
                              },
                      ),
                      const SizedBox(height: 10),
                      _buildSocialButton(
                        context,
                        "Continue with Apple",
                        icon: Icons.apple,
                        onPressed: () {
                          // Apple sign in placeholder
                        },
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

  Widget _buildSocialButton(
    BuildContext context,
    String text, {
    IconData? icon,
    Widget? iconWidget,
    VoidCallback? onPressed,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double vScale = (screenHeight / 844.0).clamp(0.8, 1.0);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: double.infinity,
        height: 54 * vScale,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.textBlack.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconWidget != null)
              iconWidget
            else
              Icon(icon, size: 24 * vScale, color: Colors.black),
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
      ),
    );
  }
}
