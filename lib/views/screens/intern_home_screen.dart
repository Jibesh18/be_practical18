import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';
import '../tabs/ai_agent_tab.dart';
import '../tabs/intern_home_tab.dart';
import '../tabs/intern_search_tab.dart';
import '../tabs/profile_tab.dart';
import '../tabs/resources_tab.dart';

class InternHomeScreen extends StatefulWidget {
  const InternHomeScreen({super.key});

  @override
  State<InternHomeScreen> createState() => _InternHomeScreenState();
}

class _InternHomeScreenState extends State<InternHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    InternHomeTab(),
    InternSearchTab(),
    AIAgentTab(),
    ResourcesTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : Colors.white,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy_rounded),
            label: 'AI Agent',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Resources',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}