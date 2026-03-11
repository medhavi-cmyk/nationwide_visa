import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class ServicesCarousel extends StatelessWidget {
  const ServicesCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      {
        'title': 'Study',
        'subtitle': '100% Scholarship Opportunities available',
        'icon': Icons.school_outlined,
        'color': const Color(0xFFE3F2FD),
      },
      {
        'title': 'Work',
        'subtitle': '1 Million+ Jobs Lying Vacant in Canada',
        'icon': Icons.work_outline,
        'color': const Color(0xFFF3E5F5),
      },
      {
        'title': 'Invest',
        'subtitle': 'Move to Canada in 90 Days',
        'icon': Icons.monetization_on_outlined,
        'color': const Color(0xFFE8F5E9),
      },
      {
        'title': 'Settle',
        'subtitle': 'Live, Work, and Study in Canada',
        'icon': Icons.home_outlined,
        'color': const Color(0xFFFFF3E0),
      },
    ];

    return SizedBox(
      height: 160,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final service = services[index];
          return Container(
            width: 280,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: service['color'] as Color,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        service['title'] as String,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        service['subtitle'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textGrey,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Apply now",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  service['icon'] as IconData,
                  size: 60,
                  color: AppColors.primaryRed.withValues(alpha: 0.2),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
