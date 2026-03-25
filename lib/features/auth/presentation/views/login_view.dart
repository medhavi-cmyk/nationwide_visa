import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nwdapp/core/router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/platform/platform_button.dart';
import '../../../../core/widgets/platform/platform_text_field.dart';
import '../../../../core/widgets/platform/platform_indicator.dart';
import '../viewmodels/login_viewmodel.dart';
import 'register_view.dart';
import 'account_exists_view.dart';
import '../../data/auth_service.dart';
import '../../../../core/utils/platform_utils.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ChangeNotifierProvider(
          create: (_) => LoginViewModel(),
          child: const LoginView(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
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
                width: 25,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[500],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 24.0,
                      right: 24.0,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 10.0,
                    ),
                    child: AutofillGroup(
                      child: Form(
                        key: viewModel.formKey,
                        child: Column(
                          children: [
                            // Illustration / Logo Area
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Image.asset(
                                "assets/login_hero.jpg",
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                            const Text(
                              "Your one-stop platform for all things study abroad",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontFamily: 'Montserrat',
                                letterSpacing: 1,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textBlack,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Email Field
                            PlatformTextField(
                              controller: viewModel.emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: viewModel.validateEmail,
                              labelText: "Email address",
                            ),
                            if (viewModel.showSuggestions) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 32,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children:
                                      [
                                            "@gmail.com",
                                            "@yahoo.com",
                                            "@outlook.com",
                                          ]
                                          .map(
                                            (domain) => Padding(
                                              padding: const EdgeInsets.only(
                                                right: 8,
                                              ),
                                              child: ActionChip(
                                                label: Text(
                                                  domain,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.primaryRed,
                                                  ),
                                                ),
                                                backgroundColor: AppColors
                                                    .primaryRed
                                                    .withValues(alpha: 0.05),
                                                side: BorderSide(
                                                  color: AppColors.primaryRed
                                                      .withValues(alpha: 0.1),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                onPressed: () {
                                                  viewModel.updateEmail(
                                                    "${viewModel.emailController.text}$domain",
                                                  );
                                                },
                                              ),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            // Terms and Conditions
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                                children: [
                                  const TextSpan(
                                    text: "By proceeding, you agree to the ",
                                  ),
                                  TextSpan(
                                    text: "Terms & Conditions",
                                    style: const TextStyle(
                                      color: AppColors.primaryRed,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => _launchURL(
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
                                        "https://www.nationwidevisas.com/privacy-policy/",
                                      ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Continue Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: PlatformButton(
                                onPressed: viewModel.isLoading
                                    ? null
                                    : () {
                                        final parentContext = Navigator.of(
                                          context,
                                        ).context;
                                        viewModel.checkEmailAndRedirect(
                                          onAccountExists: (email) {
                                            Navigator.pop(context);
                                            AccountExistsView.show(
                                              parentContext,
                                              email,
                                            );
                                          },
                                          onNewUser: (email) {
                                            Navigator.pop(context);
                                            RegisterView.show(
                                              parentContext,
                                              email: email,
                                            );
                                          },
                                        );
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
                            const SizedBox(height: 24),
                            const Row(
                              children: [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    "or",
                                    style: TextStyle(
                                      color: AppColors.textGrey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Social Logins
                            _buildSocialButton(
                              "Continue with Google",
                              iconWidget: Image.asset(
                                "assets/google_logo.png",
                                height: 20,
                              ),
                              onPressed: viewModel.isLoading
                                  ? null
                                  : () async {
                                      bool success = await viewModel
                                          .signInWithGoogle();
                                      if (success && context.mounted) {
                                        Navigator.pop(context);
                                        context.go(AppRouter.home);
                                      } else if (!success && context.mounted) {
                                        if (viewModel.errorMessage != null) {
                                          CustomSnackbar.showError(
                                            viewModel.errorMessage!,
                                          );
                                        } else {
                                          // User is authenticated but incomplete
                                          final user =
                                              AuthService().currentUser;
                                          if (user != null) {
                                            final parentContext = Navigator.of(
                                              context,
                                            ).context;
                                            Navigator.pop(
                                              context,
                                            ); // Close Login Sheet

                                            RegisterView.show(
                                              parentContext,
                                              email: user.email ?? "",
                                              isGoogleOnboarding: true,
                                              initialName: user.displayName,
                                            );
                                          }
                                        }
                                      }
                                    },
                            ),
                            const SizedBox(height: 12),
                            // /this is for ios only
                            if (PlatformUtils.isIOS)
                              _buildSocialButton(
                                "Continue with Apple",
                                icon: Icons.apple,
                                onPressed: () {
                                  // Apple Sign In placeholder
                                },
                              ),
                            const SizedBox(height: 40),
                            // Stats Row
                            const IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _StatItem(
                                    val: "4.7/5 ⭐",
                                    label: "Google \n rating",
                                  ),
                                  SizedBox(width: 8),
                                  _StatItem(
                                    val: "100K+",
                                    label: "Students counselled",
                                  ),
                                  SizedBox(width: 8),
                                  _StatItem(
                                    val: "75K+",
                                    label: "Courses available",
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
      debugPrint('Could not launch $urlString');
    }
  }

  Widget _buildSocialButton(
    String text, {
    IconData? icon,
    Widget? iconWidget,
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black87),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconWidget != null)
              iconWidget
            else
              Icon(icon, size: 20, color: Colors.black87),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String val;
  final String label;

  const _StatItem({required this.val, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              val,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryRed,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textGrey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
