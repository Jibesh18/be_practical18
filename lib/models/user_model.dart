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
  final String education;
  final String experience;
  final bool cvUploaded;
  final String cvFileName;
  final String linkedinUrl;
  final String githubUrl;
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
    this.education = '',
    this.experience = '',
    this.cvUploaded = false,
    this.cvFileName = '',
    this.linkedinUrl = '',
    this.githubUrl = '',
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
      education: map['education'] ?? '',
      experience: map['experience'] ?? '',
      cvUploaded: map['cvUploaded'] ?? false,
      cvFileName: map['cvFileName'] ?? '',
      linkedinUrl: map['linkedinUrl'] ?? '',
      githubUrl: map['githubUrl'] ?? '',
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
      'education': education,
      'experience': experience,
      'cvUploaded': cvUploaded,
      'cvFileName': cvFileName,
      'linkedinUrl': linkedinUrl,
      'githubUrl': githubUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? name,
    String? bio,
    List<String>? skills,
    String? photoURL,
    String? education,
    String? experience,
    bool? cvUploaded,
    String? cvFileName,
    String? linkedinUrl,
    String? githubUrl,
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
      education: education ?? this.education,
      experience: experience ?? this.experience,
      cvUploaded: cvUploaded ?? this.cvUploaded,
      cvFileName: cvFileName ?? this.cvFileName,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      createdAt: createdAt,
    );
  }

  bool get isProfileComplete =>
      bio.isNotEmpty && education.isNotEmpty && skills.isNotEmpty;
}