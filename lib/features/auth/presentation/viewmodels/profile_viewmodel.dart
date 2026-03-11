import 'package:flutter/material.dart';

class ProfileViewModel extends ChangeNotifier {
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
}
