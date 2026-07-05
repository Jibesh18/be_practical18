import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../viewmodel/internship_provider.dart';
import '../model/internship.dart';
import '../components/cards/primary_card.dart';

class InternshipsScreen extends ConsumerStatefulWidget {
  const InternshipsScreen({super.key});
  @override
  ConsumerState<InternshipsScreen> createState() => _InternshipsScreenState();
}

class _InternshipsScreenState extends ConsumerState<InternshipsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final internshipsAsync = ref.watch(allInternshipsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Explore Internships', style: AppTextStyles.heading.copyWith(fontWeight: FontWeight.w900)),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
            child: internshipsAsync.when(
              data: (list) {
                final filtered = list.where((i) {
                  final matchesSearch = i.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                                       i.companyName.toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchesCat = _selectedCategory == 'all' || i.category.toLowerCase() == _selectedCategory.toLowerCase();
                  return matchesSearch && matchesCat;
                }).toList();

                if (filtered.isEmpty) return _buildEmptyState();

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _InternshipTile(internship: filtered[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: const InputDecoration(
            hintText: 'Search roles, companies...',
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['all', 'IT', 'Design', 'Marketing', 'Sales'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(cat.toUpperCase()),
              selected: isSelected,
              onSelected: (s) => setState(() => _selectedCategory = cat),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No matches found', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _InternshipTile extends StatelessWidget {
  final Internship internship;
  const _InternshipTile({required this.internship});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: PrimaryCard(
        onTap: () => context.push('/internship/${internship.id}'),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.accent.withValues(alpha: 0.1),
              child: Text(internship.logo, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(internship.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black)),
                  Text(internship.companyName, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _badge(internship.workMode.name.toUpperCase(), Colors.blue),
                      const SizedBox(width: 8),
                      _badge(internship.stipend, Colors.green),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black26),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }
}

