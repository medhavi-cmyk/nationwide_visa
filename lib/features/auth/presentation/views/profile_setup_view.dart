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

    return DraggableScrollableSheet(
      initialChildSize: viewModel.isAnyExpanded ? 0.92 : 0.75,
      minChildSize: 0.5,
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
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const RegistrationProgressBar(currentStep: 3),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Step 3: Profile Setup",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF05345C),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Let's guide you like we did our 85K+ students. Can you quickly fill these out?",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF3D618C),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Center(
                          child: Image.asset(
                            'assets/profile_setup_illustration.png',
                            height: 200,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.account_circle,
                                  size: 100,
                                  color: Colors.grey,
                                ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildSelectionField(
                          icon: Icons.school_outlined,
                          label: "STUDY LEVEL",
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
                                        isSelected:
                                            viewModel.selectedStudyLevel ==
                                            level,
                                        onSelected: (_) =>
                                            viewModel.setStudyLevel(level),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSelectionField(
                          icon: Icons.calendar_today_outlined,
                          label: "START DATE",
                          value: viewModel.selectedMonthRange,
                          isExpanded: viewModel.isStartDateExpanded,
                          onTap: () => viewModel.toggleStartDateExpansion(),
                          expandedContent: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: viewModel.months
                                    .map(
                                      (range) => _buildChip(
                                        label: range,
                                        isSelected:
                                            viewModel.selectedMonthRange ==
                                            range,
                                        onSelected: (_) =>
                                            viewModel.setMonthRange(range),
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFBF0C0F), Color(0xFFFD4135)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x33BF0C0F),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: PlatformButton(
                      backgroundColor: Colors.transparent,
                      borderRadius: 30,
                      onPressed: viewModel.isLoading
                          ? null
                          : () async {
                              final success = await viewModel.saveProfile();
                              if (success && context.mounted) {
                                if (Navigator.of(context).canPop()) {
                                  Navigator.pop(context);
                                }
                                RegistrationSuccessView.show(context);
                              }
                            },
                      child: viewModel.isLoading
                          ? const PlatformIndicator(
                              color: Colors.white,
                              radius: 10,
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Finish Setup",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.chevron_right, color: Colors.white),
                              ],
                            ),
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
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                if (value != null && !isExpanded)
                  Flexible(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryRed,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                const SizedBox(width: 4),
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
