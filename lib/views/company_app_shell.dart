import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../components/company/company_drawer.dart';
import '../components/navigation/bottom_nav_bar.dart'; // We can adapt or create a specific one
import '../view/company_dashboard_screen.dart'; // For the Drawer
import '../viewmodel/screen_state_provider.dart';

class CompanyAppShell extends ConsumerWidget {
  final Widget child;
  const CompanyAppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryBlue = const Color(0xFF1565C0);
    final location = GoRouterState.of(context).matchedLocation;

    // Map location to index for BottomNav
    int currentIndex = 0;
    if (location.contains('internships') || location.contains('post')) currentIndex = 1;
    else if (location.contains('messages') || location.contains('chat')) currentIndex = 2;
    else if (location.contains('profile')) currentIndex = 3;

    return Scaffold(
      drawer: const CompanyDrawer(),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.black38,
        onTap: (index) {
          switch (index) {
            case 0: context.go('/company-dashboard'); break;
            case 1: context.go('/manage-internships'); break;
            case 2: context.go('/messages'); break;
            case 3: context.go('/company-profile'); break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.work_rounded), label: 'Internships'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.business_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

