import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class PopularDestinations extends StatelessWidget {
  const PopularDestinations({super.key});

  @override
  Widget build(BuildContext context) {
    final destinations = [
      {'name': 'Canada', 'image': 'assets/logo.png'}, // Replace with actual images if available
      {'name': 'Australia', 'image': 'assets/logo.png'},
      {'name': 'Germany', 'image': 'assets/logo.png'},
      {'name': 'UK', 'image': 'assets/logo.png'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Icon(Icons.public, color: AppColors.textGrey, size: 20),
              SizedBox(width: 8),
              Text(
                "Popular Destinations",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: destinations.length,
            separatorBuilder: (context, index) => const SizedBox(width: 20),
            itemBuilder: (context, index) {
              final dest = destinations[index];
              return Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryRed.withValues(alpha: 0.1),
                        width: 4,
                      ),
                      image: const DecorationImage(
                        image: AssetImage('assets/logo.png'), // Using logo as fallback
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dest['name']!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
