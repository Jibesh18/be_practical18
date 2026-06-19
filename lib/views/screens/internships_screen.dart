import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/internship_model.dart';
import '../../viewmodels/internships_viewmodel.dart';


class InternshipsScreen extends StatelessWidget {
  const InternshipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: Consumer<InternshipsViewModel>(
                builder: (context, viewModel, child) {
                  return ListView.builder(
                    itemCount: viewModel.internships.length,
                    itemBuilder: (context, index) {
                      final internship = viewModel.internships[index];
                      return InternshipCard(internship: internship);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InternshipCard extends StatelessWidget {
  final Internship internship;

  const InternshipCard({super.key, required this.internship});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Iconsax.briefcase)),
        title: Text(internship.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${internship.company} • ${internship.location}'),
        trailing: Text(internship.stipend, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
      ),
    );
  }
}