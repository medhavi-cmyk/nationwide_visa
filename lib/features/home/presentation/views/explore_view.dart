import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import '../widgets/services_carousel.dart';
import '../widgets/popular_destinations.dart';
import '../widgets/trending_services.dart';
import '../widgets/trending_subjects.dart';
import '../widgets/whats_new.dart';
import '../widgets/referral_banner.dart';

class ExploreView extends StatelessWidget {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: StickySearchHeaderDelegate(
            statusBarHeight: MediaQuery.of(context).padding.top,
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: const [
              SizedBox(height: 24),
              ServicesCarousel(),
              SizedBox(height: 32),
              PopularDestinations(),
              SizedBox(height: 32),
              TrendingServices(),
              SizedBox(height: 40),
              TrendingSubjects(),
              SizedBox(height: 40),
              WhatsNew(),
              SizedBox(height: 40),
              ReferralBanner(),
              SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }
}
