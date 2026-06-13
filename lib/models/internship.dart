class Internship {
  final String id;
  final String company;
  final String logo;
  final String position;
  final String location;
  final String type; // Remote, Onsite, Hybrid
  final String salary;
  final String price; // Added price for purchase/enrollment
  final String deadline;
  final String description;
  final List<String> requirements;
  final List<String> responsibilities;
  final String duration;
  final int seatsLeft;
  final int matchPercentage;
  final int postedDays;
  final String website;
  final String postedDate;
  final List<String> skills;
  final bool verified;
  final bool featured;
  final bool trending;
  bool applied;
  bool saved;
  String status; // 'Applied', 'Under Review', 'Accepted', 'Rejected', 'None'

  Internship({
    required this.id,
    required this.company,
    required this.logo,
    required this.position,
    required this.location,
    required this.type,
    required this.salary,
    required this.price,
    required this.deadline,
    required this.description,
    required this.requirements,
    required this.responsibilities,
    required this.duration,
    required this.seatsLeft,
    required this.matchPercentage,
    required this.postedDays,
    required this.website,
    required this.postedDate,
    required this.skills,
    required this.verified,
    required this.featured,
    required this.trending,
    this.applied = false,
    this.saved = false,
    this.status = 'None',
  });

  Internship copyWith({
    bool? applied,
    bool? saved,
    String? status,
  }) {
    return Internship(
      id: id,
      company: company,
      logo: logo,
      position: position,
      location: location,
      type: type,
      salary: salary,
      price: price,
      deadline: deadline,
      description: description,
      requirements: requirements,
      responsibilities: responsibilities,
      duration: duration,
      seatsLeft: seatsLeft,
      matchPercentage: matchPercentage,
      postedDays: postedDays,
      website: website,
      postedDate: postedDate,
      skills: skills,
      verified: verified,
      featured: featured,
      trending: trending,
      applied: applied ?? this.applied,
      saved: saved ?? this.saved,
      status: status ?? this.status,
    );
  }

  factory Internship.fromFirestore(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Internship(
      id: doc.id,
      company: data['company'] ?? '',
      logo: data['logo'] ?? '',
      position: data['position'] ?? '',
      location: data['location'] ?? '',
      type: data['type'] ?? '',
      salary: data['salary'] ?? '',
      price: data['price'] ?? '',
      deadline: data['deadline'] ?? '',
      description: data['description'] ?? '',
      requirements: List<String>.from(data['requirements'] ?? []),
      responsibilities: List<String>.from(data['responsibilities'] ?? []),
      duration: data['duration'] ?? '',
      seatsLeft: data['seatsLeft'] ?? 0,
      matchPercentage: data['matchPercentage'] ?? 0,
      postedDays: data['postedDays'] ?? 0,
      website: data['website'] ?? '',
      postedDate: data['postedDate'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      verified: data['verified'] ?? false,
      featured: data['featured'] ?? false,
      trending: data['trending'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'company': company,
      'logo': logo,
      'position': position,
      'location': location,
      'type': type,
      'salary': salary,
      'price': price,
      'deadline': deadline,
      'description': description,
      'requirements': requirements,
      'responsibilities': responsibilities,
      'duration': duration,
      'seatsLeft': seatsLeft,
      'matchPercentage': matchPercentage,
      'postedDays': postedDays,
      'website': website,
      'postedDate': postedDate,
      'skills': skills,
      'verified': verified,
      'featured': featured,
      'trending': trending,
    };
  }
}
