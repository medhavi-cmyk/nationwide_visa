import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class OtpVerificationSheet extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationSheet({super.key, required this.phoneNumber});

  static void show(BuildContext context, String phoneNumber) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => OtpVerificationSheet(phoneNumber: phoneNumber),
    );
  }

  @override
  State<OtpVerificationSheet> createState() => _OtpVerificationSheetState();
}

class _OtpVerificationSheetState extends State<OtpVerificationSheet> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    // Calculate responsive OTP box width (max 64, scales down on tiny screens)
    final double otpBoxSize = (screenWidth - (24 * 2) - (12 * 3)) / 4;
    final double actualBoxSize = otpBoxSize > 64 ? 64 : otpBoxSize;
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95, // Allow expansion when keyboard is up
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
                  controller: scrollController,
                  // Disable scrolling when keyboard is down to meet user requirement
                  physics: isKeyboardVisible
                      ? const AlwaysScrollableScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        "Let's verify your account",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "We want you to have a secure experience.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Illustration - Further scaled down to ensure everything fits
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          "assets/otp_image.png",
                          height: isKeyboardVisible 
                            ? screenHeight * 0.10 
                            : screenHeight * 0.13,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.security,
                                size: 60,
                                color: Colors.grey,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4B5563),
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            const TextSpan(
                              text: "Enter the 4-digit code sent via SMS to\n",
                            ),
                            TextSpan(
                              text: widget.phoneNumber,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const TextSpan(text: " "),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
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
                      const SizedBox(height: 20),
                      // OTP Input row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) {
                          return SizedBox(
                            width: actualBoxSize,
                            height: actualBoxSize,
                            child: TextFormField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              onChanged: (val) => _onChanged(val, index),
                              style: TextStyle(
                                fontSize: actualBoxSize > 50 ? 22 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                counterText: "",
                                contentPadding: EdgeInsets.zero,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.grey[200]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryRed,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Didn't receive a code? ",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Resend logic
                            },
                            child: const Text(
                              "Resend Code",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Verify Button
                      Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryRed.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            // Pop the OTP sheet
                            Navigator.pop(context);
                            // Pop the Register sheet (assuming it's still below)
                            // Using a slight delay or popUntil is safer for nested modals
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Verify",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
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
        );
      },
    );
  }
}
