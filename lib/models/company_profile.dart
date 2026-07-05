import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyProfile {
  final String id;
  final String name;
  final String logo;
  final String coverPhoto;
  final String description;
  final String website;
  final String email;
  final String phone;
  final String address;
  final String googleMapsUrl;
  final String industry;
  final String size;
  final String foundedYear;
  final Map<String, String> socialLinks;
  final String vision;
  final String mission;
  final String culture;
  final bool isVerified;
  final String membershipPlan;

  CompanyProfile({
    required this.id,
    required this.name,
    required this.logo,
    this.coverPhoto = '',
    required this.description,
    required this.website,
    required this.email,
    required this.phone,
    required this.address,
    this.googleMapsUrl = '',
    required this.industry,
    required this.size,
    required this.foundedYear,
    required this.socialLinks,
    this.vision = '',
    this.mission = '',
    this.culture = '',
    this.isVerified = false,
    this.membershipPlan = 'Free',
  });

  factory CompanyProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CompanyProfile(
      id: doc.id,
      name: data['name'] ?? '',
      logo: data['logo'] ?? '',
      coverPhoto: data['coverPhoto'] ?? '',
      description: data['description'] ?? '',
      website: data['website'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      googleMapsUrl: data['googleMapsUrl'] ?? '',
      industry: data['industry'] ?? '',
      size: data['size'] ?? '',
      foundedYear: data['foundedYear'] ?? '',
      socialLinks: Map<String, String>.from(data['socialLinks'] ?? {}),
      vision: data['vision'] ?? '',
      mission: data['mission'] ?? '',
      culture: data['culture'] ?? '',
      isVerified: data['isVerified'] ?? false,
      membershipPlan: data['membershipPlan'] ?? 'Free',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'logo': logo,
      'coverPhoto': coverPhoto,
      'description': description,
      'website': website,
      'email': email,
      'phone': phone,
      'address': address,
      'googleMapsUrl': googleMapsUrl,
      'industry': industry,
      'size': size,
      'foundedYear': foundedYear,
      'socialLinks': socialLinks,
      'vision': vision,
      'mission': mission,
      'culture': culture,
      'isVerified': isVerified,
      'membershipPlan': membershipPlan,
    };
  }

  CompanyProfile copyWith({
    String? name, String? logo, String? coverPhoto, String? description,
    String? website, String? email, String? phone, String? address,
    String? googleMapsUrl, String? industry, String? size, String? foundedYear,
    Map<String, String>? socialLinks, String? vision, String? mission, String? culture,
    bool? isVerified, String? membershipPlan,
  }) {
    return CompanyProfile(
      id: id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      coverPhoto: coverPhoto ?? this.coverPhoto,
      description: description ?? this.description,
      website: website ?? this.website,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      googleMapsUrl: googleMapsUrl ?? this.googleMapsUrl,
      industry: industry ?? this.industry,
      size: size ?? this.size,
      foundedYear: foundedYear ?? this.foundedYear,
      socialLinks: socialLinks ?? this.socialLinks,
      vision: vision ?? this.vision,
      mission: mission ?? this.mission,
      culture: culture ?? this.culture,
      isVerified: isVerified ?? this.isVerified,
      membershipPlan: membershipPlan ?? this.membershipPlan,
    );
  }
}

