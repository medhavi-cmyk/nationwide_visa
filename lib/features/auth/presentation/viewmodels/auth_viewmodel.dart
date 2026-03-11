import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  final List<TextEditingController> controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void onCodeChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
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
