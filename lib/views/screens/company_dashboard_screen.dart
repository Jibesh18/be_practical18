import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/company_dashboard_viewmodel.dart';

class CompanyDashboardScreen extends StatelessWidget {
  const CompanyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CompanyDashboardViewModel>(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Company Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Stats Cards
            Row(
              children: [
                _statCard(Iconsax.briefcase, viewModel.totalInternships.toString(), 'Posted'),
                const SizedBox(width: 12),
                _statCard(Iconsax.document, viewModel.activeApplications.toString(), 'Applications'),
                const SizedBox(width: 12),
                _statCard(Iconsax.award, viewModel.shortlisted.toString(), 'Shortlisted'),
              ],
            ),

            const SizedBox(height: 30),
            const Text('Recent Internships', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // Add list of recent internships...
          ],
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, String count, String label) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: Colors.blue, size: 32),
              const SizedBox(height: 8),
              Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}