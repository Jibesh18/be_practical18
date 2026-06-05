import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/skill.dart';
import '../repo/skill_service.dart';

final skillServiceProvider = Provider((ref) => SkillService());

final skillsProvider = FutureProvider<List<Skill>>((ref) {
  final service = ref.watch(skillServiceProvider);
  return service.getAllSkills();
});

final skillByIdProvider = FutureProvider.family<Skill?, String>((ref, id) {
  final service = ref.watch(skillServiceProvider);
  return service.getSkill(id);
});
