import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:nwdapp/features/auth/presentation/views/otp_verification_view.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/platform/platform_button.dart';
import '../../../../core/widgets/platform/platform_text_field.dart';
import '../../../../core/widgets/platform/platform_indicator.dart';
import '../viewmodels/register_viewmodel.dart';
import '../widgets/city_picker.dart';
import '../widgets/country_picker.dart';
import '../widgets/destination_picker.dart';
import '../widgets/registration_exit_confirmation.dart';
import '../widgets/registration_progress_bar.dart';

class RegisterView extends StatelessWidget {
  final String email;
  final bool isGoogleOnboarding;
  final String? initialName;

  const RegisterView({
    super.key,
    required this.email,
    this.isGoogleOnboarding = false,
    this.initialName,
  });

  static void show(
    BuildContext context, {
    required String email,
    bool isGoogleOnboarding = false,
    String? initialName,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ChangeNotifierProvider(
          create: (_) => RegisterViewModel()
            ..setGoogleOnboarding(isGoogleOnboarding)
            ..prefillFromGoogle(name: initialName),
          child: RegisterView(
            email: email,
            isGoogleOnboarding: isGoogleOnboarding,
            initialName: initialName,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RegisterViewModel>();
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return DraggableScrollableSheet(
      initialChildSize: screenHeight < 600 ? 0.95 : 0.92,
      minChildSize: 0.5,
      maxChildSize: screenHeight < 600 ? 0.95 : 0.92,
      expand: false,
      builder: (context, scrollController) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            _showExitConfirmation(context);
          },
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onVerticalDragEnd: (details) {
                    if (details.primaryVelocity! > 50) {
                      _showExitConfirmation(context);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                const Center(
                  child: Column(
                    children: [
                      RegistrationProgressBar(currentStep: 1),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.only(
                      left: 24.0,
                      right: 24.0,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 10.0,
                    ),
                    child: AutofillGroup(
                      child: Form(
                        key: viewModel.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              "Choose from best country to work or study abroad",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: screenWidth < 350 ? 24 : 28,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textBlack,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Let's make it happen.",
                              style: TextStyle(
                                fontSize: screenWidth < 350 ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textBlack,
                              ),
                            ),
                            const SizedBox(height: 32),

                            _buildField(
                              context: context,
                              label: "Full name",
                              hint: "As per your passport or ID proof",
                              controller: viewModel.nameController,
                              validator: viewModel.validateFullName,
                              autofillHints: [AutofillHints.name],
                            ),
                            const SizedBox(height: 16),
                            _buildField(
                              context: context,
                              label: "Country you live in",
                              controller: viewModel.countryController,
                              validator: viewModel.validateCountry,
                              readOnly: true,
                              onTap: () =>
                                  _showCountryPicker(context, viewModel),
                            ),
                            const SizedBox(height: 16),
                            _buildField(
                              context: context,
                              label: "City you live in",
                              controller: viewModel.cityController,
                              validator: viewModel.validateCity,
                              readOnly: true,
                              enabled: viewModel.isCountrySelected,
                              onTap: viewModel.isCountrySelected
                                  ? () => _showCityPicker(context, viewModel)
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            _buildField(
                              context: context,
                              label: "Nationality",
                              controller: viewModel.nationalityController,
                              validator: viewModel.validateNationality,
                              readOnly: true,
                              onTap: () =>
                                  _showNationalityPicker(context, viewModel),
                            ),
                            const SizedBox(height: 16),

                            PlatformTextField(
                              controller: viewModel.phoneController,
                              keyboardType: TextInputType.number,
                              validator: viewModel.validatePhone,
                              labelText: "Phone number",
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 12,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(2),
                                      child: Image.network(
                                        "https://flagcdn.com/w40/in.png",
                                        width: 24,
                                        height: 16,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.flag_outlined,
                                                  size: 20,
                                                ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "+91",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),
                            _buildField(
                              context: context,
                              label: "Where do you wish to go?",
                              controller: viewModel.studyCountryController,
                              validator: viewModel.validateStudyCountry,
                              readOnly: true,
                              onTap: () =>
                                  _showStudyCountryPicker(context, viewModel),
                            ),

                            if (!viewModel.isGoogleOnboarding) ...[
                              const SizedBox(height: 16),
                              PlatformTextField(
                                controller: viewModel.passwordController,
                                obscureText: viewModel.obscurePassword,
                                validator: viewModel.validatePassword,
                                labelText: "Set your password",
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    viewModel.obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.grey[400],
                                  ),
                                  onPressed: () =>
                                      viewModel.togglePasswordVisibility(),
                                ),
                              ),
                            ],

                            const SizedBox(height: 24),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: viewModel.agreedToTerms,
                                    onChanged: (val) =>
                                        viewModel.toggleAgreedToTerms(val),
                                    activeColor: AppColors.primaryRed,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textGrey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        const TextSpan(text: "I agree to the "),
                                        TextSpan(
                                          text: "Terms & Conditions",
                                          style: const TextStyle(
                                            color: AppColors.primaryRed,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () => _launchURL(
                                              context,
                                              "https://www.nationwidevisas.com/terms-and-conditions/",
                                            ),
                                        ),
                                        const TextSpan(text: " and "),
                                        TextSpan(
                                          text: "Privacy Policy.",
                                          style: const TextStyle(
                                            color: AppColors.primaryRed,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () => _launchURL(
                                              context,
                                              "https://www.nationwidevisas.com/privacy-policy/",
                                            ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: PlatformButton(
                                onPressed: viewModel.isLoading
                                    ? null
                                    : () {
                                        if (viewModel.validateForm()) {
                                          if (!viewModel.agreedToTerms) {
                                            CustomSnackbar.showError(
                                              "Please agree to the Terms & Conditions",
                                            );
                                            return;
                                          }
                                          final parentContext = Navigator.of(
                                            context,
                                          ).context;
                                          Navigator.pop(
                                            context,
                                          ); // Close Register Sheet

                                          OtpVerificationView.show(
                                            context: parentContext,
                                            email: email,
                                            password:
                                                viewModel.isGoogleOnboarding
                                                ? "" // No password for Google
                                                : viewModel
                                                      .passwordController
                                                      .text
                                                      .trim(),
                                            name: viewModel.nameController.text
                                                .trim(),
                                            phoneNumber: viewModel
                                                .phoneController
                                                .text
                                                .trim(),
                                            country: viewModel
                                                .countryController
                                                .text
                                                .trim(),
                                            city: viewModel.cityController.text
                                                .trim(),
                                            nationality: viewModel
                                                .nationalityController
                                                .text
                                                .trim(),
                                            studyCountry: viewModel
                                                .studyCountryController
                                                .text
                                                .trim(),
                                          );
                                        }
                                      },
                                child: viewModel.isLoading
                                    ? const PlatformIndicator(
                                        color: Colors.white,
                                        radius: 10,
                                      )
                                    : const Text(
                                        "Continue",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
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

  void _showExitConfirmation(BuildContext context) {
    RegistrationExitConfirmationDialog.show(
      context,
      () {},
      () => Navigator.of(context).pop(),
    );
  }

  void _showCountryPicker(
    BuildContext context,
    RegisterViewModel viewModel,
  ) async {
    final countries = await viewModel.getAllCountries();
    if (!context.mounted) return;
    CountryPickerView.show(context, countries, (country) {
      viewModel.updateCountry(country);
    });
  }

  void _showNationalityPicker(
    BuildContext context,
    RegisterViewModel viewModel,
  ) async {
    final countries = await viewModel.getAllCountries();
    if (!context.mounted) return;
    CountryPickerView.show(
      context,
      countries,
      (country) {
        viewModel.updateNationality(country);
      },
      title: "Select Nationality",
      hint: "Nationality",
    );
  }

  void _showStudyCountryPicker(
    BuildContext context,
    RegisterViewModel viewModel,
  ) {
    DestinationPickerView.show(context, (country) {
      viewModel.updateStudyCountry(country);
    });
  }

  void _showCityPicker(
    BuildContext context,
    RegisterViewModel viewModel,
  ) async {
    final cities = await viewModel.getCitiesForSelectedCountry();
    if (!context.mounted) return;
    CityPickerView.show(context, cities, (city) {
      viewModel.updateCity(city);
    });
  }

  Widget _buildField({
    required BuildContext context,
    required String label,
    String? hint,
    TextEditingController? controller,
    String? Function(String?)? validator,
    bool readOnly = false,
    bool enabled = true,
    VoidCallback? onTap,
    Iterable<String>? autofillHints,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlatformTextField(
          controller: controller,
          // labelText: label,
          hintText: label,
          enabled: enabled,
          validator: validator,
          readOnly: readOnly,
          onTap: onTap,
        ),
        if (hint != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              hint,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _launchURL(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
      debugPrint('Could not launch $urlString');
    }
  }
}

class PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(' ', '');
    // No formatting here to keep it simple for now, or just space out.
    // The previous logic was causing issues if not careful.
    if (text.length > 5) {
      text = '${text.substring(0, 5)} ${text.substring(5)}';
    }
    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
