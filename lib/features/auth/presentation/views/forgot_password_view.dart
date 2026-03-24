import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';
import 'package:nwdapp/core/app_colors.dart';
import 'package:nwdapp/core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/platform/platform_button.dart';
import '../../../../core/widgets/platform/platform_text_field.dart';
import '../../../../core/widgets/platform/platform_indicator.dart';
import 'dart:io' show Platform;

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ChangeNotifierProvider(
            create: (_) => LoginViewModel(),
            child: const ForgotPasswordView(),
          ),
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
      height: screenHeight * 0.35,
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
                    child: PlatformButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Got it!",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
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
                  PlatformTextField(
                    controller: viewModel.emailController,
                    validator: viewModel.validateEmail,
                    labelText: "Email",
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: PlatformButton(
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
                      child: viewModel.isLoading
                          ? const PlatformIndicator(
                              color: Colors.white,
                              radius: 10,
                            )
                          : const Text(
                              "Send Reset Email",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
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
