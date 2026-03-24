import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel() {
    debugPrint("--- RegisterViewModel Initialized ---");
  }

  final nameController = TextEditingController();
  final countryController = TextEditingController();
  final cityController = TextEditingController();
  final nationalityController = TextEditingController();
  final phoneController = TextEditingController();
  final studyCountryController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Static caches for JSON data to avoid repeated parsing
  static List<Map<String, dynamic>>? _cachedCountries;
  static Map<String, String>? _cachedStates;
  static List<Map<String, dynamic>>? _cachedCities;

  bool isGoogleOnboarding = false;

  void setGoogleOnboarding(bool value) {
    isGoogleOnboarding = value;
    notifyListeners();
  }

  void prefillFromGoogle({String? name, String? email}) {
    if (name != null) nameController.text = name;
    // email is handled by the view transition typically, but we can set it if needed
    notifyListeners();
  }

  bool receiveUpdates = true;
  bool obscurePassword = true;
  bool agreedToTerms = false;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

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
      return "This Field is required to proceed";
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
    // Simple validation for 10 digits (ignoring spaces)
    final digits = value.replaceAll(' ', '');
    if (!RegExp(r'^\d{10}$').hasMatch(digits)) {
      return "Please enter a valid 10-digit phone number";
    }
    return null;
  }

  String? validateStudyCountry(String? value) =>
      validateRequired(value, "Study country");

  String? validatePassword(String? value) {
    if (isGoogleOnboarding) return null; // No password needed for Google users
    
    if (value == null || value.trim().isEmpty) {
      return "Password is required";
    }
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    if (!regex.hasMatch(value)) {
      return "Password must have 8 characters with a number, symbol, uppercase and lowercase";
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

  void toggleAgreedToTerms(bool? value) {
    agreedToTerms = value ?? false;
    notifyListeners();
  }

  void updateCountry(Map<String, dynamic> country) {
    countryController.text = country['name'] ?? '';
    _selectedCountryId = country['id']?.toString();
    _selectedCountryIso2 = country['iso2']?.toString();
    _selectedCountryIso3 = country['iso3']?.toString();
    cityController.clear();
    notifyListeners();
  }

  void updateNationality(Map<String, dynamic> country) {
    nationalityController.text = country['name'] ?? '';
    notifyListeners();
  }

  String? _selectedCountryId;
  String? _selectedCountryIso2;
  String? _selectedCountryIso3;

  bool get isCountrySelected => countryController.text.isNotEmpty;

  Future<List<Map<String, dynamic>>> getAllCountries() async {
    if (_cachedCountries != null) return _cachedCountries!;
    try {
      final String response = await rootBundle.loadString('packages/country_state_city_pro/assets/country.json');
      final List<dynamic> data = json.decode(response);
      _cachedCountries = data.cast<Map<String, dynamic>>();
      return _cachedCountries!;
    } catch (e) {
      debugPrint("--- Error loading countries: $e ---");
      return [];
    }
  }

  Future<void> _loadStates() async {
    if (_cachedStates != null) return;
    try {
      final String response = await rootBundle.loadString('packages/country_state_city_pro/assets/state.json');
      final List<dynamic> data = json.decode(response);
      _cachedStates = {};
      for (var state in data) {
        final id = state['id']?.toString();
        final name = state['name']?.toString();
        if (id != null && name != null) {
          _cachedStates![id] = name;
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
      if (_cachedCities == null) {
        final String response = await rootBundle.loadString('packages/country_state_city_pro/assets/city.json');
        _cachedCities = json.decode(response).cast<Map<String, dynamic>>();
      }
      
      final filtered = _cachedCities!.where((city) {
        final countryId = city['country_id']?.toString();
        return countryId == _selectedCountryId || 
               countryId == _selectedCountryIso2 || 
               countryId == _selectedCountryIso3;
      }).map((cityData) {
        final city = Map<String, dynamic>.from(cityData);
        final stateId = city['state_id']?.toString();
        final stateName = _cachedStates?[stateId];
        
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
