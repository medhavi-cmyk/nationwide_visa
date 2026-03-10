import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';
import '../view_model/register_view_model.dart';

class RegisterBottomSheet extends StatefulWidget {
  final String email;

  const RegisterBottomSheet({super.key, required this.email});

  static void show(BuildContext context, String email) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
  final _formKey = GlobalKey<FormState>();
  final _viewModel = RegisterViewModel();

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
        return Container(
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
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  // padding: const EdgeInsets.symmetric(horizontal: 24),
                  padding: EdgeInsets.only(
                    left: 24.0,
                    right: 24.0,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 10.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          "Choose from best country to work /n study abroad",
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
                          readOnly: true,
                          onTap: () => _showCountryPicker(context),
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          context: context,
                          label: "City you live in",
                          controller: _viewModel.cityController,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          context: context,
                          label: "Nationality",
                          controller: _viewModel.nationalityController,
                        ),
                        const SizedBox(height: 16),

                        // Phone Number Field
                        TextFormField(
                          controller: _viewModel.phoneController,
                          decoration: _inputDecoration(context, "Phone number")
                              .copyWith(
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    right: 12,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(2),
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
                          label: "Where do you wish to study?",
                          controller: _viewModel.studyCountryController,
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextFormField(
                          controller: _viewModel.passwordController,
                          obscureText: _viewModel.obscurePassword,
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
                                "I'd like to receive Edvoy's marketing updates",
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
                              if (_formKey.currentState!.validate()) {
                                // Proceed
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
        );
      },
    );
  }

  void _showCountryPicker(BuildContext context) {
    _SelectCountryBottomSheet.show(context, (country) {
      setState(() {
        _viewModel.updateCountry(country);
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
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: _inputDecoration(context, label),
          validator: validator,
          readOnly: readOnly,
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
      filled: true,
      fillColor: Colors.grey[50],
    );
  }
}

class _SelectCountryBottomSheet extends StatefulWidget {
  final Function(String) onSelect;

  const _SelectCountryBottomSheet({required this.onSelect});

  static void show(BuildContext context, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SelectCountryBottomSheet(onSelect: onSelect),
    );
  }

  @override
  State<_SelectCountryBottomSheet> createState() =>
      _SelectCountryBottomSheetState();
}

class _SelectCountryBottomSheetState extends State<_SelectCountryBottomSheet> {
  final List<String> _allCountries = [
    "India",
    "Bangladesh",
    "Pakistan",
    "Egypt",
    "Nepal",
    "Saudi Arabia",
    "Qatar",
    "United Arab Emirates",
  ];
  List<String> _filteredCountries = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCountries = _allCountries;
  }

  void _filterCountries(String query) {
    setState(() {
      _filteredCountries = _allCountries
          .where(
            (country) => country.toLowerCase().contains(query.toLowerCase()),
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
          const Text(
            "Select Country",
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
              onChanged: _filterCountries,
              decoration: InputDecoration(
                hintText: "Country",
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
                    _filteredCountries[index],
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
