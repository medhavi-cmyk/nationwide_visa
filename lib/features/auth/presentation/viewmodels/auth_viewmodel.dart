import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../data/auth_service.dart';
import '../../data/models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  // Changed to 6 digits to match Firebase default
  final List<TextEditingController> controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
  
  Timer? _resendTimer;
  int _secondsRemaining = 0;
  bool _canResend = true;
  String? _verificationId;
  bool _isLoading = false;
  String? _errorMessage;

  int get secondsRemaining => _secondsRemaining;
  bool get canResend => _canResend;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthViewModel();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void startResendTimer() {
    debugPrint("--- Starting Resend Timer ---");
    _canResend = false;
    _secondsRemaining = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        debugPrint("--- Resend Timer Expired ---");
        _canResend = true;
        _resendTimer?.cancel();
        notifyListeners();
      }
    });
    notifyListeners();
  }

  // Send OTP
  Future<void> sendOtp(String phoneNumber) async {
    debugPrint("--- Attempting to send OTP to: $phoneNumber ---");
    _setLoading(true);
    _setError(null);
    
    // Start timer early so user sees feedback
    startResendTimer();

    try {
      String formattedPhone = phoneNumber.replaceAll(' ', '');
      if (!formattedPhone.startsWith('+')) {
        formattedPhone = '+91$formattedPhone'; 
      }
      
      debugPrint("--- Formatted Phone for Firebase: $formattedPhone ---");

      await _authService.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        onCodeSent: (verificationId, resendToken) {
          debugPrint("--- OTP Code Sent! Verification ID: $verificationId ---");
          _verificationId = verificationId;
          _setLoading(false);
          // Timer is already running
        },
        onVerificationFailed: (e) {
          debugPrint("--- OTP Verification Failed: ${e.message} (Code: ${e.code}) ---");
          _setError(e.message ?? "Verification failed. Check your phone number.");
          _setLoading(false);
          _canResend = true;
          _resendTimer?.cancel();
          _secondsRemaining = 0;
          notifyListeners();
        },
        onVerificationCompleted: (credential) async {
          debugPrint("--- Phone Verification Auto-Completed ---");
          // Optionally auto-verify here
        },
        onCodeAutoRetrievalTimeout: (verificationId) {
          debugPrint("--- OTP Code Auto-Retrieval Timeout ---");
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      debugPrint("--- Send OTP Catch Error: $e ---");
      _setError("Failed to send OTP: $e");
      _setLoading(false);
      _canResend = true;
      _resendTimer?.cancel();
      _secondsRemaining = 0;
      notifyListeners();
    }
  }

  // Verify OTP and Finalize Registration
  Future<bool> verifyAndRegister({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String country,
  }) async {
    debugPrint("--- Verifying OTP and Registering user ---");
    if (_verificationId == null) {
      _setError("Please wait for the code to be sent");
      return false;
    }

    if (!isOtpComplete) {
      _setError("Please enter the 6-digit code");
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpCode,
      );

      debugPrint("--- Signing in with Phone Credential ---");
      final userCredential = await _authService.signInWithPhoneCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        debugPrint("--- Successfully signed in with Phone. UID: ${user.uid} ---");
        
        debugPrint("--- Linking Email and Password ---");
        await _authService.linkEmailPassword(email, password);

        debugPrint("--- Saving User Data to Firestore ---");
        final userModel = UserModel(
          uid: user.uid,
          email: email,
          name: name,
          phoneNumber: phoneNumber,
          country: country,
          createdAt: DateTime.now(),
        );
        await _authService.saveUserData(userModel);
        
        debugPrint("--- Registration Complete! ---");
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("--- Verify/Register Error: $e ---");
      _setError("Verification failed: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void resendCode(String phoneNumber) {
    if (_canResend) {
      sendOtp(phoneNumber);
    }
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void onCodeChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
    notifyListeners();
  }

  bool get isOtpComplete => controllers.every((c) => c.text.isNotEmpty);

  String get otpCode => controllers.map((c) => c.text).join();

  void clearOtp() {
    for (var controller in controllers) {
      controller.clear();
    }
    focusNodes[0].requestFocus();
    notifyListeners();
  }
}
