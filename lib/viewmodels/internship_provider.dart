import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/internship.dart';
import '../repo/internship_service.dart';

final internshipServiceProvider = Provider((ref) => InternshipService());

final searchQueryProvider = StateProvider<String>((ref) => '');
final activeFilterProvider = StateProvider<String>((ref) => 'all');

final allInternshipsProvider = FutureProvider<List<Internship>>((ref) {
  final service = ref.watch(internshipServiceProvider);
  return service.getAllInternships();
});

final filteredInternshipsProvider =
    FutureProvider<List<Internship>>((ref) async {
  final service = ref.watch(internshipServiceProvider);
  final query = ref.watch(searchQueryProvider);
  final filter = ref.watch(activeFilterProvider);

  List<Internship> results;

  if (query.isNotEmpty) {
    results = await service.searchInternships(query);
  } else if (filter != 'all') {
    results = await service.filterInternships(filter);
  } else {
    results = await service.getAllInternships();
  }

  return results;
});

final trendingInternshipsProvider = FutureProvider<List<Internship>>((ref) {
  final service = ref.watch(internshipServiceProvider);
  return service.getTrendingInternships();
});

final userApplicationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(internshipServiceProvider);
  return service.getUserApplications();
});

final applicationStatusProvider = FutureProvider.family<bool, String>((ref, internshipId) {
  final service = ref.watch(internshipServiceProvider);
  return service.hasUserApplied(internshipId);
});
