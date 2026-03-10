import 'package:flutter/material.dart';
import 'dart:io';
import '../../../../core/app_colors.dart';
import '../view_model/register_view_model.dart';
import 'otp_verification_sheet.dart';

class RegisterBottomSheet extends StatefulWidget {
  final String email;

  const RegisterBottomSheet({super.key, required this.email});

  static void show(BuildContext context, String email) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return RegisterBottomSheet(email: email);
      },
    );
  }

  @override
  State<RegisterBottomSheet> createState() => _RegisterBottomSheetState();
}

class _RegisterBottomSheetState extends State<RegisterBottomSheet> {
  final _viewModel = RegisterViewModel();

  @override
  void initState() {
    super.initState();
    debugPrint("--- RegisterBottomSheet State Initialized ---");
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return DraggableScrollableSheet(
      initialChildSize: screenHeight < 600 ? 0.95 : 0.92,
      minChildSize: 0.5,
      maxChildSize: screenHeight < 600 ? 0.95 : 0.92,
      expand: false,
      builder: (context, scrollController) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            _showExitConfirmation(context);
          },
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onVerticalDragEnd: (details) {
                    if (details.primaryVelocity! > 50) {
                      _showExitConfirmation(context);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.only(
                      left: 24.0,
                      right: 24.0,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 10.0,
                    ),
                    child: Form(
                      key: _viewModel.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            "Choose from best country to work or study abroad",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenWidth < 350 ? 24 : 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textBlack,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Let's make it happen.",
                            style: TextStyle(
                              fontSize: screenWidth < 350 ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textBlack,
                            ),
                          ),
                          const SizedBox(height: 32),

                          _buildField(
                            context: context,
                            label: "Full name",
                            hint: "As per your passport or ID proof",
                            controller: _viewModel.nameController,
                            validator: _viewModel.validateFullName,
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            context: context,
                            label: "Country you live in",
                            controller: _viewModel.countryController,
                            validator: _viewModel.validateCountry,
                            readOnly: true,
                            onTap: () => _showCountryPicker(context),
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            context: context,
                            label: "City you live in",
                            controller: _viewModel.cityController,
                            validator: _viewModel.validateCity,
                            readOnly: true,
                            enabled: _viewModel.isCountrySelected,
                            onTap: _viewModel.isCountrySelected
                                ? () => _showCityPicker(context)
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            context: context,
                            label: "Nationality",
                            controller: _viewModel.nationalityController,
                            validator: _viewModel.validateNationality,
                            readOnly: true,
                            onTap: () => _showNationalityPicker(context),
                          ),
                          const SizedBox(height: 16),

                          // Phone Number Field
                          TextFormField(
                            controller: _viewModel.phoneController,
                            validator: _viewModel.validatePhone,
                            decoration:
                                _inputDecoration(
                                  context,
                                  "Phone number",
                                ).copyWith(
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                      right: 12,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                          child: Image.network(
                                            "https://flagcdn.com/w40/in.png",
                                            width: 24,
                                            height: 16,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                                      Icons.flag_outlined,
                                                      size: 20,
                                                    ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          "+91",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          ),

                          const SizedBox(height: 16),
                          _buildField(
                            context: context,
                            label: "Where do you wish to go?",
                            controller: _viewModel.studyCountryController,
                            validator: _viewModel.validateStudyCountry,
                            readOnly: true,
                            onTap: () => _showStudyCountryPicker(context),
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            controller: _viewModel.passwordController,
                            obscureText: _viewModel.obscurePassword,
                            validator: _viewModel.validatePassword,
                            decoration:
                                _inputDecoration(
                                  context,
                                  "Set your password",
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _viewModel.obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.grey[400],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _viewModel.togglePasswordVisibility();
                                      });
                                    },
                                  ),
                                ),
                          ),

                          const SizedBox(height: 24),

                          // Marketing Checkbox
                          Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: _viewModel.receiveUpdates,
                                  onChanged: (val) {
                                    setState(() {
                                      _viewModel.toggleReceiveUpdates(val);
                                    });
                                  },
                                  activeColor: AppColors.primaryRed,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  "I'd like to receive NationwideVisas marketing Updates ",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Continue Button
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.primaryRed,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryRed.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_viewModel.validateForm()) {
                                  OtpVerificationSheet.show(
                                    context,
                                    "+91${_viewModel.phoneController.text}",
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                "Continue",
                                style: TextStyle(
                                  fontSize: screenWidth < 350 ? 16 : 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showExitConfirmation(BuildContext context) {
    _RegistrationExitConfirmationSheet.show(
      context,
      () {
        // Continue -> Keep open (do nothing special, modal popped naturally)
      },
      () {
        // Not now -> Close everything
        Navigator.of(context).pop(); // Close register sheet
      },
    );
  }

  void _showCountryPicker(BuildContext context) async {
    debugPrint("--- Showing Country Picker ---");
    final countries = await _viewModel.getAllCountries();
    if (!mounted) return;
    _SelectCountryBottomSheet.show(context, countries, (country) {
      setState(() {
        _viewModel.updateCountry(country);
      });
    });
  }

  void _showNationalityPicker(BuildContext context) async {
    debugPrint("--- Showing Nationality Picker ---");
    final countries = await _viewModel.getAllCountries();
    if (!mounted) return;
    _SelectCountryBottomSheet.show(
      context,
      countries,
      (country) {
        setState(() {
          _viewModel.updateNationality(country);
        });
      },
      title: "Select Nationality",
      hint: "Nationality",
    );
  }

  void _showStudyCountryPicker(BuildContext context) async {
    debugPrint("--- Showing Destination Picker ---");
    _DestinationBottomSheet.show(context, (country) {
      setState(() {
        _viewModel.studyCountryController.text = country;
      });
    });
  }

  void _showCityPicker(BuildContext context) async {
    final cities = await _viewModel.getCitiesForSelectedCountry();
    if (!mounted) return;
    _SelectCityBottomSheet.show(context, cities, (city) {
      setState(() {
        _viewModel.cityController.text = city;
      });
    });
  }

  Widget _buildField({
    required BuildContext context,
    required String label,
    String? hint,
    TextEditingController? controller,
    String? Function(String?)? validator,
    bool readOnly = false,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: _inputDecoration(
            context,
            label,
          ).copyWith(fillColor: enabled ? Colors.grey[50] : Colors.grey[100]),
          validator: validator,
          readOnly: readOnly,
          enabled: enabled,
          onTap: onTap,
        ),
        if (hint != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              hint,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.grey[400],
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      errorMaxLines: 3,
      errorStyle: const TextStyle(fontSize: 12, height: 1.2),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }
}

class _SelectCountryBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> countries;
  final Function(Map<String, dynamic>) onSelect;
  final String title;
  final String hint;

  const _SelectCountryBottomSheet({
    required this.countries,
    required this.onSelect,
    this.title = "Select Country",
    this.hint = "Country",
  });

  static void show(
    BuildContext context,
    List<Map<String, dynamic>> countries,
    Function(Map<String, dynamic>) onSelect, {
    String title = "Select Country",
    String hint = "Country",
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SelectCountryBottomSheet(
        countries: countries,
        onSelect: onSelect,
        title: title,
        hint: hint,
      ),
    );
  }

  @override
  State<_SelectCountryBottomSheet> createState() =>
      _SelectCountryBottomSheetState();
}

class _SelectCountryBottomSheetState extends State<_SelectCountryBottomSheet> {
  List<Map<String, dynamic>> _filteredCountries = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCountries = widget.countries;
  }

  void _filterCountries(String query) {
    setState(() {
      _filteredCountries = widget.countries
          .where(
            (country) => (country['name'] ?? '')
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.8,
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
            widget.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _searchController,
              onChanged: _filterCountries,
              decoration: InputDecoration(
                hintText: widget.hint,
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
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
                  borderSide: const BorderSide(
                    color: AppColors.primaryRed,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _filteredCountries.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _filteredCountries[index]['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                    ),
                  ),
                  onTap: () {
                    widget.onSelect(_filteredCountries[index]);
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
}

class _SelectCityBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> cities;
  final Function(String) onSelect;

  const _SelectCityBottomSheet({required this.cities, required this.onSelect});

  static void show(
    BuildContext context,
    List<Map<String, dynamic>> cities,
    Function(String) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _SelectCityBottomSheet(cities: cities, onSelect: onSelect),
    );
  }

  @override
  State<_SelectCityBottomSheet> createState() => _SelectCityBottomSheetState();
}

class _SelectCityBottomSheetState extends State<_SelectCityBottomSheet> {
  List<Map<String, dynamic>> _filteredCities = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCities = widget.cities;
  }

  void _filterCities(String query) {
    debugPrint("--- Filtering Cities with query: '$query' ---");
    setState(() {
      _filteredCities = widget.cities.where((item) {
        final displayName = (item['displayName'] ?? item['name'] ?? '')
            .toString();
        final matches = displayName.toLowerCase().contains(query.toLowerCase());
        return matches;
      }).toList();
      debugPrint("--- Found ${_filteredCities.length} matches ---");
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.8,
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
          const Text(
            "Select City",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _searchController,
              onChanged: _filterCities,
              decoration: InputDecoration(
                hintText: "City",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          _filterCities("");
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
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
                  borderSide: const BorderSide(
                    color: AppColors.primaryRed,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: _filteredCities.length,
              itemBuilder: (context, index) {
                final city =
                    (_filteredCities[index]['displayName'] ??
                            _filteredCities[index]['name'] ??
                            '')
                        .toString();
                final query = _searchController.text.toLowerCase();

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  title: RichText(text: _highlightMatch(city, query)),
                  onTap: () {
                    widget.onSelect(city);
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

  TextSpan _highlightMatch(String text, String query) {
    if (query.isEmpty || !text.toLowerCase().contains(query)) {
      return TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.textBlack,
        ),
      );
    }

    final matches = query.toLowerCase().allMatches(text.toLowerCase());
    int lastMatchEnd = 0;
    List<TextSpan> children = [];

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        children.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      children.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      );
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      children.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return TextSpan(
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.textBlack,
      ),
      children: children,
    );
  }
}

class _DestinationBottomSheet extends StatelessWidget {
  final Function(String) onSelect;

  const _DestinationBottomSheet({required this.onSelect});

  static const List<Map<String, String>> _destinations = [
    {'name': 'United Kingdom', 'code': 'gb'},
    {'name': 'United States', 'code': 'us'},
    {'name': 'Canada', 'code': 'ca'},
    {'name': 'Australia', 'code': 'au'},
    {'name': 'Germany', 'code': 'de'},
    {'name': 'New Zealand', 'code': 'nz'},
    {'name': 'Ireland', 'code': 'ie'},
    {'name': 'Netherlands', 'code': 'nl'},
    {'name': 'France', 'code': 'fr'},
    {'name': 'Switzerland', 'code': 'ch'},
    {'name': 'Spain', 'code': 'es'},
    {'name': 'United Arab Emirates', 'code': 'ae'},
    {'name': 'Poland', 'code': 'pl'},
    {'name': 'Malta', 'code': 'mt'},
    {'name': 'Grenada', 'code': 'gd'},
    {'name': 'Cyprus', 'code': 'cy'},
    {'name': 'Hungary', 'code': 'hu'},
    {'name': 'Italy', 'code': 'it'},
    {'name': 'Malaysia', 'code': 'my'},
    {'name': 'Mauritius', 'code': 'mu'},
  ];

  static void show(BuildContext context, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DestinationBottomSheet(onSelect: onSelect),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Text(
              "Destination",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A1C1E),
                letterSpacing: -0.5,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Where do you wish to pursue your studies?",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1C1E),
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Wrap(
                spacing: 10,
                runSpacing: 12,
                children: _destinations.map((country) {
                  return GestureDetector(
                    onTap: () {
                      onSelect(country['name']!);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Image.network(
                              "https://flagcdn.com/w40/${country['code']}.png",
                              width: 20,
                              height: 14,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.flag_outlined, size: 14),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            country['name']!,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4A4D54),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegistrationExitConfirmationSheet extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onExit;

  const _RegistrationExitConfirmationSheet({
    required this.onContinue,
    required this.onExit,
  });

  static void show(
    BuildContext context,
    VoidCallback onContinue,
    VoidCallback onExit,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RegistrationExitConfirmationSheet(
        onContinue: onContinue,
        onExit: onExit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    "Wait, don't go yet!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth < 350 ? 24 : 28,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: screenHeight * 0.25,
                      maxWidth: screenWidth,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        "assets/exit_confirmation.jpg",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Your study-abroad dream is ours too. Sign up for free expert help, AI-powered course picks, and more",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onExit();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F4F6),
                      foregroundColor: const Color(0xFF4B5563),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Not now",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accentRed, AppColors.primaryRed],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onContinue();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Continue ->",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
        ],
      ),
    );
  }
}
