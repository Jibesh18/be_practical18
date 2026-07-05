import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/internship.dart';
import '../repo/internship_service.dart';

final internshipServiceProvider = Provider((ref) => InternshipService());

final searchQueryProvider = StateProvider<String>((ref) => '');
final activeFilterProvider = StateProvider<String>((ref) => 'all');

// Production Stream for Real-Time Synchronization
final allInternshipsStreamProvider = StreamProvider<List<Internship>>((ref) {
  return ref.watch(internshipServiceProvider).streamAllInternships();
});

// Helper for detail screens
final internshipDetailProvider = FutureProvider.family<Internship?, String>((ref, id) {
  return ref.watch(internshipServiceProvider).getById(id);
});

// Real-time checking if student has already applied
final applicationStatusProvider = StreamProvider.family<bool, String>((ref, internshipId) {
  return ref.watch(internshipServiceProvider).streamHasUserApplied(internshipId);
});

// Corrected: Real-time filtered internships using clean stream mapping
final filteredInternshipsProvider = StreamProvider<List<Internship>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final filter = ref.watch(activeFilterProvider);
  final internshipsStream = ref.watch(allInternshipsStreamProvider.stream);

  return internshipsStream.map((list) {
    return list.where((i) {
      final matchesSearch = i.title.toLowerCase().contains(query) || 
                           i.companyName.toLowerCase().contains(query);
      final matchesCat = filter == 'all' || i.category.toLowerCase() == filter.toLowerCase();
      return matchesSearch && matchesCat;
    }).toList();
  });
});

// Stream of student's own applications
final userApplicationsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(internshipServiceProvider).streamUserApplications();
});

// Legacy support
final allInternshipsProvider = FutureProvider<List<Internship>>((ref) async {
  return ref.watch(internshipServiceProvider).getAllInternships();
});

final userApplicationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(internshipServiceProvider).getUserApplications();
});

