import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router.dart';
import '../../../../core/widgets/custom_snackbar.dart';

class EmailVerificationViewModel extends ChangeNotifier {
  Timer? _timer;
  bool _isChecking = false;
  bool _isResending = false;

  bool get isChecking => _isChecking;
  bool get isResending => _isResending;

  final FirebaseAuth _auth = FirebaseAuth.instance;

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
        notifyListeners();
        // The router will automatically detect the state change and route them to Profile Setup or Home!
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
          if (context.mounted) {
            CustomSnackbar.showSuccess("Email verified successfully!");
            // Navigate to home (or onboarding will redirect based on guard)
            context.go(AppRouter.home);
          }
        } else {
          CustomSnackbar.showError("Email not verified yet. Please check your inbox.");
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
    if (context.mounted) {
      context.go(AppRouter.onboarding);
    }
  }
}
