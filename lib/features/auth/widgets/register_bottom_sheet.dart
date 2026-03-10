import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class RegisterBottomSheet extends StatefulWidget {
  final String email;

  const RegisterBottomSheet({
    super.key,
    required this.email,
  });

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
  bool _receiveUpdates = true;
  bool _obscurePassword = true;

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
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          "... the best university\nabroad!",
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
                          hint: "As per your passport or ID proof"
                        ),
                        const SizedBox(height: 16),
                        _buildField(context: context, label: "Country you live in"),
                        const SizedBox(height: 16),
                        _buildField(context: context, label: "City you live in"),
                        const SizedBox(height: 16),
                        _buildField(context: context, label: "Nationality"),
                        const SizedBox(height: 16),
                        
                        // Phone Number Field
                        TextFormField(
                          decoration: _inputDecoration(context, "Phone number").copyWith(
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 16, right: 12),
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
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.flag_outlined, size: 20),
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
                        _buildField(context: context, label: "Where do you wish to study?"),
                        const SizedBox(height: 16),
                        
                        // Password Field
                        TextFormField(
                          obscureText: _obscurePassword,
                          decoration: _inputDecoration(context, "Set your password").copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.grey[400],
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
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
                                value: _receiveUpdates,
                                onChanged: (val) {
                                  setState(() {
                                    _receiveUpdates = val ?? false;
                                  });
                                },
                                activeColor: const Color(0xFF6B4EE0),
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
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFF4B2BB8),
                                Color(0xFF9147E8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6B4EE0).withValues(alpha: 0.3),
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

  Widget _buildField({required BuildContext context, required String label, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration: _inputDecoration(context, label),
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
        borderSide: const BorderSide(color: Color(0xFF6B4EE0), width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }
}
