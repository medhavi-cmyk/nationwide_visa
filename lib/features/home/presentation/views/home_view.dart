import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'explore_view.dart';
import '../../../chat/presentation/views/chat_view.dart';
import '../../../meetings/presentation/views/meetings_view.dart';
import '../../../profile/presentation/views/profile_view.dart';
import '../../../../core/widgets/platform/platform_scaffold.dart';
import '../../../../core/utils/platform_utils.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  static const Color _navRed = Color(0xFFC00A15);

  List<Widget> get _pages => [
        const ExploreView(),
        const ChatView(),
        const MeetingsView(),
        ProfileView(
          onNavigateToChat: () => setState(() => _selectedIndex = 1),
          onNavigateToMeet: () => setState(() => _selectedIndex = 2),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          activeColor: _navRed,
          inactiveColor: CupertinoColors.systemGrey,
          backgroundColor: CupertinoColors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.globe),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person_2),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.video_camera),
              label: 'Meet',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person),
              label: 'Profile',
            ),
          ],
        ),
        tabBuilder: (context, index) {
          return CupertinoPageScaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            child: _pages[index],
          );
        },
      );
    }

    return PlatformScaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
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
          selectedItemColor: _navRed,
          unselectedItemColor: Colors.grey[400],
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.language_outlined),
              activeIcon: Icon(Icons.language),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.headset_mic_outlined),
              activeIcon: Icon(Icons.headset_mic),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.videocam_outlined),
              activeIcon: Icon(Icons.videocam),
              label: 'Meet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
