class Lesson {
  final String title;
  final String content;
  final String codeSnippet;

  Lesson({
    required this.title,
    required this.content,
    this.codeSnippet = "",
  });
}

class Skill {
  final String id;
  final String name;
  final String category;
  final List<Lesson> lessons;
  final double progress;
  final int level;
  final int xp;
  final int maxXp;

  Skill({
    required this.id,
    required this.name,
    required this.category,
    required this.lessons,
    required this.progress,
    required this.level,
    required this.xp,
    required this.maxXp,
  });

  int get progressPercentage => (progress * 100).toInt();
}
