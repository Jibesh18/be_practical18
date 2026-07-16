class Notification {
  final String id;
  final String type; // 'internship', 'xp', 'message', 'deadline', 'announcement'
  final String title;
  final String message;
  final String time;
  final bool read;
  final bool isArchived;

  Notification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    this.read = false,
    this.isArchived = false,
  });

  Notification copyWith({
    String? id,
    String? type,
    String? title,
    String? message,
    String? time,
    bool? read,
    bool? isArchived,
  }) {
    return Notification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      read: read ?? this.read,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
