import 'package:flutter/material.dart';
import '../../data/auth_service.dart';
import '../../data/models/user_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  
  bool get isLoading => _isLoading;
  String? _selectedStudyLevel;
  String? _selectedStartYear;
  String? _selectedMonthRange;
  bool _isStartDateExpanded = false;
  bool _isStudyLevelExpanded = false;

  late final List<String> _years;
  final List<String> _months = [
    "Apr - June",
    "July - Sept",
    "Oct - Dec",
    "Help me decide",
  ];
  final List<String> _studyLevels = [
    "Undergraduate",
    "Post graduate",
    "Doctorate",
    "Other",
  ];

  ProfileViewModel() {
    final currentYear = DateTime.now().year;
    _years = [
      currentYear.toString(),
      (currentYear + 1).toString(),
      (currentYear + 2).toString(),
      "Help me decide",
    ];
    _selectedStartYear = _years[0];
  }

  // Getters
  String? get selectedStudyLevel => _selectedStudyLevel;
  String? get selectedStartYear => _selectedStartYear;
  String? get selectedMonthRange => _selectedMonthRange;
  bool get isStartDateExpanded => _isStartDateExpanded;
  bool get isStudyLevelExpanded => _isStudyLevelExpanded;
  List<String> get years => _years;
  List<String> get months => _months;
  List<String> get studyLevels => _studyLevels;
  bool get isAnyExpanded => _isStartDateExpanded || _isStudyLevelExpanded;

  // Setters/Actions
  void setStudyLevel(String level) {
    _selectedStudyLevel = level;
    _isStudyLevelExpanded = false;
    notifyListeners();
  }

  void setStartYear(String year) {
    _selectedStartYear = year;
    notifyListeners();
  }

  void setMonthRange(String range) {
    _selectedMonthRange = range;
    notifyListeners();
  }

  void toggleStartDateExpansion() {
    _isStartDateExpanded = !_isStartDateExpanded;
    _isStudyLevelExpanded = false;
    notifyListeners();
  }

  void toggleStudyLevelExpansion() {
    _isStudyLevelExpanded = !_isStudyLevelExpanded;
    _isStartDateExpanded = false;
    notifyListeners();
  }

  void collapseAll() {
    _isStartDateExpanded = false;
    _isStudyLevelExpanded = false;
    notifyListeners();
  }

  Future<bool> saveProfile() async {
    debugPrint("PROFILE: saveProfile() called");
    final user = _authService.currentUser;
    if (user == null) {
      debugPrint("PROFILE: Error - currentUser is NULL");
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Fetch existing user data first to avoid overwriting with nulls
      final existingData = await _authService.getUserData(user.uid);
      debugPrint("PROFILE: Raw user data from Firestore: ${existingData?.toMap()}");
      
      UserModel userModel;
      if (existingData != null) {
        // 2. Merge new fields into existing data
        userModel = existingData.copyWith(
          profession: _selectedStudyLevel,
          gradingSystem: _selectedStartYear,
          cgpa: _selectedMonthRange,
        );
        debugPrint("PROFILE: Merged user data: ${userModel.toMap()}");
      } else {
        debugPrint("PROFILE: No existing data found for UID: ${user.uid}. Creating new.");
        // Fallback for new user without existing data
        userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          profession: _selectedStudyLevel,
          gradingSystem: _selectedStartYear,
          cgpa: _selectedMonthRange,
          createdAt: DateTime.now(),
        );
      }

      await _authService.saveUserData(userModel);
      return true;
    } catch (e) {
      debugPrint("Error saving profile: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
