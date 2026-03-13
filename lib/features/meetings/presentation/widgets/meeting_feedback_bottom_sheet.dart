import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class MeetingFeedbackBottomSheet extends StatefulWidget {
  const MeetingFeedbackBottomSheet({super.key});

  @override
  State<MeetingFeedbackBottomSheet> createState() => _MeetingFeedbackBottomSheetState();
}

class _MeetingFeedbackBottomSheetState extends State<MeetingFeedbackBottomSheet> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: 24 + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            "How would you rate the meeting?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "1 Star - Needs improvement, 5 Star - It was helpful",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textGrey,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          // Star Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              final isSelected = starIndex <= _rating;
              return GestureDetector(
                onTap: () => setState(() => _rating = starIndex),
                child: Icon(
                  isSelected ? Icons.star : Icons.star_outline,
                  size: 40,
                  color: isSelected ? AppColors.primaryRed : Colors.grey.withValues(alpha: 0.4),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
          // Comment Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderGrey),
            ),
            child: TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Anything else you want to share?",
                hintStyle: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 16,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Send Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // Return data or just close for now
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Thank you for your feedback!"),
                    backgroundColor: AppColors.primaryRed,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Send",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
