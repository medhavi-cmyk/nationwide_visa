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
    final double screenHeight = MediaQuery.of(context).size.height;

    return DraggableScrollableSheet(
      initialChildSize: screenHeight < 600 ? 0.95 : 0.92,
      minChildSize: 0.5,
      maxChildSize: screenHeight < 600 ? 0.95 : 0.92,
      expand: false,
      builder: (context, scrollController) {
        final viewModel = context.watch<RegisterViewModel>();

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            _showExitConfirmation(context);
          },
          child: Material(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
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
                            const SizedBox(height: 24),
                            const Text(
                              "Create your account",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF05345C), // on-surface
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Please fill in your details to start your journey with us.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF3D618C), // on-surface-variant
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 32),

                            _buildLabeledField(
                              label: "FULL NAME",
                              hint: "e.g. John Doe",
                              subHint: "As per your passport or ID proof",
                              controller: viewModel.nameController,
                              validator: viewModel.validateFullName,
                              autofillHints: [AutofillHints.name],
                            ),
                            const SizedBox(height: 20),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildLabeledField(
                                    label: "COUNTRY",
                                    hint: "Select Country",
                                    controller: viewModel.countryController,
                                    validator: viewModel.validateCountry,
                                    readOnly: true,
                                    suffixIcon: const Icon(
                                      Icons.expand_more,
                                      color: Color(0x993D618C),
                                    ),
                                    onTap: () =>
                                        _showCountryPicker(context, viewModel),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildLabeledField(
                                    label: "CITY",
                                    hint: "e.g. London",
                                    controller: viewModel.cityController,
                                    validator: viewModel.validateCity,
                                    readOnly: true,
                                    enabled: viewModel.isCountrySelected,
                                    onTap: viewModel.isCountrySelected
                                        ? () =>
                                            _showCityPicker(context, viewModel)
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            _buildLabeledField(
                              label: "NATIONALITY",
                              hint: "Search nationality",
                              controller: viewModel.nationalityController,
                              validator: viewModel.validateNationality,
                              readOnly: true,
                              suffixIcon: const Icon(
                                Icons.public,
                                color: Color(0x993D618C),
                                size: 20,
                              ),
                              onTap: () =>
                                  _showNationalityPicker(context, viewModel),
                            ),
                            const SizedBox(height: 20),

                            // Phone Number Section
                            const Text(
                              "PHONE NUMBER",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF3D618C),
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 100,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0x1A5A7DA9),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "+91",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF05345C),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: PlatformTextField(
                                    controller: viewModel.phoneController,
                                    keyboardType: TextInputType.number,
                                    validator: viewModel.validatePhone,
                                    hintText: "07700 900000",
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            _buildLabeledField(
                              label: "DESTINATION",
                              hint: "Where are you heading?",
                              controller: viewModel.studyCountryController,
                              validator: viewModel.validateStudyCountry,
                              readOnly: true,
                              suffixIcon: const Icon(
                                Icons.near_me,
                                color: Color(0x993D618C),
                                size: 20,
                              ),
                              onTap: () =>
                                  _showStudyCountryPicker(context, viewModel),
                            ),

                            if (!viewModel.isGoogleOnboarding) ...[
                              const SizedBox(height: 20),
                              _buildLabeledField(
                                label: "PASSWORD",
                                hint: "Min. 8 characters",
                                controller: viewModel.passwordController,
                                obscureText: viewModel.obscurePassword,
                                validator: viewModel.validatePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    viewModel.obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: const Color(0x993D618C),
                                    size: 20,
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
                                  height: 22,
                                  width: 22,
                                  child: Checkbox(
                                    value: viewModel.agreedToTerms,
                                    onChanged: (val) =>
                                        viewModel.toggleAgreedToTerms(val),
                                    activeColor: AppColors.primaryRed,
                                    side: BorderSide(
                                      color: Colors.grey[300]!,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF3D618C),
                                        height: 1.4,
                                      ),
                                      children: [
                                        const TextSpan(text: "I agree to the "),
                                        TextSpan(
                                          text: "Terms of Service",
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
                                          text: "Privacy Policy",
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
                                        const TextSpan(
                                          text: ", including cookie use.",
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            Container(
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFBF0C0F),
                                    Color(0xFFFD4135),
                                  ],
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
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Continue",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(
                                            Icons.chevron_right,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF3D618C),
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: "Already have an account? ",
                                    ),
                                    TextSpan(
                                      text: "Sign In",
                                      style: const TextStyle(
                                        color: AppColors.primaryRed,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.pop(context);
                                        },
                                    ),
                                  ],
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

  Widget _buildLabeledField({
    required String label,
    required String hint,
    String? subHint,
    TextEditingController? controller,
    String? Function(String?)? validator,
    bool readOnly = false,
    bool enabled = true,
    bool obscureText = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    Iterable<String>? autofillHints,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF3D618C), // on-surface-variant
              letterSpacing: 1.0,
            ),
          ),
        ),
        PlatformTextField(
          controller: controller,
          hintText: hint,
          enabled: enabled,
          validator: validator,
          readOnly: readOnly,
          obscureText: obscureText,
          onTap: onTap,
          suffixIcon: suffixIcon,
        ),
        if (subHint != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              subHint,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
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
