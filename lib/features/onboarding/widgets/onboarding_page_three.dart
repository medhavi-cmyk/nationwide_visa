import 'package:flutter/material.dart';

class OnboardingPageThree extends StatelessWidget {
  const OnboardingPageThree({super.key});

  @override
  Widget build(BuildContext context) {
    // Faded red color for image tinting to match the theme
    final Color tintColor = Colors.red[900]!.withValues(alpha: 0.6);

    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Staggered Image Collage Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column
                      Expanded(
                        child: Column(
                          children: [
                            _buildImage(
                              url: "https://www.shutterstock.com/shutterstock/photos/1564489651/display_1500/stock-photo-happy-indian-student-male-bearded-wearing-glasses-and-black-t-short-holding-passport-airline-ticket-1564489651.jpg",
                              height: 220,
                              isFaded: false,
                            ),
                            const SizedBox(height: 16),
                            _buildImage(
                              url: "https://www.shutterstock.com/shutterstock/photos/2205410909/display_1500/stock-photo-a-young-happy-asian-girl-with-a-german-flag-poses-at-the-media-harbor-and-tv-tower-in-dusseldorf-2205410909.jpg",
                              height: 140,
                              isFaded: true,
                              tintColor: tintColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Center Column
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            _buildImage(
                              url: "https://www.shutterstock.com/shutterstock/photos/2072876585/display_1500/stock-photo-multicultural-group-of-young-people-standing-in-circle-and-smiling-at-camera-happy-diverse-2072876585.jpg",
                              height: 130,
                              isFaded: false,
                            ),
                            const SizedBox(height: 14),
                            // 100K+ Text
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "100K+",
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        offset: const Offset(0, 4),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _buildImage(
                              url: "https://www.shutterstock.com/shutterstock/photos/2401451549/display_1500/stock-photo-beautiful-caucasian-woman-applying-for-an-american-visa-online-using-the-laptop-while-holding-a-us-2401451549.jpg",
                              height: 180,
                              isFaded: true,
                              tintColor: tintColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Right Column
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(height: 50),
                            _buildImage(
                              url: "https://www.shutterstock.com/shutterstock/photos/2690300141/display_1500/stock-photo-young-man-smiling-while-carrying-a-backpack-and-holding-a-passport-with-boarding-pass-represents-2690300141.jpg",
                              height: 200,
                              isFaded: false,
                            ),
                            const SizedBox(height: 16),
                            _buildImage(
                              url: "https://www.shutterstock.com/shutterstock/photos/1421390993/display_1500/stock-photo-group-of-students-with-canadian-flags-outdoors-1421390993.jpg",
                              height: 140,
                              isFaded: true,
                              tintColor: tintColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Content / Headline
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: const Text(
                  "Trusted by 100K+\nstudents across the\nglobe",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImage({
    required String url,
    required double height,
    required bool isFaded,
    Color? tintColor,
  }) {
    Widget imageContent = Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(30),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
        ),
      ),
    );

    if (isFaded) {
      return ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.1, 1.0],
            colors: [Colors.white, Colors.transparent],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: Stack(
          children: [
            imageContent,
            Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: tintColor,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ],
        ),
      );
    }

    return imageContent;
  }
}
