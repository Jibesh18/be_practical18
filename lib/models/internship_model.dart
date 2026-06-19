class Internship {
  final String id;
  final String title;
  final String company;
  final String location;
  final String stipend;
  final String type;
  final List<String> skills;
  final String description;
  final DateTime postedDate;
  final int applicationsCount;

  Internship({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.stipend,
    required this.type,
    required this.skills,
    required this.description,
    required this.postedDate,
    this.applicationsCount = 0,
  });
}