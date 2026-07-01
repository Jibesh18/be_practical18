import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/applications_viewmodel.dart';
import 'internship_detail_screen.dart';

class InternshipsScreen extends StatelessWidget {
  const InternshipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final applicationVM = Provider.of<ApplicationsViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Internships', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search internships...',
                prefixIcon: const Icon(Iconsax.search_normal),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Recommended Internships', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _buildInternshipCard(
                    context,
                    id: '1',
                    title: 'Data Analyst Intern',
                    company: 'ABC Tech',
                    location: 'Kathmandu',
                    stipend: '15,000',
                    onApply: () => applicationVM.applyForInternship(
                      title: 'Data Analyst Intern',
                      company: 'ABC Tech',
                    ),
                  ),
                  _buildInternshipCard(
                    context,
                    id: '2',
                    title: 'Flutter Developer Intern',
                    company: 'TechNepal',
                    location: 'Remote',
                    stipend: '12,000',
                    onApply: () => applicationVM.applyForInternship(
                      title: 'Flutter Developer Intern',
                      company: 'TechNepal',
                    ),
                  ),
                  _buildInternshipCard(
                    context,
                    id: '3',
                    title: 'Digital Marketing Intern',
                    company: 'GrowthHub',
                    location: 'Kathmandu',
                    stipend: '8,000',
                    onApply: () => applicationVM.applyForInternship(
                      title: 'Digital Marketing Intern',
                      company: 'GrowthHub',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInternshipCard(
      BuildContext context, {
        required String id,
        required String title,
        required String company,
        required String location,
        required String stipend,
        required VoidCallback onApply,
      }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Clickable Job Information
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InternshipDetailScreen(
                        id: id,
                        title: title,
                        company: company,
                        location: location,
                        stipend: stipend,
                      ),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('$company • $location', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),

            // Apply Button
            ElevatedButton(
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Apply Now'),
            ),
          ],
        ),
      ),
    );
  }
}