import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../themes/app_colors.dart';
import '../../themes/app_textstyles.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../tabs/applications_tab.dart';
import '../tabs/community_tab.dart';
import '../tabs/intern_home_tab.dart';
import '../tabs/intern_search_tab.dart';
import '../tabs/profile_tab.dart';

// Palette matching splash screen
const _kLogoBlue = Color(0xFF1F4BAE);

class InternScreen extends StatelessWidget {
  const InternScreen({super.key});

  static const List<Widget> _pages = [
    InternHomeTab(),
    InternSearchTab(),
    ApplicationsScreen(),
    CommunityScreen(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            body: IndexedStack(
              index: viewModel.currentIndex,
              children: _pages,
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: _kLogoBlue,
                unselectedItemColor: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                selectedLabelStyle:
                AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w700),
                unselectedLabelStyle: AppTextStyles.labelSmall,
                currentIndex: viewModel.currentIndex,
                onTap: viewModel.setIndex,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.search_normal),
                    label: 'Search',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.document),
                    label: 'Applied',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.people),
                    label: 'Community',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.profile_circle),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}