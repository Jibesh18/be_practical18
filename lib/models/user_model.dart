import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'internSeeker' or 'employer'
  final String authProvider;
  final String bio;
  final List<String> skills;
  final String photoURL;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.authProvider,
    this.bio = '',
    this.skills = const [],
    this.photoURL = '',
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      authProvider: map['authProvider'] ?? 'password',
      bio: map['bio'] ?? '',
      skills: List<String>.from(map['skills'] ?? []),
      photoURL: map['photoURL'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'authProvider': authProvider,
      'bio': bio,
      'skills': skills,
      'photoURL': photoURL,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? name,
    String? bio,
    List<String>? skills,
    String? photoURL,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      role: role,
      authProvider: authProvider,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt,
    );
  }
}
 