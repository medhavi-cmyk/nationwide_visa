import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import '../../../../features/auth/presentation/widgets/country_picker.dart';
import '../../../../features/auth/presentation/widgets/city_picker.dart';

void showEditProfileSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _EditProfileSheet(),
  );
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet();

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  int _tab = 0;
  final _formKey = GlobalKey<FormState>();

  static const Color _bgGrey = Color(0xFFF2F3F7);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textGrey = Color(0xFF6B7280);
  static const Color _borderGrey = Color(0xFFE2E8EF);
  static const Color _red = Color(0xFFC00A15);
  static const Color _redLight = Color(0xFFE53935);

  final _nameCtrl = TextEditingController(text: 'Medhavi Sharma');
  final _emailCtrl = TextEditingController(
    text: 'medhavisharma11apr@gmail.com',
  );
  final _phoneCtrl = TextEditingController(text: '88513 32289');

  String _country = 'India';
  String _city = 'Delhi Cantonment';
  String _nationality = 'India';
  String? _selectedCountryId;
  String? _selectedCountryIso2;
  String? _selectedCountryIso3;
  final Map<String, String> _stateNames = {};
  String? _dob;

  // validation error messages for picker fields
  String? _countryError;
  String? _cityError;
  String? _nationalityError;
  String? _dobError;

  // ── Qualification expand state ────────────────────────────────────────────
  bool _academicExpanded = false;
  bool _englishExpanded = false;
  bool _standardizedExpanded = false;

  // Academic form
  String? _qualification;
  String _eduCountry = '';
  String? _university;
  String? _gradingSystem;
  final _gradingValueCtrl = TextEditingController();
  String _major = ''; // studied major (from course picker)

  // English form
  String? _englishTest;

  // Standardized form
  String? _standardizedTest;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _gradingValueCtrl.dispose();
    super.dispose();
  }

  // ── DATA ─────────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> _loadCountries() async {
    try {
      final raw = await rootBundle.loadString(
        'packages/country_state_city_pro/assets/country.json',
      );
      return (json.decode(raw) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<void> _ensureStates() async {
    if (_stateNames.isNotEmpty) return;
    try {
      final raw = await rootBundle.loadString(
        'packages/country_state_city_pro/assets/state.json',
      );
      for (final s in (json.decode(raw) as List)) {
        final id = s['id']?.toString();
        final name = s['name']?.toString();
        if (id != null && name != null) _stateNames[id] = name;
      }
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> _loadCities() async {
    if (_selectedCountryId == null && _selectedCountryIso2 == null) return [];
    await _ensureStates();
    try {
      final raw = await rootBundle.loadString(
        'packages/country_state_city_pro/assets/city.json',
      );
      return (json.decode(raw) as List)
          .where((city) {
            final cid = city['country_id']?.toString();
            return cid == _selectedCountryId ||
                cid == _selectedCountryIso2 ||
                cid == _selectedCountryIso3;
          })
          .map((cityData) {
            final city = Map<String, dynamic>.from(cityData as Map);
            final stateName = _stateNames[city['state_id']?.toString()];
            city['displayName'] = stateName != null
                ? '${city['name']}, $stateName'
                : city['name'];
            return city;
          })
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── PICKERS ───────────────────────────────────────────────────────────────────
  void _pickCountry() async {
    final countries = await _loadCountries();
    if (!mounted) return;
    CountryPickerView.show(context, countries, (selected) {
      setState(() {
        _country = selected['name'] ?? '';
        _selectedCountryId = selected['id']?.toString();
        _selectedCountryIso2 = selected['iso2']?.toString();
        _selectedCountryIso3 = selected['iso3']?.toString();
        _city = '';
        _countryError = null;
        _cityError = null;
      });
    });
  }

  void _pickCity() async {
    final cities = await _loadCities();
    if (!mounted) return;
    CityPickerView.show(context, cities, (selected) {
      setState(() {
        _city = selected;
        _cityError = null;
      });
    });
  }

  void _pickNationality() async {
    final countries = await _loadCountries();
    if (!mounted) return;
    CountryPickerView.show(
      context,
      countries,
      (selected) => setState(() {
        _nationality = selected['name'] ?? '';
        _nationalityError = null;
      }),
      title: 'Select Nationality',
      hint: 'Nationality',
    );
  }

  // ── VALIDATION ───────────────────────────────────────────────────────────────
  bool _validate() {
    final formValid = _formKey.currentState?.validate() ?? false;
    setState(() {
      _countryError = _country.isEmpty ? 'Country is required' : null;
      _cityError = _city.isEmpty ? 'City is required' : null;
      _nationalityError = _nationality.isEmpty
          ? 'Nationality is required'
          : null;
      _dobError = _dob == null ? 'Date of birth is required' : null;
    });
    return formValid &&
        _countryError == null &&
        _cityError == null &&
        _nationalityError == null &&
        _dobError == null;
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _tabChip(0, 'Basic information'),
                const SizedBox(width: 10),
                _tabChip(1, 'Qualifications'),
                const SizedBox(width: 10),
                _tabChip(2, 'Preferences'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: [
                _buildBasicInfo(bottom),
                _buildQualifications(),
                _buildComingSoon('Preferences'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabChip(int index, String label) {
    final selected = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _textDark : _bgGrey,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : _textGrey,
          ),
        ),
      ),
    );
  }

  // ── BASIC INFO FORM ───────────────────────────────────────────────────────────
  Widget _buildBasicInfo(double keyboardHeight) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 8, 16, keyboardHeight + 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full name
                  TextFormField(
                    controller: _nameCtrl,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Full name is required'
                        : null,
                    decoration: _inputDeco(label: 'Full name'),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      'As per your passport or ID proof',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: _textGrey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Country
                  _pickerField(
                    label: 'Country',
                    value: _country,
                    onTap: _pickCountry,
                    errorText: _countryError,
                  ),
                  const SizedBox(height: 12),

                  // City
                  _pickerField(
                    label: 'City',
                    value: _city,
                    onTap: _selectedCountryId != null ? _pickCity : null,
                    disabled: _selectedCountryId == null,
                    errorText: _cityError,
                  ),
                  const SizedBox(height: 12),

                  // Nationality
                  _pickerField(
                    label: 'Nationality',
                    value: _nationality,
                    onTap: _pickNationality,
                    errorText: _nationalityError,
                  ),
                  const SizedBox(height: 12),

                  // Date of birth
                  _dobField(),
                  const SizedBox(height: 12),

                  // Email — read-only / non-editable
                  TextFormField(
                    controller: _emailCtrl,
                    readOnly: true,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _textGrey,
                    ),
                    decoration: _inputDeco(label: 'Email Address').copyWith(
                      fillColor: const Color(0xFFF9FAFB),
                      suffixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        size: 18,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Phone
                  _phoneField(),
                ],
              ),
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  InputDecoration _inputDeco({required String label}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(fontSize: 12, color: _textGrey),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderGrey, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _red, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _red, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _red, width: 1.5),
      ),
      errorStyle: GoogleFonts.poppins(fontSize: 11, color: _red),
    );
  }

  // ── PICKER FIELD ──────────────────────────────────────────────────────────────
  Widget _pickerField({
    required String label,
    required String value,
    required VoidCallback? onTap,
    bool disabled = false,
    String? errorText,
  }) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: disabled ? null : onTap,
          child: Container(
            decoration: BoxDecoration(
              color: disabled ? const Color(0xFFF9FAFB) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasError ? _red : _borderGrey,
                width: hasError ? 1.5 : 1.2,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: hasError ? _red : _textGrey,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value.isEmpty ? label : value,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: value.isEmpty || disabled
                              ? _textGrey
                              : _textDark,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: disabled
                          ? const Color(0xFFD1D5DB)
                          : const Color(0xFF9CA3AF),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 4),
            child: Text(
              errorText,
              style: GoogleFonts.poppins(fontSize: 11, color: _red),
            ),
          ),
      ],
    );
  }

  // ── DATE OF BIRTH ─────────────────────────────────────────────────────────────
  Widget _dobField() {
    final hasError = _dobError != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(2000),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
              builder: (ctx, child) => Theme(
                data: Theme.of(
                  ctx,
                ).copyWith(colorScheme: const ColorScheme.light(primary: _red)),
                child: child!,
              ),
            );
            if (picked != null) {
              setState(() {
                _dob =
                    '${picked.day.toString().padLeft(2, '0')} / ${picked.month.toString().padLeft(2, '0')} / ${picked.year}';
                _dobError = null;
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasError ? _red : _borderGrey,
                width: hasError ? 1.5 : 1.2,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date of birth',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: hasError ? _red : _textGrey,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _dob ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: _dob != null ? 15 : 14,
                          fontWeight: _dob != null
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: _dob != null ? _textDark : _textGrey,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF9CA3AF),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 4),
            child: Text(
              _dobError!,
              style: GoogleFonts.poppins(fontSize: 11, color: _red),
            ),
          ),
      ],
    );
  }

  // ── PHONE FIELD ───────────────────────────────────────────────────────────────
  Widget _phoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderGrey, width: 1.2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Text('🇮🇳', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    if (!RegExp(r'^\d{5}\s\d{5}$').hasMatch(v.trim()) &&
                        !RegExp(r'^\d{10}$').hasMatch(v.trim())) {
                      return 'Enter a valid 10-digit number';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: 'Phone number',
                    prefixText: '+91  ',
                    prefixStyle: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                    errorStyle: GoogleFonts.poppins(fontSize: 11, color: _red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── BOTTOM BUTTONS ────────────────────────────────────────────────────────────
  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF3F4F6), width: 1)),
      ),
      child: Row(
        children: [
          // Cancel
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: const StadiumBorder(),
                side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                backgroundColor: const Color(0xFFF3F4F6),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Save — red gradient
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_validate()) Navigator.pop(context);
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_red, _redLight],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Save',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── QUALIFICATIONS TAB ───────────────────────────────────────────────────────
  Widget _buildQualifications() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── ACADEMIC QUALIFICATION ────────────────────────────────────
          if (!_academicExpanded)
            _addButton(
              label: 'Academic qualification',
              buttonLabel: 'Add Academic Qualification',
              onTap: () => setState(() => _academicExpanded = true),
            )
          else
            _academicForm(),

          const SizedBox(height: 28),

          // ── ENGLISH LANGUAGE ──────────────────────────────────────────────
          if (!_englishExpanded)
            _addButton(
              label: 'English Language',
              buttonLabel: 'Add English Language',
              onTap: () => setState(() => _englishExpanded = true),
            )
          else
            _englishForm(),

          const SizedBox(height: 28),

          // ── STANDARDIZED TEST ──────────────────────────────────────────────
          if (!_standardizedExpanded)
            _addButton(
              label: 'Standardized Test',
              buttonLabel: 'Add Standardized Test',
              onTap: () => setState(() => _standardizedExpanded = true),
            )
          else
            _standardizedForm(),
        ],
      ),
    );
  }

  // ── ADD BUTTON (collapsed state) ─────────────────────────────────────────
  Widget _addButton({
    required String label,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFECEC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, color: _red, size: 18),
                const SizedBox(width: 6),
                Text(
                  buttonLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── ACADEMIC QUALIFICATION FORM ──────────────────────────────────────────
  Widget _academicForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header label + add button active
        _addButtonActive('Add Academic Qualification'),
        const SizedBox(height: 14),

        // Qualification dropdown
        _qualDropdown(
          hint: 'Qualification',
          value: _qualification,
          items: [
            'Bachelors',
            'Masters',
            'PhD',
            'Diploma',
            'High School',
            'Other',
          ],
          onChanged: (v) => setState(() => _qualification = v),
        ),
        const SizedBox(height: 10),

        // Country of education — taps CountryPicker
        GestureDetector(
          onTap: () async {
            final countries = await _loadCountries();
            if (!mounted) return;
            CountryPickerView.show(context, countries, (selected) {
              setState(() => _eduCountry = selected['name'] ?? '');
            });
          },
          child: _qualField(
            hint: 'Country of education',
            value: _eduCountry.isEmpty ? null : _eduCountry,
          ),
        ),
        const SizedBox(height: 10),

        // University (optional)
        _qualDropdown(
          hint: 'University (optional)',
          value: _university,
          items: [
            'University of Delhi',
            'IIT Bombay',
            'IIT Delhi',
            'Mumbai University',
            'Other',
          ],
          onChanged: (v) => setState(() => _university = v),
        ),
        const SizedBox(height: 10),

        // Grading system
        _qualDropdown(
          hint: 'Grading system',
          value: _gradingSystem,
          items: ['GPA (4.0)', 'GPA (10.0)', 'Percentage', 'CGPA', 'Other'],
          onChanged: (v) => setState(() => _gradingSystem = v),
        ),
        const SizedBox(height: 10),

        // Grading value — hint reflects selected system
        _plainTextField(
          controller: _gradingValueCtrl,
          label: _gradingSystem == null
              ? 'Grading system value'
              : _gradingSystem == 'GPA (4.0)'
              ? 'Enter GPA out of 4.0 '
              : _gradingSystem == 'GPA (10.0)'
              ? 'Enter GPA out of 10.0 '
              : _gradingSystem == 'Percentage'
              ? 'Enter percentage'
              : _gradingSystem == 'CGPA'
              ? 'Enter CGPA'
              : 'Enter your grade value',
          hint:
              'e.g. ${_gradingSystem == 'GPA (4.0)'
                  ? '3.8'
                  : _gradingSystem == 'GPA (10.0)'
                  ? '8.5'
                  : _gradingSystem == 'Percentage'
                  ? '85%'
                  : _gradingSystem == 'CGPA'
                  ? '8.5'
                  : '—'}',
        ),
        const SizedBox(height: 10),

        // Studied major — opens searchable course picker
        GestureDetector(
          onTap: _showCoursePicker,
          child: _qualField(
            hint: 'Studied major',
            value: _major.isEmpty ? null : _major,
          ),
        ),
        const SizedBox(height: 16),

        _qualCancelSave(
          onCancel: () => setState(() {
            _academicExpanded = false;
            _qualification = null;
            _eduCountry = '';
            _university = null;
            _gradingSystem = null;
            _gradingValueCtrl.clear();
            _major = '';
          }),
          onSave: () => setState(() => _academicExpanded = false),
        ),
      ],
    );
  }

  // ── ENGLISH LANGUAGE FORM ───────────────────────────────────────────────
  Widget _englishForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'English Language',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 10),
        _addButtonActive('Add English Language'),
        const SizedBox(height: 14),

        _qualDropdown(
          hint: 'English language test',
          value: _englishTest,
          items: [
            'IELTS',
            'TOEFL',
            'PTE',
            'Cambridge English',
            'Duolingo',
            'None',
          ],
          onChanged: (v) => setState(() => _englishTest = v),
        ),
        const SizedBox(height: 16),

        _qualCancelSave(
          onCancel: () => setState(() {
            _englishExpanded = false;
            _englishTest = null;
          }),
          onSave: () => setState(() => _englishExpanded = false),
        ),
      ],
    );
  }

  // ── STANDARDIZED TEST FORM ──────────────────────────────────────────────
  Widget _standardizedForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Standardized Test',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 10),
        _addButtonActive('Add Standardized Test'),
        const SizedBox(height: 14),

        _qualDropdown(
          hint: 'Standardized test',
          value: _standardizedTest,
          items: ['GRE', 'GMAT', 'SAT', 'ACT', 'LSAT', 'MCAT', 'None'],
          onChanged: (v) => setState(() => _standardizedTest = v),
        ),
        const SizedBox(height: 16),

        _qualCancelSave(
          onCancel: () => setState(() {
            _standardizedExpanded = false;
            _standardizedTest = null;
          }),
          onSave: () => setState(() => _standardizedExpanded = false),
        ),
      ],
    );
  }

  // ── FORM HELPERS ──────────────────────────────────────────────────────────────

  /// The filled active header (shown when form is expanded)
  Widget _addButtonActive(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFECEC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add, color: _red, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _qualDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderGrey, width: 1.2),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Always-visible label
          Text(
            hint,
            style: GoogleFonts.poppins(fontSize: 11, color: _textGrey),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF9CA3AF),
              ),
              dropdownColor: Colors.white,
              // When no value selected, show a greyed placeholder
              hint: Text(
                'Select',
                style: GoogleFonts.poppins(fontSize: 14, color: _textGrey),
              ),
              selectedItemBuilder: (ctx) => items
                  .map(
                    (e) => Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        e,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              items: items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _textDark,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _qualField({required String hint, String? value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderGrey, width: 1.2),
      ),
      child: Text(
        value ?? hint,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: value != null ? _textDark : _textGrey,
          fontWeight: value != null ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _plainTextField({
    required TextEditingController controller,
    required String hint,
    String? label, // always-visible small label on top (like _qualDropdown)
  }) {
    if (label != null) {
      // Wrap in a container with a persistent label, same style as _qualDropdown
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderGrey, width: 1.2),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 12, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 11, color: _textGrey),
            ),
            TextField(
              controller: controller,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: GoogleFonts.poppins(fontSize: 14, color: _textGrey),
              ),
            ),
          ],
        ),
      );
    }
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(fontSize: 14, color: _textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: _textGrey),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderGrey, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _red, width: 1.5),
        ),
      ),
    );
  }

  Widget _qualCancelSave({
    required VoidCallback onCancel,
    required VoidCallback onSave,
  }) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: const StadiumBorder(),
              side: const BorderSide(color: _borderGrey, width: 1.5),
              backgroundColor: const Color(0xFFF3F4F6),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: onSave,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_red, _redLight],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              alignment: Alignment.center,
              child: Text(
                'Save',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── COMING SOON ───────────────────────────────────────────────────────────────
  Widget _buildComingSoon(String tab) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.construction_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            '$tab coming soon',
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: _textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── COURSE PICKER ─────────────────────────────────────────────────────────────
  void _showCoursePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _CoursePicker(onSelect: (course) => setState(() => _major = course)),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Standalone searchable course picker sheet
// ────────────────────────────────────────────────────────────────────────────
class _CoursePicker extends StatefulWidget {
  final ValueChanged<String> onSelect;
  const _CoursePicker({required this.onSelect});

  @override
  State<_CoursePicker> createState() => _CoursePickerState();
}

class _CoursePickerState extends State<_CoursePicker> {
  static const Color _red = Color(0xFFC00A15);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textGrey = Color(0xFF6B7280);

  static const List<String> _allCourses = [
    // Business & Management
    'Business Administration (BBA)', 'Master of Business Administration (MBA)',
    'Finance', 'Accounting', 'Marketing', 'Human Resource Management',
    'International Business', 'Economics', 'Entrepreneurship',
    // Engineering & Technology
    'Computer Science', 'Software Engineering', 'Electrical Engineering',
    'Mechanical Engineering', 'Civil Engineering', 'Chemical Engineering',
    'Aerospace Engineering', 'Biomedical Engineering', 'Data Science',
    'Artificial Intelligence', 'Cybersecurity', 'Information Technology',
    'Electronics & Communication Engineering',
    // Sciences
    'Biology', 'Chemistry', 'Physics', 'Mathematics', 'Statistics',
    'Environmental Science', 'Biotechnology', 'Microbiology', 'Biochemistry',
    // Medicine & Health
    'Medicine (MBBS)', 'Nursing', 'Pharmacy', 'Dentistry',
    'Public Health', 'Physiotherapy', 'Psychology',
    // Arts & Humanities
    'English Literature', 'History', 'Philosophy', 'Sociology',
    'Political Science', 'Media & Communications', 'Journalism',
    'Fine Arts', 'Music', 'Film Studies',
    // Law
    'Law (LLB)', 'International Law', 'Corporate Law',
    // Design & Architecture
    'Architecture', 'Interior Design', 'Fashion Design', 'Graphic Design',
    // Hospitality & Tourism
    'Hotel Management', 'Tourism Management', 'Event Management',
    // Education
    'Education (B.Ed)', 'Early Childhood Education',
    // Other
    'Other',
  ];

  final _searchCtrl = TextEditingController();
  List<String> _filtered = _allCourses;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _filter(String q) {
    setState(() {
      _filtered = q.isEmpty
          ? _allCourses
          : _allCourses
                .where((c) => c.toLowerCase().contains(q.toLowerCase()))
                .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Studied Major',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _filter,
              decoration: InputDecoration(
                hintText: 'Search course or subject…',
                hintStyle: GoogleFonts.poppins(fontSize: 14, color: _textGrey),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchCtrl.clear();
                          _filter('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: _red, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              itemCount: _filtered.length,
              itemBuilder: (context, i) {
                final course = _filtered[i];
                final query = _searchCtrl.text.toLowerCase();
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 4,
                  ),
                  title: _highlightMatch(course, query),
                  onTap: () {
                    widget.onSelect(course);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _highlightMatch(String text, String query) {
    if (query.isEmpty || !text.toLowerCase().contains(query)) {
      return Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _textDark,
        ),
      );
    }
    final start = text.toLowerCase().indexOf(query);
    final end = start + query.length;
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text.substring(0, start),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textDark,
            ),
          ),
          TextSpan(
            text: text.substring(start, end),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: _red,
            ),
          ),
          TextSpan(
            text: text.substring(end),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textDark,
            ),
          ),
        ],
      ),
    );
  }
}
