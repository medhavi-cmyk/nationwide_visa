import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';
import 'package:nwdapp/core/app_colors.dart';
import 'package:nwdapp/core/widgets/custom_snackbar.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return ChangeNotifierProvider(
          create: (_) => LoginViewModel(),
          child: const ForgotPasswordView(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final vScale = screenHeight / 800.0;
    final hScale = screenWidth / 390.0;

    return Container(
      height: screenHeight * 0.4,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 24 * hScale,
          vertical: 24 * vScale,
        ),
        child: viewModel.isResetEmailSent
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Check your email",
                    style: TextStyle(
                      fontSize: 22 * vScale.clamp(0.9, 1.0),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "We've sent a password reset link to\n${viewModel.emailController.text}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 14 * vScale.clamp(0.9, 1.0),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Got it!",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Forgot Password",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24 * vScale.clamp(0.9, 1.0),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Enter your email to receive a reset link.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 14 * vScale.clamp(0.9, 1.0),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: viewModel.emailController,
                    validator: viewModel.validateEmail,
                    decoration: InputDecoration(
                      labelText: "Email",
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
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : () async {
                              bool sent = await viewModel
                                  .sendPasswordResetEmail();
                              if (sent && context.mounted) {
                                // No longer popping immediately - UI will show success state
                                CustomSnackbar.showSuccess(
                                  "Password reset email sent",
                                );
                              } else if (!sent && context.mounted) {
                                CustomSnackbar.showError(
                                  viewModel.errorMessage ??
                                      "Failed to send reset email",
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
                              "Send Reset Email",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
