import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/skill.dart';

class SkillService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // The mock data has been moved to firestore_seeder.dart

  Future<List<Skill>> getAllSkills() async {
    final snapshot = await _db.collection('skills').get();
    return snapshot.docs.map((doc) => Skill.fromFirestore(doc)).toList();
  }

  Future<Skill?> getSkill(String id) async {
    try {
      final doc = await _db.collection('skills').doc(id).get();
      if (doc.exists) return Skill.fromFirestore(doc);
      return null;
    } catch (e) {
      return null;
    }
  }
}
