import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class DestinationPickerView extends StatelessWidget {
  final Function(String) onSelect;

  const DestinationPickerView({super.key, required this.onSelect});

  static void show(BuildContext context, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DestinationPickerView(onSelect: onSelect),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final List<Map<String, String>> destinations = [
      {"name": "Canada", "flag": "ca"},
      {"name": "Australia", "flag": "au"},
      {"name": "UK", "flag": "gb"},
      {"name": "USA", "flag": "us"},
      {"name": "Germany", "flag": "de"},
      {"name": "Other", "flag": ""},
    ];

    return Container(
      height: screenHeight * 0.6,
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
            "Where do you wish to go?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
              ),
              itemCount: destinations.length,
              itemBuilder: (context, index) {
                final dest = destinations[index];
                return GestureDetector(
                  onTap: () {
                    onSelect(dest['name']!);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (dest['flag']!.isNotEmpty) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Image.network(
                              "https://flagcdn.com/w40/${dest['flag']}.png",
                              width: 24,
                              height: 16,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          dest['name']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
