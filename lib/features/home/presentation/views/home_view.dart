import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';
import 'explore_view.dart';
import '../../../chat/presentation/views/chat_view.dart';
import '../../../meetings/presentation/views/meetings_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ExploreView(),
    const ChatView(),
    const MeetingsView(),
    const Center(child: Text('Applications - Coming Soon')),
    const Center(child: Text('Profile - Coming Soon')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedItemColor: AppColors.primaryRed,
          unselectedItemColor: Colors.grey[400],
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.videocam_outlined),
              label: 'Meet',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.description_outlined),
            //   label: 'Applications',
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
