import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class RegistrationProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps = 3;

  const RegistrationProgressBar({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    String stepTitle = "";
    switch (currentStep) {
      case 1:
        stepTitle = "PERSONAL DETAILS";
        break;
      case 2:
        stepTitle = "VERIFICATION";
        break;
      case 3:
        stepTitle = "SUCCESS";
        break;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "STEP $currentStep OF $totalSteps",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryRed,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                stepTitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF526074), // on-secondary-fixed-variant
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Stack(
            children: [
              Container(
                height: 3,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE9FF), // surface-container-high
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: currentStep / totalSteps,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
