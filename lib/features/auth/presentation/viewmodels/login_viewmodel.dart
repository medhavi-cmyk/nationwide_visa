import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/auth_service.dart';
import '../../data/models/user_model.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService;

  LoginViewModel({AuthService? authService})
    : _authService = authService ?? AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isResetEmailSent = false;
  bool get isResetEmailSent => _isResetEmailSent;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your email";
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return "Please enter a valid email";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your password";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  bool validateForm() {
    final isValid = formKey.currentState?.validate() ?? false;
    notifyListeners();
    return isValid;
  }

  Future<void> checkEmailAndRedirect({
    required Function(String email) onAccountExists,
    required Function(String email) onNewUser,
  }) async {
    if (!validateForm()) return;

    _setLoading(true);
    _setError(null);

    try {
      String email = emailController.text.trim();
      bool exists = await _authService.doesEmailExist(email);

      if (exists) {
        onAccountExists(email);
      } else {
        onNewUser(email);
      }
    } catch (e) {
      _setError("Failed to check email: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _setError(null);
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null && userCredential.user != null) {
        final String uid = userCredential.user!.uid;
        final bool isComplete = await _authService.isUserComplete(uid);

        if (!isComplete) {
          debugPrint("--- User incomplete. Triggering onboarding ---");
          return false; // Return false to indicate "Incomplete", or we can return a custom result
        }
        return true;
      }
      return false;
    } on Exception catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains('PlatformException')) {
        // Specifically extract the error code from platform exceptions
        _setError(
          "Google Error: ${errorMsg.split(',').first.split(':').last.trim()}",
        );
      } else {
        _setError("Google sign in failed: $e");
      }
      return false;
    } catch (e) {
      _setError("An unexpected error occurred: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithEmail(String password) async {
    _setLoading(true);
    _setError(null);
    try {
      final userCredential = await _authService.signInWithEmail(
        emailController.text.trim(),
        password,
      );
      if (userCredential != null && userCredential.user != null) {
        final bool isComplete = await _authService.isUserComplete(userCredential.user!.uid);
        if (!isComplete) {
          debugPrint("--- User incomplete. Triggering onboarding ---");
          return false; // Return false without setting errorMessage to indicate "Incomplete"
        }
        return true;
      }
      return false;
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          _setError("No account found with this email.");
        } else if (e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          _setError("Incorrect password. Please try again.");
        } else if (e.code == 'user-disabled') {
          _setError("This account has been disabled.");
        } else {
          _setError("Sign in failed: ${e.message}");
        }
      } else {
        _setError("Sign in error: $e");
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendPasswordResetEmail() async {
    String email = emailController.text.trim();
    if (email.isEmpty) {
      _setError("Please enter your email");
      return false;
    }

    _setLoading(true);
    _setError(null);
    _isResetEmailSent = false;

    try {
      await _authService.sendPasswordResetEmail(email);
      _isResetEmailSent = true;
      notifyListeners();
      return true;
    } catch (e) {
      _setError("Failed to send reset email: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUpWithEmail(String password) async {
    _setLoading(true);
    _setError(null);
    try {
      final userCredential = await _authService.signUpWithEmail(
        emailController.text.trim(),
        password,
      );
      if (userCredential != null && userCredential.user != null) {
        final userModel = UserModel(
          uid: userCredential.user!.uid,
          email: emailController.text.trim(),
          createdAt: DateTime.now(),
        );
        await _authService.saveUserData(userModel);
        return true;
      }
      return false;
    } catch (e) {
      _setError("Sign up failed: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void updateEmail(String value) {
    emailController.text = value;
    emailController.selection = TextSelection.fromPosition(
      TextPosition(offset: emailController.text.length),
    );
    notifyListeners();
  }

  bool get showSuggestions {
    final text = emailController.text;
    return text.isNotEmpty && !text.contains('@');
  }
}
