import 'package:flutter/material.dart';
import '../../data/auth_service.dart';
import '../../data/models/user_model.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    emailController.dispose();
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
        final userModel = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          name: userCredential.user!.displayName,
          createdAt: DateTime.now(),
        );
        await _authService.saveUserData(userModel);
        return true;
      }
      return false;
    } catch (e) {
      _setError("Google sign in failed: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithEmail(String password) async {
    _setLoading(true);
    _setError(null);
    try {
      final user = await _authService.signInWithEmail(emailController.text.trim(), password);
      return user != null;
    } catch (e) {
      _setError("Sign in failed: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUpWithEmail(String password) async {
    _setLoading(true);
    _setError(null);
    try {
      final userCredential = await _authService.signUpWithEmail(emailController.text.trim(), password);
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
}
