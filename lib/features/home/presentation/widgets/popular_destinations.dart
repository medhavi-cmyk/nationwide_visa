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
  // Track progress by destination name (how many segments viewed)
  final Map<String, int> _destinationProgress = {};

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

  // Detailed story content organized by country (exactly 7 slides each)
  final Map<String, List<StorySlide>> countryStories = {
    'UK': [
      const StorySlide(
        title: "A sneak peek\ninto the UK",
        subtitle: "High value. Global degree.",
        stats: {
          "Employability rate": "75%",
          "International students": "758K",
          "Intakes": "Jan | May | Sep",
        },
      ),
      const StorySlide(
        title: "5 reasons why you\nshould choose the\nUK",
      ),
      const StorySlide(
        title: "Money matters",
        stats: {
          "Cost of studies:": "GBP 11,400 - 38,000 (UG)\nGBP 9000 - 30,000 (PG)",
          "Scholarships?": "YES! Exciting options available!",
          "Cost of living": "GBP 1400 - 2200/month",
        },
      ),
      const StorySlide(
        title: "Work while\nyou study",
        stats: {
          "Min. wage:": "GBP 10-12/hour",
          "Max. hours": "20 hours/week",
        },
      ),
      const StorySlide(
        title: "Stay-back\noptions: Say\nhello to the\nGraduate visa",
        stats: {
          "Validity": "• 2 years for graduates\n• 3 years for doctoral graduates",
        },
      ),
      const StorySlide(
        title: "Top Universities",
        subtitle: "Home to Oxford, Cambridge & more.",
        stats: {
          "Global Ranking": "Top 1% includes 20+ UK unis",
          "Research Impact": "World-leading excellence",
        },
      ),
      const StorySlide(
        title: "Ready to Apply?",
        subtitle: "Your journey starts here.",
        stats: {
          "Support": "Complete Visa Guidance",
          "Counseling": "Free Expert Sessions",
        },
      ),
    ],
    'Canada': [
      const StorySlide(
        title: "Discover\nCanada",
        subtitle: "Nature. Education. Future.",
        stats: {
          "PR Prospects": "Very High",
          "Education Quality": "Top Ranked",
          "Work Permit": "Up to 3 years",
        },
      ),
      const StorySlide(
        title: "Why Canada?",
        subtitle: "Safe, welcoming, and boundless opportunities.",
      ),
      const StorySlide(
        title: "Education Hub",
        stats: {
          "Intakes": "Fall | Winter | Summer",
          "Language": "English & French",
          "Cost of Living": "CAD 1500 - 2000/month",
        },
      ),
      const StorySlide(
        title: "Work & Life",
        subtitle: "Balance your studies with part-time work.",
        stats: {
          "Hours": "20 hrs/week (Off-campus)",
          "Vacation": "Full-time work allowed",
        },
      ),
      const StorySlide(
        title: "Post-Graduation",
        subtitle: "Transition to permanent residency.",
        stats: {
          "PGWP": "Post-Grad Work Permit",
          "Experience": "Canadian Work Experience",
        },
      ),
      const StorySlide(
        title: "Student Life",
        subtitle: "Multicultural and vibrant campus life.",
      ),
      const StorySlide(
        title: "Get Started",
        subtitle: "Apply for your Study Permit today.",
      ),
    ],
    'Australia': [
      const StorySlide(
        title: "Your Australian\nDream",
        subtitle: "Adventure and world-class studies.",
        stats: {
          "Weather": "Warm & Sunny",
          "Post-study work": "Up to 4 years",
          "Lifestyle": "High quality",
        },
      ),
      const StorySlide(title: "Top Cities", subtitle: "Melbourne, Sydney & Brisbane."),
      const StorySlide(
        title: "Quality Education",
        stats: {
          "Unis": "Group of Eight Excellence",
          "Research": "Innovation focus",
        },
      ),
      const StorySlide(title: "Part-time Work", stats: {"Limit": "48 hours per fortnight"}),
      const StorySlide(title: "Vibrant Culture", subtitle: "Unique wildlife and landscapes."),
      const StorySlide(title: "Scholarships", subtitle: "Government & Uni funded options."),
      const StorySlide(title: "Plan Your Visit", subtitle: "Consult our experts now."),
    ],
    'Germany': [
      const StorySlide(
        title: "Study Free in\nGermany",
        subtitle: "Excellence in Engineering & Arts.",
        stats: {
          "Tuition": "€0 at Public Unis",
          "Job seeker visa": "18 months",
          "Part-time work": "120 full days/year",
        },
      ),
      const StorySlide(title: "Why Germany?", subtitle: "Economic powerhouse of Europe."),
      const StorySlide(
        title: "Language",
        stats: {
          "Courses": "English & German tracks",
          "Benefit": "Learn a global language",
        },
      ),
      const StorySlide(title: "Innovation Hub", subtitle: "Home to BMW, SAP, and Siemens."),
      const StorySlide(title: "Travel Europe", subtitle: "Heart of the Schengen Area."),
      const StorySlide(title: "Living Costs", stats: {"Blocked Account": "€11,208 per year"}),
      const StorySlide(title: "Your Future", subtitle: "Start your German career today."),
    ],
  };

  void _openStory(String name, String icon) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DestinationStoryView(
          name: name,
          countryIcon: icon,
          slides: countryStories[name] ?? 
            [StorySlide(title: "Exploring $name", subtitle: "Coming soon!")],
          onProgress: (viewedSegments) {
            if (mounted) {
              setState(() {
                final current = _destinationProgress[name] ?? 0;
                if (viewedSegments > current) {
                  _destinationProgress[name] = viewedSegments;
                }
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
              final int viewedCount = _destinationProgress[name] ?? 0;
              final int totalSlides = countryStories[name]?.length ?? 1;

              return GestureDetector(
                onTap: () => _openStory(name, image),
                child: Column(
                  children: [
                    CustomPaint(
                      painter: SegmentedCirclePainter(
                        viewedSegments: viewedCount,
                        viewedColor: Colors.grey[400]!,
                        unviewedColor: AppColors.primaryRed,
                        totalSegments: totalSlides,
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
  final int viewedSegments;
  final Color viewedColor;
  final Color unviewedColor;
  final int totalSegments;
  final double strokeWidth;

  SegmentedCirclePainter({
    required this.viewedSegments,
    required this.viewedColor,
    required this.unviewedColor,
    this.totalSegments = 7,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Adjust radius to account for stroke width and prevent clipping
    final double radius =
        min(size.width / 2, size.height / 2) - (strokeWidth / 2);
    final Offset center = Offset(size.width / 2, size.height / 2);

    final double totalGap = 0.15;
    final double segmentAngle = (2 * pi - (totalSegments * totalGap)) / totalSegments;

    for (int i = 0; i < totalSegments; i++) {
      final Paint paint = Paint()
        ..color = i < viewedSegments ? viewedColor : unviewedColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

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
  bool shouldRepaint(covariant SegmentedCirclePainter oldDelegate) {
    return oldDelegate.viewedSegments != viewedSegments ||
        oldDelegate.viewedColor != viewedColor ||
        oldDelegate.unviewedColor != unviewedColor ||
        oldDelegate.totalSegments != totalSegments ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
