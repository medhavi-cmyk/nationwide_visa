import 'package:flutter/material.dart';
import 'package:nwdapp/features/auth/presentation/views/forgot_password_view.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../viewmodels/login_viewmodel.dart';
import 'login_view.dart';

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
            const LinearProgressIndicator(color: AppColors.primaryRed),
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
                  TextFormField(
                    controller: viewModel.passwordController,
                    obscureText: viewModel.obscurePassword,
                    validator: viewModel.validatePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: const TextStyle(color: AppColors.textGrey),
                      floatingLabelStyle: const TextStyle(
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.bold,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.borderGrey,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.borderGrey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.primaryRed,
                          width: 2,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          viewModel.obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textGrey,
                        ),
                        onPressed: () => viewModel.togglePasswordVisibility(),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
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
                    child: ElevatedButton(
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
                                CustomSnackbar.showError(
                                  viewModel.errorMessage ?? "Sign in failed",
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: viewModel.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
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
                                } else if (!success &&
                                    context.mounted &&
                                    viewModel.errorMessage != null) {
                                  CustomSnackbar.showError(
                                    viewModel.errorMessage!,
                                  );
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
