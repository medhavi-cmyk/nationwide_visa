import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

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
                              assetPath: "assets/image_sir.png",
                              height: 220,
                              isFaded: false,
                            ),
                            const SizedBox(height: 16),
                            _buildImage(
                              assetPath: "assets/image_2.webp",
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
                              assetPath: "assets/mahima_ghalaut.jpg",
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
                              assetPath: "assets/ramandeep.jpg",
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
                              assetPath: "assets/dsc00113.jpg",
                              height: 200,
                              isFaded: false,
                            ),
                            const SizedBox(height: 16),
                            _buildImage(
                              assetPath: "assets/dsc00423.jpg",
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
              const SizedBox(height: 160),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImage({
    required String assetPath,
    required double height,
    required bool isFaded,
    Color? tintColor,
  }) {
    Widget imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Image.asset(
        assetPath,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: height,
              width: double.infinity,
              color: Colors.white,
            ),
          );
        },
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
            imageWidget,
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

    return imageWidget;
  }
}
