import 'package:flutter/material.dart';

class RegisterViewModel {
  final nameController = TextEditingController();
  final countryController = TextEditingController();
  final cityController = TextEditingController();
  final nationalityController = TextEditingController();
  final phoneController = TextEditingController();
  final studyCountryController = TextEditingController();
  final passwordController = TextEditingController();

  bool receiveUpdates = true;
  bool obscurePassword = true;

  void dispose() {
    nameController.dispose();
    countryController.dispose();
    cityController.dispose();
    nationalityController.dispose();
    phoneController.dispose();
    studyCountryController.dispose();
    passwordController.dispose();
  }

  String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "this field is required to proccede.";
    }
    return null;
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
  }

  void toggleReceiveUpdates(bool? value) {
    receiveUpdates = value ?? false;
  }

  void updateCountry(String country) {
    countryController.text = country;
  }
}
