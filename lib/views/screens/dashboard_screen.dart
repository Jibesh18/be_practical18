import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';


import '../../viewmodels/dashboard_viewmodel.dart';
import 'profile_screen.dart';
import 'internships_screen.dart';
import 'applications_screen.dart';
import 'community_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  final List<Widget> _pages = const [
    DashboardContent(),
    InternshipsScreen(),
    ApplicationsScreen(),
    CommunityScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          body: IndexedStack(
            index: viewModel.currentIndex,
            children: _pages,
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

// ================== DASHBOARD HOME CONTENT ==================
class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
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
                _buildSectionTitle('Recommended For You (AI Powered)'),
                const SizedBox(height: 12),
                _buildRecommendedList(),
                const SizedBox(height: 24),
                _buildSectionTitle("What's trending!" ),
                const SizedBox(height: 12),
                _buildLatestInternships(),
                const SizedBox(height: 150),
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
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Iconsax.teacher, color: Colors.white, size: 36),
                  SizedBox(width: 10),
                  Text('Be Practical', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  const Text('Hi Bipin! ', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                  const Icon(Iconsax.star, color: Colors.amber, size: 22),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      );
                    },
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage('assets/images/profilepic.png'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Ready to level up your IT career? ✨', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search internships, courses...',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Filter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All Roles', true),
              const SizedBox(width: 8),
              _buildFilterChip('Kathmandu', false),
              const SizedBox(width: 8),
              _buildFilterChip('Remote', false),
              const SizedBox(width: 8),
              _buildFilterChip('Paid', true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));

  Widget _buildRecommendedList() {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildRecommendedCard('Data Analyst Intern', 'ABC Company', Colors.blue),
          const SizedBox(width: 16),
          _buildRecommendedCard('Frontend Developer', 'TechNepal', Colors.purple),
        ],
      ),
    );
  }

  Widget _buildLatestInternships() {
    return Row(
      children: [
        Expanded(child: _buildInternshipCard('🐍', 'Python', 'Beginner')),
        const SizedBox(width: 12),
        Expanded(child: _buildInternshipCard('📊', 'Data Science', 'Essential')),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1E40AF) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildRecommendedCard(String title, String company, MaterialColor color) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.shade700, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          Text('at $company', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          const Align(alignment: Alignment.centerRight, child: Icon(Iconsax.arrow_right_3, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildInternshipCard(String icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}