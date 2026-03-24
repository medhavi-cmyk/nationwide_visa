import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../viewmodels/email_verification_viewmodel.dart';
import '../../../../core/widgets/platform/platform_scaffold.dart';
import '../../../../core/widgets/platform/platform_button.dart';
import '../../../../core/widgets/platform/platform_indicator.dart';

class EmailVerificationView extends StatelessWidget {
  const EmailVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EmailVerificationViewModel(),
      child: const _EmailVerificationContent(),
    );
  }
}

class _EmailVerificationContent extends StatelessWidget {
  const _EmailVerificationContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EmailVerificationViewModel>();
    final double screenHeight = MediaQuery.of(context).size.height;

    return PlatformScaffold(
      backgroundColor: Colors.white,
      title: "Verify Email",
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => viewModel.cancelSetup(context),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.05),
              // Icon Container
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.mark_email_unread_outlined,
                    size: 60,
                    color: AppColors.primaryRed,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "Check your email",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: "We've sent a verification link to "),
                    TextSpan(
                      text: viewModel.email,
                      style: const TextStyle(
                        color: AppColors.textBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text: ". Please click the link to verify your account.",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              
              // I have verified button
              PlatformButton(
                onPressed: viewModel.isChecking
                    ? null
                    : () => viewModel.manualCheckVerification(context),
                child: viewModel.isChecking
                    ? const PlatformIndicator(color: Colors.white)
                    : const Text(
                        "I've Verified It",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              
              // Resend Button
              PlatformButton(
                onPressed: viewModel.isResending
                    ? null
                    : () => viewModel.sendVerificationEmail(),
                backgroundColor: Colors.white,
                child: viewModel.isResending
                    ? const PlatformIndicator(color: AppColors.primaryRed)
                    : const Text(
                        "Resend Email",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryRed,
                        ),
                      ),
              ),
              
              const Spacer(),
              TextButton(
                onPressed: () => viewModel.cancelSetup(context),
                child: const Text(
                  "Cancel and return to login",
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
