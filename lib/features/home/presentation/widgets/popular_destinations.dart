import 'dart:math';
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
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
        title: "Immigrate to\nCanada",
        subtitle: "1 Million+ Jobs. High Success Rate.",
        stats: {
          "PR Prospects": "Excellent",
          "Express Entry": "Fast-Track PR",
          "PNP Options": "80+ Streams",
        },
      ),
      const StorySlide(
        title: "Why Canada PR?",
        subtitle: "Safe, booming economy, and free healthcare.",
      ),
      const StorySlide(
        title: "Express Entry",
        subtitle: "The fastest way to permanent residency.",
        stats: {
          "Latest Draw": "CEC | PNP | French",
          "Target 2025": "500,000 New PRs",
          "Processing Time": "6-8 Months",
        },
      ),
      const StorySlide(
        title: "Provincial Nominee\nPrograms (PNP)",
        subtitle: "Move to specific provinces like Ontario or Alberta.",
        stats: {
          "CRS Boost": "+600 Points",
          "Ontario PNP": "Tech & Healthcare focus",
        },
      ),
      const StorySlide(
        title: "Work & Settle",
        subtitle: "Bridge the labor gap in Canada's economy.",
        stats: {
          "Vacant Jobs": "1 Million+",
          "Language": "IELTS/PTE accepted",
        },
      ),
      const StorySlide(
        title: "Family First",
        subtitle: "Sponsor your spouse and children for PR.",
      ),
      const StorySlide(
        title: "Check Eligibility",
        subtitle: "See if you qualify in 60 seconds.",
      ),
    ],
    'Australia': [
      const StorySlide(
        title: "Your Australian\nPR Dream",
        subtitle: "Skilled migration and high quality of life.",
        stats: {
          "Subclass 189/190": "Most Popular",
          "Points System": "Age, Skill, English",
          "Job Market": "High demand for Tech",
        },
      ),
      const StorySlide(title: "Why Australia?", subtitle: "Great weather, high wages, and safety."),
      const StorySlide(
        title: "Points Calculator",
        stats: {
          "Min Points": "65 Points",
          "Target Score": "85+ Recommended",
        },
      ),
      const StorySlide(title: "Skill Assessment", subtitle: "Verify your skills with ACS/Engineers Australia."),
      const StorySlide(title: "Vibrant Culture", subtitle: "Unique landscapes and work-life balance."),
      const StorySlide(title: "Visa Options", subtitle: "PR, Work (482), and Regional (491)."),
      const StorySlide(title: "Consult Experts", subtitle: "Nationwide Visas: 17+ Years Exp."),
    ],
    'Germany': [
      const StorySlide(
        title: "German Opportunity\nCard",
        subtitle: "Work in Europe's strongest economy.",
        stats: {
          "Chancenkarte": "New Points System",
          "Job seeker visa": "18 months",
          "Tuition": "€0 at Public Unis",
        },
      ),
      const StorySlide(title: "Economic Power", subtitle: "Heart of European innovation."),
      const StorySlide(
        title: "No Language Barrier",
        stats: {
          "Tech Jobs": "English is widely spoken",
          "Study": "Many English-taught courses",
        },
      ),
      const StorySlide(title: "Engineering Hub", subtitle: "Home to BMW, Mercedes, and SAP."),
      const StorySlide(title: "Heart of Europe", subtitle: "Travel freely in the Schengen Area."),
      const StorySlide(title: "Easy PR", stats: {"Pathway": "Blue Card to PR in 21 months"}),
      const StorySlide(title: "Your Future", subtitle: "Start your German career today."),
    ],
  };

  void _openStory(String name, String icon) {
    final route = Platform.isIOS
        ? CupertinoPageRoute(
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
          )
        : MaterialPageRoute(
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
          );

    Navigator.of(context).push(route);
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
