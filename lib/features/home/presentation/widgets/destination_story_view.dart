import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class StorySlide {
  final String title;
  final String? subtitle;
  final Map<String, String>? stats;
  final String? image; // Optional specific image for this slide

  const StorySlide({
    required this.title,
    this.subtitle,
    this.stats,
    this.image,
  });
}

class DestinationStoryView extends StatefulWidget {
  final String name;
  final String countryIcon;
  final List<StorySlide> slides;
  final void Function(int)? onProgress;

  const DestinationStoryView({
    super.key,
    required this.name,
    required this.countryIcon,
    required this.slides,
    this.onProgress,
  });

  @override
  State<DestinationStoryView> createState() => _DestinationStoryViewState();
}

class _DestinationStoryViewState extends State<DestinationStoryView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentSegmentIndex = 0;
  int get _totalSegments => widget.slides.length;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // 4 seconds per slide
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        if (_currentSegmentIndex < _totalSegments - 1) {
          setState(() {
            _currentSegmentIndex++;
            widget.onProgress?.call(_currentSegmentIndex);
            _controller.reset();
            _controller.forward();
          });
        } else {
          widget.onProgress?.call(_totalSegments);
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
        widget.onProgress?.call(_currentSegmentIndex);
        _controller.reset();
        _controller.forward();
      });
    } else {
      widget.onProgress?.call(_totalSegments);
      Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSlide = widget.slides[_currentSegmentIndex];

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          widget.onProgress?.call(_currentSegmentIndex + 1);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: _nextSegment,
          child: Stack(
            children: [
              // Background Image with Gradient Overlay
              Positioned.fill(
                child: Image.asset(
                  currentSlide.image ?? widget.countryIcon,
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
                      // Progress Bars
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
                                      backgroundColor:
                                          Colors.white.withValues(alpha: 0.3),
                                      valueColor:
                                          const AlwaysStoppedAnimation(Colors.white),
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

                      // Header
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              image: DecorationImage(
                                image: AssetImage(widget.countryIcon),
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
                              widget.onProgress?.call(_currentSegmentIndex + 1);
                              Navigator.maybePop(context);
                            },
                          ),
                        ],
                      ),

                      const Spacer(flex: 1),

                      // Dynamic Headline
                      Text(
                        currentSlide.title,
                        style: TextStyle(
                          color: currentSlide.stats != null ? Colors.white : const Color(0xFFFFEB3B),
                          fontSize: currentSlide.stats != null ? 40 : 36,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      if (currentSlide.subtitle != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          currentSlide.subtitle!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 18,
                          ),
                        ),
                      ],

                      const Spacer(flex: 1),

                      // Dynamic Stats Section
                      if (currentSlide.stats != null)
                        ...currentSlide.stats!.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: _buildStatItem(entry.key, entry.value),
                          );
                        }),

                      const Spacer(flex: 2),

                      // Footer Image fallback
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            widget.countryIcon,
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
            color: Color(0xFFFFEB3B),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
