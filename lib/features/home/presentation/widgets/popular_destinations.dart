import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';
import 'destination_story_view.dart';

class PopularDestinations extends StatefulWidget {
  const PopularDestinations({super.key});

  @override
  State<PopularDestinations> createState() => _PopularDestinationsState();
}

class _PopularDestinationsState extends State<PopularDestinations> {
  // Track viewed destinations by name
  final Set<String> _viewedDestinations = {};

  final destinations = [
    {
      'name': 'Canada',
      'image': 'assets/popular_destination/canada_img.jpg',
    },
    {
      'name': 'Australia',
      'image': 'assets/popular_destination/australia_img.jpg',
    },
    {
      'name': 'Germany',
      'image': 'assets/popular_destination/germany_img.jpg',
    },
    {
      'name': 'UK',
      'image': 'assets/popular_destination/uk_img.jpg',
    },
  ];

  void _openStory(String name, String image) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DestinationStoryView(
          name: name,
          image: image,
          onComplete: () {
            if (mounted) {
              setState(() {
                _viewedDestinations.add(name);
              });
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          height: 140, // Increased to provide room for border and text
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: destinations.length,
            separatorBuilder: (context, index) => const SizedBox(width: 20),
            itemBuilder: (context, index) {
              final dest = destinations[index];
              final String name = dest['name']!;
              final String image = dest['image']!;
              final bool isViewed = _viewedDestinations.contains(name);

              return GestureDetector(
                onTap: () => _openStory(name, image),
                child: Column(
                  children: [
                    CustomPaint(
                      painter: SegmentedCirclePainter(
                        color: isViewed
                            ? Colors.grey[400]!
                            : AppColors.primaryRed,
                        segments: 7,
                        strokeWidth: 3.0,
                      ),
                      child: Container(
                        width: 90,
                        height: 90,
                        padding: const EdgeInsets.all(5),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage(image),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SegmentedCirclePainter extends CustomPainter {
  final Color color;
  final int segments;
  final double strokeWidth;

  SegmentedCirclePainter({
    required this.color,
    this.segments = 7,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Adjust radius to account for stroke width and prevent clipping
    final double radius = min(size.width / 2, size.height / 2) - (strokeWidth / 2);
    final Offset center = Offset(size.width / 2, size.height / 2);

    final double totalGap = 0.15; // Reduced from 0.5 for closer dashes
    final double segmentAngle = (2 * pi - (segments * totalGap)) / segments;

    for (int i = 0; i < segments; i++) {
      final double startAngle = i * (segmentAngle + totalGap) - (pi / 2);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
