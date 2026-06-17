class Internship {
  final String title;
  final String company;
  final String location;
  final String stipend;
  final String icon;

  Internship({
    required this.title,
    required this.company,
    required this.location,
    required this.stipend,
    this.icon = '💼',
  });
}