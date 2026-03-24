import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/widgets/platform/platform_button.dart';
import '../../../../core/widgets/platform/platform_indicator.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../widgets/registration_progress_bar.dart';
import 'registration_success_view.dart';

class ProfileSetupView extends StatelessWidget {
  const ProfileSetupView({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => ProfileViewModel(),
        child: const ProfileSetupView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();
    final double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: viewModel.isAnyExpanded ? screenHeight * 0.9 : screenHeight * 0.7,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          // Fixed Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const RegistrationProgressBar(currentStep: 3),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              physics: viewModel.isAnyExpanded
                  ? const AlwaysScrollableScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Let's guide you like we did\nour 85K+ students.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Can you quickly fill these out?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Scaled Illustration
                  Container(
                    height: viewModel.isAnyExpanded ? 260 : 200,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/profile_setup_illustration.png',
                        ),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Study Level Input
                  _buildSelectionField(
                    icon: Icons.school_outlined,
                    label: "Study level",
                    value: viewModel.selectedStudyLevel,
                    isExpanded: viewModel.isStudyLevelExpanded,
                    onTap: () => viewModel.toggleStudyLevelExpansion(),
                    expandedContent: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: viewModel.studyLevels
                              .map(
                                (level) => _buildChip(
                                  label: level,
                                  isSelected: viewModel.selectedStudyLevel == level,
                                  onSelected: (_) => viewModel.setStudyLevel(level),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Start Date Input
                  _buildSelectionField(
                    icon: Icons.calendar_today_outlined,
                    label: "Start date",
                    value: viewModel.selectedStartYear,
                    isExpanded: viewModel.isStartDateExpanded,
                    onTap: () => viewModel.toggleStartDateExpansion(),
                    expandedContent: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          "When do you plan to start your studies?",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: viewModel.years
                              .map(
                                (year) => _buildChip(
                                  label: year,
                                  isSelected: viewModel.selectedStartYear == year,
                                  onSelected: (_) => viewModel.setStartYear(year),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "In which month do you wish to join?",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: viewModel.months
                              .map(
                                (range) => _buildChip(
                                  label: range,
                                  isSelected: viewModel.selectedMonthRange == range,
                                  onSelected: (_) => viewModel.setMonthRange(range),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Sign Up Button - Fixed at bottom
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: PlatformButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        debugPrint("PROFILE_VIEW: 'Sign up' button tapped");
                        final success = await viewModel.saveProfile();
                        if (success && context.mounted) {
                          final parentContext = Navigator.of(context).context;
                          Navigator.pop(context); // Close Profile Setup
                          
                          Future.delayed(const Duration(milliseconds: 100), () {
                            if (parentContext.mounted) {
                              RegistrationSuccessView.show(parentContext);
                            }
                          });
                        }
                      },
                child: viewModel.isLoading
                    ? const PlatformIndicator(
                        color: Colors.white,
                        radius: 10,
                      )
                    : const Text(
                        "Sign up",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF4B5563),
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppColors.primaryRed,
      backgroundColor: Colors.grey[100],
      checkmarkColor: Colors.white,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primaryRed : Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildSelectionField({
    required IconData icon,
    required String label,
    required String? value,
    required VoidCallback onTap,
    bool isExpanded = false,
    Widget? expandedContent,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isExpanded
                ? AppColors.primaryRed.withValues(alpha: 0.3)
                : Colors.grey[200]!,
            width: isExpanded ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isExpanded
                      ? AppColors.primaryRed
                      : const Color(0xFF4B5563),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                if (value != null && !isExpanded)
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryRed,
                    ),
                  ),
                if (isExpanded)
                  const Icon(Icons.expand_less, color: AppColors.primaryRed)
                else
                  const Icon(Icons.expand_more, color: Color(0xFF4B5563)),
              ],
            ),
            if (isExpanded && expandedContent != null) expandedContent,
          ],
        ),
      ),
    );
  }
}
