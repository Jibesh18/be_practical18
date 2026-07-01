import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../viewmodels/internship_viewmodel.dart';
import '../tabs/intern_home_tab.dart';
import '../tabs/intern_search_tab.dart';
import '../tabs/ai_agent_tab.dart';
import '../tabs/resources_tab.dart';
import '../tabs/profile_tab.dart';
import 'applications_screen.dart';
import 'community_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DashboardHome(),
      const InternSearchTab(),
      const ApplicationsScreen(),
      const CommunityScreen(),
      const ProfileTab(),
    ];

    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          body: IndexedStack(
            index: viewModel.currentIndex,
            children: pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            currentIndex: viewModel.currentIndex,
            onTap: (index) => viewModel.setIndex(index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Iconsax.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Iconsax.search_normal), label: 'Internships'),
              BottomNavigationBarItem(icon: Icon(Iconsax.document), label: 'Applications'),
              BottomNavigationBarItem(icon: Icon(Iconsax.people), label: 'Community'),
              BottomNavigationBarItem(icon: Icon(Iconsax.profile_circle), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final internshipVM = context.watch<InternshipViewModel>();

    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuickFilter(),
                const SizedBox(height: 24),
                const Text('Latest Internships', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                StreamBuilder(
                  stream: internshipVM.allInternships,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final internships = snapshot.data ?? [];
                    if (internships.isEmpty) {
                      return const Center(child: Text('No internships yet'));
                    }
                    return Column(
                      children: internships.take(5).map((i) => Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(i.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${i.company} • ${i.location}'),
                          trailing: Text(i.stipend, style: const TextStyle(color: Colors.green)),
                        ),
                      )).toList(),
                    );
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Be Practical', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              Icon(Iconsax.notification, color: Colors.white),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Find your perfect internship ✨', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search internships...',
              prefixIcon: const Icon(Iconsax.search_normal),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['All', 'Remote', 'On-site', 'Hybrid'].map((label) =>
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: label == 'All' ? const Color(0xFF1E40AF) : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: label == 'All' ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ).toList(),
      ),
    );
  }
}