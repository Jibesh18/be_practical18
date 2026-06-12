class ResourceModel {
  final String id;
  final String title;
  final String provider;
  final String description;
  final String url;
  final String category;
  final String iconName;

  ResourceModel({
    required this.id,
    required this.title,
    required this.provider,
    required this.description,
    required this.url,
    required this.category,
    required this.iconName,
  });

  factory ResourceModel.fromFirestore(String id, Map<String, dynamic> json) {
    return ResourceModel(
      id: id,
      title: json['title'] ?? '',
      provider: json['provider'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      category: json['category'] ?? '',
      iconName: json['iconName'] ?? 'school',
    );
  }
}