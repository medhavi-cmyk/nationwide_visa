import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class StickySearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double statusBarHeight;

  StickySearchHeaderDelegate({required this.statusBarHeight});

  @override
  double get minExtent => statusBarHeight + 86; // Status bar + Search Bar + Padding

  @override
  double get maxExtent => 180; // Reduced height

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double percent = shrinkOffset / maxExtent;
    // Calculation for fading out elements
    final double fadeOpacity = 1.0 - (percent * 3).clamp(0.0, 1.0);

    // Calculation for search bar position
    final double searchBarHeight = 56.0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE91E63), AppColors.primaryRed],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [
          // Logo and Notifications (Fade out)
          Positioned(
            top: statusBarHeight + 10,
            left: 24,
            right: 24,
            child: Opacity(
              opacity: fadeOpacity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Image.asset('assets/logo.png', height: 40),
                  const Text(
                    "NationWide Visas",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Bar (Sticky)
          Positioned(
            left: 24,
            right: 24,
            bottom: max(
              12, // Reduced from 20 to move it more down
              (maxExtent - shrinkOffset - searchBarHeight - statusBarHeight) /
                      4 + // Reduced denominator to push it down further when expanded
                  8,
            ),
            child: Container(
              height: searchBarHeight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[400], size: 24),
                  const SizedBox(width: 12),
                  Text(
                    "Find Visas and Programs",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant StickySearchHeaderDelegate oldDelegate) {
    return statusBarHeight != oldDelegate.statusBarHeight;
  }
}
