import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nwdapp/core/router.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/platform/platform_button.dart';
import '../../../../core/widgets/platform/platform_indicator.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/registration_progress_bar.dart';
import 'profile_setup_view.dart';

class OtpVerificationView extends StatefulWidget {
  final String email;
  final String password;
  final String name;
  final String phoneNumber;
  final String country;
  final String city;
  final String nationality;
  final String studyCountry;

  const OtpVerificationView({
    super.key,
    required this.email,
    required this.password,
    required this.name,
    required this.phoneNumber,
    required this.country,
    required this.city,
    required this.nationality,
    required this.studyCountry,
  });

  static void show({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String country,
    required String city,
    required String nationality,
    required String studyCountry,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => AuthViewModel(),
        child: OtpVerificationView(
          email: email,
          password: password,
          name: name,
          phoneNumber: phoneNumber,
          country: country,
          city: city,
          nationality: nationality,
          studyCountry: studyCountry,
        ),
      ),
    );
  }

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().sendOtp(widget.phoneNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    // Adjusted for 6 boxes
    final double otpBoxSize = (screenWidth - (24 * 2) - (8 * 5)) / 6;
    final double actualBoxSize = otpBoxSize > 56 ? 56 : otpBoxSize;
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Material(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
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
              const RegistrationProgressBar(currentStep: 2),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: isKeyboardVisible
                      ? const AlwaysScrollableScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        "Verify your phone",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "We've sent a 6-digit code to your number.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      if (viewModel.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            viewModel.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          "assets/otp_image.png",
                          height: isKeyboardVisible
                              ? screenHeight * 0.08
                              : screenHeight * 0.12,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.security,
                                size: 60,
                                color: Colors.grey,
                              ),
                        ),
                      ),
                      if (!isKeyboardVisible) const SizedBox(height: 16),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4B5563),
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            const TextSpan(text: "SMS sent to "),
                            TextSpan(
                              text: widget.phoneNumber,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            const TextSpan(text: ". "),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: GestureDetector(
                                onTap: () => GoRouter.of(context).go(AppRouter.register),
                                child: const Text(
                                  "Change number",
                                  style: TextStyle(
                                    color: AppColors.primaryRed,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // OTP Input row (6 digits)
                      AutofillGroup(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (index) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: AspectRatio(
                                  aspectRatio: 0.8,
                                  child: TextFormField(
                                    controller: viewModel.controllers[index],
                                    focusNode: viewModel.focusNodes[index],
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    autofillHints: const [
                                      AutofillHints.oneTimeCode,
                                    ],
                                    onChanged: (val) =>
                                        viewModel.onCodeChanged(val, index),
                                    style: TextStyle(
                                      fontSize: actualBoxSize > 40 ? 20 : 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      counterText: "",
                                      contentPadding: EdgeInsets.zero,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[200]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: AppColors.primaryRed,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            viewModel.canResend
                                ? "Didn't receive a code? "
                                : "Resend code in ",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                          GestureDetector(
                            onTap: viewModel.canResend
                                ? () => viewModel.resendCode(widget.phoneNumber)
                                : null,
                            child: Text(
                              viewModel.canResend
                                  ? "Resend Code"
                                  : "00:${viewModel.secondsRemaining.toString().padLeft(2, '0')}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: viewModel.canResend
                                    ? AppColors.primaryRed
                                    : AppColors.textGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Verify Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: PlatformButton(
                          onPressed: viewModel.isLoading
                              ? null
                              : () async {
                                  bool success = await viewModel
                                      .verifyAndRegister(
                                        email: widget.email,
                                        password: widget.password,
                                        name: widget.name,
                                        phoneNumber: widget.phoneNumber,
                                        country: widget.country,
                                        city: widget.city,
                                        nationality: widget.nationality,
                                        studyCountry: widget.studyCountry,
                                      );

                                  if (success && context.mounted) {
                                    if (Navigator.of(context).canPop()) {
                                      Navigator.pop(context);
                                    }
                                    // Manually show the Profile Setup modal since it's no longer a route redirect
                                    ProfileSetupView.show(context);
                                  } else if (!success &&
                                      context.mounted &&
                                      viewModel.errorMessage != null) {
                                    CustomSnackbar.showError(
                                      viewModel.errorMessage!,
                                    );
                                  }
                                },
                          child: viewModel.isLoading
                              ? const PlatformIndicator(
                                  color: Colors.white,
                                  radius: 10,
                                )
                              : const Text(
                                  "Verify & Register",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
    );
  }
}
