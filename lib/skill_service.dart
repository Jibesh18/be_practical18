import '../model/skill.dart';

class SkillService {
  final List<Skill> _skills = [
    Skill(
      id: '1',
      name: 'Flutter & Dart',
      category: 'Mobile',
      level: 4,
      xp: 750,
      maxXp: 1000,
      progress: 0.75,
      lessons: [
        Lesson(
          title: 'Riverpod State',
          content: 'Manage global app state with clean architecture.',
          codeSnippet: 'final userProvider = StateProvider((ref) => User());',
        ),
        Lesson(
          title: 'Awe-Inspiring UI',
          content: 'Using 3D depth and animations in Flutter.',
          codeSnippet: 'Widget build(context) => Container().animate().scale();',
        ),
      ],
    ),
    Skill(
      id: '2',
      name: 'Python for AI',
      category: 'Data Science',
      level: 2,
      xp: 320,
      maxXp: 1000,
      progress: 0.32,
      lessons: [
        Lesson(
          title: 'Pandas Dataframes',
          content: 'Analyze huge data sets with Python.',
          codeSnippet: 'import pandas as pd\ndf = pd.read_csv("data.csv")',
        ),
        Lesson(
          title: 'Neural Networks',
          content: 'Building a simple perceptron with PyTorch.',
          codeSnippet: 'import torch.nn as nn\nmodel = nn.Sequential(nn.Linear(10, 1))',
        ),
      ],
    ),
    Skill(
      id: '3',
      name: 'React.js Next',
      category: 'Web',
      level: 3,
      xp: 600,
      maxXp: 1000,
      progress: 0.60,
      lessons: [
        Lesson(
          title: 'Server Components',
          content: 'Modern React rendering techniques.',
          codeSnippet: 'export default async function Page() { ... }',
        ),
      ],
    ),
    Skill(
      id: '4',
      name: 'Cyber Security',
      category: 'Security',
      level: 1,
      xp: 150,
      maxXp: 1000,
      progress: 0.15,
      lessons: [
        Lesson(
          title: 'Ethical Hacking',
          content: 'Understanding vulnerability scanning.',
        ),
      ],
    ),
  ];

  Future<List<Skill>> getAllSkills() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _skills;
  }

  Future<Skill?> getSkill(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _skills.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
}
