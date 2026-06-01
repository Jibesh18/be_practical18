class UserStats {
  final int applicationsSubmitted;
  final int interviewsScheduled;
  final int offersReceived;
  final int learningStreak;

  UserStats({
    required this.applicationsSubmitted,
    required this.interviewsScheduled,
    required this.offersReceived,
    required this.learningStreak,
  });

  UserStats copyWith({
    int? applicationsSubmitted,
    int? interviewsScheduled,
    int? offersReceived,
    int? learningStreak,
  }) {
    return UserStats(
      applicationsSubmitted: applicationsSubmitted ?? this.applicationsSubmitted,
      interviewsScheduled: interviewsScheduled ?? this.interviewsScheduled,
      offersReceived: offersReceived ?? this.offersReceived,
      learningStreak: learningStreak ?? this.learningStreak,
    );
  }
}

class UserSkill {
  final String id;
  final String name;
  final double progress; // 0.0 to 1.0
  final int xp;
  final int projectsCompleted;
  final String icon;

  UserSkill({
    required this.id,
    required this.name,
    required this.progress,
    required this.xp,
    required this.projectsCompleted,
    required this.icon,
  });

  UserSkill copyWith({
    String? name,
    double? progress,
    int? xp,
    int? projectsCompleted,
    String? icon,
  }) {
    return UserSkill(
      id: id,
      name: name ?? this.name,
      progress: progress ?? this.progress,
      xp: xp ?? this.xp,
      projectsCompleted: projectsCompleted ?? this.projectsCompleted,
      icon: icon ?? this.icon,
    );
  }
}

class UserSettings {
  final bool publicProfile;
  final bool showEmail;
  final bool internshipVisibility;
  final bool notificationsEnabled;
  final bool twoFactorEnabled;

  UserSettings({
    this.publicProfile = true,
    this.showEmail = false,
    this.internshipVisibility = true,
    this.notificationsEnabled = true,
    this.twoFactorEnabled = false,
  });

  UserSettings copyWith({
    bool? publicProfile,
    bool? showEmail,
    bool? internshipVisibility,
    bool? notificationsEnabled,
    bool? twoFactorEnabled,
  }) {
    return UserSettings(
      publicProfile: publicProfile ?? this.publicProfile,
      showEmail: showEmail ?? this.showEmail,
      internshipVisibility: internshipVisibility ?? this.internshipVisibility,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
    );
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final String role;
  final List<UserSkill> skills;
  final UserStats stats;
  final UserSettings settings;
  final String headline;
  final String bio;
  final String location;
  final int level;
  final int xp;
  final int nextLevelXp;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.role,
    required this.skills,
    required this.stats,
    required this.settings,
    required this.headline,
    required this.bio,
    required this.location,
    required this.level,
    required this.xp,
    required this.nextLevelXp,
  });

  User copyWith({
    String? name,
    String? bio,
    String? avatar,
    int? xp,
    int? level,
    int? nextLevelXp,
    UserSettings? settings,
    UserStats? stats,
    String? role,
    List<UserSkill>? skills,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      skills: skills ?? this.skills,
      stats: stats ?? this.stats,
      settings: settings ?? this.settings,
      headline: headline,
      bio: bio ?? this.bio,
      location: location,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      nextLevelXp: nextLevelXp ?? this.nextLevelXp,
    );
  }
}
