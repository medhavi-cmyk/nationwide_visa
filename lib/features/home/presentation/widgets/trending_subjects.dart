import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class TrendingSubjects extends StatelessWidget {
  const TrendingSubjects({super.key});

  @override
  Widget build(BuildContext context) {
    final subjects = [
      "Business",
      "Education",
      "Business Administration",
      "Computer Sciences",
      "Law",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Icon(Icons.book_outlined, color: AppColors.textGrey, size: 20),
              SizedBox(width: 8),
              Text(
                "Trending Subjects",
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: subjects.map((subject) => _buildSubjectChip(subject)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textBlack,
        ),
      ),
    );
  }
}
