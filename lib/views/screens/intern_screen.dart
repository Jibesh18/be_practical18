import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_textstyles.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../tabs/intern_home_tab.dart';
import '../tabs/applications_tab.dart';
import '../tabs/resources_tab.dart';
import '../tabs/community_tab.dart';
import '../tabs/intern_suggestions.dart';

class InternScreen extends StatelessWidget {
  const InternScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<DashboardViewModel>(
      builder: (context, vm, _) {
        final List<Widget> pages = [
          const HomeTab(),
          const ApplicationsScreen(),
          const ResourcesTab(),
          const CommunityTab(),
          const InternAiSuggestionsTab(),
        ];

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
            body: IndexedStack(index: vm.currentIndex, children: pages),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
                selectedLabelStyle: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w700),
                unselectedLabelStyle: AppTextStyles.labelSmall,
                currentIndex: vm.currentIndex,
                onTap: vm.setIndex,
                items: const [
                  BottomNavigationBarItem(icon: Icon(Iconsax.home),          label: 'Home'),
                  BottomNavigationBarItem(icon: Icon(Iconsax.document),       label: 'Applied'),
                  BottomNavigationBarItem(icon: Icon(Iconsax.book),           label: 'Resources'),
                  BottomNavigationBarItem(icon: Icon(Iconsax.people),         label: 'Community'),
                  BottomNavigationBarItem(icon: Icon(Iconsax.magic_star),     label: 'AI picks'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}