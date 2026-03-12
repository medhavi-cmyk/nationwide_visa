import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';
import 'upcoming_meetings_view.dart';
import 'history_meetings_view.dart';

class MeetingsView extends StatefulWidget {
  const MeetingsView({super.key});

  @override
  State<MeetingsView> createState() => _MeetingsViewState();
}

class _MeetingsViewState extends State<MeetingsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Meetings',
          style: TextStyle(
            color: AppColors.textBlack,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                dividerColor: Colors.transparent,
                indicatorColor: Colors.transparent,
                unselectedLabelColor: AppColors.textGrey,
                labelColor: Colors.white,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                tabs: [
                  _buildTab('Upcoming', 0),
                  _buildTab('History', 1),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          UpcomingMeetingsView(),
          HistoryMeetingsView(),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        final isSelected = _tabController.index == index;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryRed : AppColors.primaryRed.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Tab(
            height: 32,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }
}
