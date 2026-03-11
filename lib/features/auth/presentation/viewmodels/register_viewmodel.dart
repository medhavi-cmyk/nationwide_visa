import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel() {
    debugPrint("--- RegisterViewModel Initialized (CSC PRO Fixed) ---");
  }

  final nameController = TextEditingController();
  final countryController = TextEditingController();
  final cityController = TextEditingController();
  final nationalityController = TextEditingController();
  final phoneController = TextEditingController();
  final studyCountryController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool receiveUpdates = true;
  bool obscurePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    countryController.dispose();
    cityController.dispose();
    nationalityController.dispose();
    phoneController.dispose();
    studyCountryController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return "This Field is required to procceed";
    }
    return null;
  }

  String? validateFullName(String? value) =>
      validateRequired(value, "Full name");
  String? validateCountry(String? value) => validateRequired(value, "Country");
  String? validateCity(String? value) => validateRequired(value, "City");
  String? validateNationality(String? value) =>
      validateRequired(value, "Nationality");
  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Phone number is required";
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
      return "Please enter a valid 10-digit phone number";
    }
    return null;
  }

  String? validateStudyCountry(String? value) =>
      validateRequired(value, "Study country");

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Password is required";
    }
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    if (!regex.hasMatch(value)) {
      return "Password must have 8 characters with a number , symbol, uppercase and lower case";
    }
    return null;
  }

  bool validateForm() {
    final isValid = formKey.currentState?.validate() ?? false;
    notifyListeners();
    return isValid;
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleReceiveUpdates(bool? value) {
    receiveUpdates = value ?? false;
    notifyListeners();
  }

  void updateCountry(Map<String, dynamic> country) {
    debugPrint("--- Selected Country Data: $country ---");
    countryController.text = country['name'] ?? '';
    _selectedCountryId = country['id']?.toString();
    _selectedCountryIso2 = country['iso2']?.toString();
    _selectedCountryIso3 = country['iso3']?.toString();
    cityController.clear();
    notifyListeners();
  }

  void updateNationality(Map<String, dynamic> country) {
    debugPrint("--- Selected Nationality Data: $country ---");
    nationalityController.text = country['name'] ?? '';
    notifyListeners();
  }

  String? _selectedCountryId;
  String? _selectedCountryIso2;
  String? _selectedCountryIso3;
  final Map<String, String> _stateNames = {};

  bool get isCountrySelected => countryController.text.isNotEmpty;

  Future<List<Map<String, dynamic>>> getAllCountries() async {
    debugPrint("--- Fetching Countries ---");
    try {
      final String response = await rootBundle.loadString('packages/country_state_city_pro/assets/country.json');
      final List<dynamic> data = json.decode(response);
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint("--- Error loading countries: $e ---");
      return [];
    }
  }

  Future<void> _loadStates() async {
    if (_stateNames.isNotEmpty) return;
    try {
      final String response = await rootBundle.loadString('packages/country_state_city_pro/assets/state.json');
      final List<dynamic> data = json.decode(response);
      for (var state in data) {
        final id = state['id']?.toString();
        final name = state['name']?.toString();
        if (id != null && name != null) {
          _stateNames[id] = name;
        }
      }
    } catch (e) {
      debugPrint("--- Error loading states: $e ---");
    }
  }

  Future<List<Map<String, dynamic>>> getCitiesForSelectedCountry() async {
    if (_selectedCountryId == null && _selectedCountryIso2 == null) {
      return [];
    }

    await _loadStates();

    try {
      final String response = await rootBundle.loadString('packages/country_state_city_pro/assets/city.json');
      final List<dynamic> data = json.decode(response);
      
      final filtered = data.where((city) {
        final countryId = city['country_id']?.toString();
        return countryId == _selectedCountryId || 
               countryId == _selectedCountryIso2 || 
               countryId == _selectedCountryIso3;
      }).map((cityData) {
        final city = Map<String, dynamic>.from(cityData);
        final stateId = city['state_id']?.toString();
        final stateName = _stateNames[stateId];
        
        if (stateName != null) {
          city['displayName'] = "${city['name']}, $stateName";
        } else {
          city['displayName'] = city['name'];
        }
        return city;
      }).toList();

      return filtered;
    } catch (e) {
      debugPrint("--- Error loading cities: $e ---");
      return [];
    }
  }

  void updateCity(String city) {
    cityController.text = city;
    notifyListeners();
  }

  void updateStudyCountry(String country) {
    studyCountryController.text = country;
    notifyListeners();
  }
}
