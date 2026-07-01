import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/application_model.dart';
import '../../viewmodels/applications_viewmodel.dart';

class ApplicationsScreen extends StatelessWidget {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<ApplicationsViewModel>(
              builder: (context, viewModel, child) {
                return TextField(
                  onChanged: (value) => viewModel.searchApplications(value),
                  decoration: InputDecoration(
                    hintText: 'Search applications...',
                    prefixIcon: const Icon(Iconsax.search_normal),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<ApplicationsViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.applications.isEmpty) {
                  return const Center(child: Text('No applications found.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: viewModel.applications.length,
                  itemBuilder: (context, index) {
                    final application = viewModel.applications[index];
                    return ApplicationCard(application: application);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ApplicationCard extends StatelessWidget {
  final Application application;

  const ApplicationCard({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Iconsax.document, color: application.color),
        title: Text(application.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(application.company),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(application.status, style: TextStyle(color: application.color, fontWeight: FontWeight.w600)),
            Text(application.date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}