import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/globals.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../data/auth_service.dart';

class EmailVerificationViewModel extends ChangeNotifier {
  Timer? _timer;
  bool _isChecking = false;
  bool _isResending = false;

  bool get isChecking => _isChecking;
  bool get isResending => _isResending;
  String get email => _auth.currentUser?.email ?? '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();

  EmailVerificationViewModel() {
    startVerificationPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startVerificationPolling() {
    // Poll every 3 seconds to check if the user clicked the link
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final user = _auth.currentUser;
      if (user == null) return;

      await user.reload();
      if (user.emailVerified) {
        timer.cancel();
        // Update Firestore flag
        await _authService.updateEmailVerificationStatus(user.uid, true);
        routerNotifier.notify();
      }
    });
  }

  Future<void> sendVerificationEmail() async {
    _isResending = true;
    notifyListeners();
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        CustomSnackbar.showSuccess("Verification email sent!");
      }
    } catch (e) {
      CustomSnackbar.showError("Failed to resend email: $e");
    } finally {
      _isResending = false;
      notifyListeners();
    }
  }

  Future<void> manualCheckVerification(BuildContext context) async {
    _isChecking = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        if (user.emailVerified) {
          _timer?.cancel();
          // Update Firestore flag
          await _authService.updateEmailVerificationStatus(user.uid, true);
          
          if (context.mounted) {
            CustomSnackbar.showSuccess("Email verified successfully!");
            routerNotifier.notify();
          }
        } else {
          CustomSnackbar.showError(
            "Email not verified yet. Please check your inbox.",
          );
        }
      }
    } catch (e) {
      CustomSnackbar.showError("Error checking verification status: $e");
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  void cancelSetup(BuildContext context) async {
    _timer?.cancel();
    await _auth.signOut();
    // The AppRouter will handle the return to 'onboarding' automatically after sign out
  }
}
