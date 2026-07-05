import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../model/user.dart';
import '../model/internship.dart';
import '../viewmodel/company_provider.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final internships = ref.watch(myInternshipsProvider).value ?? [];
    final apps = ref.watch(companyApplicationsProvider).value ?? [];

    final filteredInternships = internships.where((i) => i.title.toLowerCase().contains(_query.toLowerCase())).toList();
    final filteredApps = apps.where((a) => a.studentName.toLowerCase().contains(_query.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: (v) => setState(() => _query = v),
          decoration: const InputDecoration(
            hintText: 'Search candidates, jobs, messages...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: _query.isEmpty 
        ? _buildRecentSearches() 
        : ListView(
            children: [
              if (filteredApps.isNotEmpty) _sectionHeader('Candidates'),
              ...filteredApps.map((a) => ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(a.studentName),
                subtitle: Text(a.internshipTitle),
                onTap: () => context.push('/view-student', extra: a),
              )),
              if (filteredInternships.isNotEmpty) _sectionHeader('Internships'),
              ...filteredInternships.map((i) => ListTile(
                leading: const Icon(Icons.work_outline),
                title: Text(i.title),
                subtitle: Text(i.status.name),
                onTap: () => context.push('/manage-internships'),
              )),
            ],
          ),
    );
  }

  Widget _sectionHeader(String t) => Padding(
    padding: const EdgeInsets.all(16),
    child: Text(t.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.blue)),
  );

  Widget _buildRecentSearches() => const Center(child: Text('Type to start searching across your portal', style: TextStyle(color: Colors.black38)));
}

