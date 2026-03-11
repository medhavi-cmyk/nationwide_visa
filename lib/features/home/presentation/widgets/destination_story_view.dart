import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class DestinationStoryView extends StatefulWidget {
  final String name;
  final String image;
  final VoidCallback? onComplete;

  const DestinationStoryView({
    super.key,
    required this.name,
    required this.image,
    this.onComplete,
  });

  @override
  State<DestinationStoryView> createState() => _DestinationStoryViewState();
}

class _DestinationStoryViewState extends State<DestinationStoryView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentSegmentIndex = 0;
  final int _totalSegments = 7;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        if (_currentSegmentIndex < _totalSegments - 1) {
          setState(() {
            _currentSegmentIndex++;
            _controller.reset();
            _controller.forward();
          });
        } else {
          Navigator.maybePop(context);
        }
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextSegment() {
    if (_currentSegmentIndex < _totalSegments - 1) {
      setState(() {
        _currentSegmentIndex++;
        _controller.reset();
        _controller.forward();
      });
    } else {
      widget.onComplete?.call();
      Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _nextSegment,
        child: Stack(
          children: [
            // Background Image with Gradient Overlay
            Positioned.fill(
              child: Image.asset(
                widget.image,
                fit: BoxFit.cover,
              ),
            ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    AppColors.primaryRed.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Bars (7 Segments)
                  Row(
                    children: List.generate(_totalSegments, (index) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                double progress = 0.0;
                                if (index < _currentSegmentIndex) {
                                  progress = 1.0;
                                } else if (index == _currentSegmentIndex) {
                                  progress = _controller.value;
                                }

                                return LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                                  minHeight: 3,
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Header (Mini Circle + Title + Close)
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          image: DecorationImage(
                            image: AssetImage(widget.image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          widget.onComplete?.call();
                          Navigator.maybePop(context);
                        },
                      ),
                    ],
                  ),

                  const Spacer(flex: 1),

                  // Marketing Headline
                  Text(
                    "A sneak peek\ninto the ${widget.name}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "High value. Global degree.",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 18,
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Stats Section
                  _buildStatItem("Employability rate", "75%"),
                  const SizedBox(height: 24),
                  _buildStatItem("International students", "758K"),
                  const SizedBox(height: 24),
                  _buildStatItem("Intakes", "Jan | May | Sep"),

                  const Spacer(flex: 2),

                  // Footer Image (Landscape thumbnail like in reference)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        widget.image,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFFFEB3B), // Yellowish highlight for titles
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
