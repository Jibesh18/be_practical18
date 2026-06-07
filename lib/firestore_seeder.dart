import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreSeeder {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> seedData() async {
    try {
      await _seedInternships();
      await _seedSkills();
      debugPrint("✅ Firestore Seeding Complete!");
    } catch (e) {
      debugPrint("❌ Error seeding Firestore: $e");
    }
  }

  Future<void> _seedInternships() async {
    final collection = _db.collection('internships');
    final snapshot = await collection.get();
    
    // Clear existing to ensure fresh 20+ internships with new schema
    final deleteBatch = _db.batch();
    for (var doc in snapshot.docs) {
      deleteBatch.delete(doc.reference);
    }
    await deleteBatch.commit();
    
    debugPrint("Seeding Internships...");
    
    final List<Map<String, dynamic>> internshipsData = [
      {
        'company': 'Google', 'logo': '🏢', 'position': 'Flutter Developer Intern',
        'location': 'Mountain View, CA', 'type': 'Onsite', 'salary': '\$5000/mo', 'price': 'Free',
        'deadline': '2 weeks left', 'description': 'Join the Flutter team at Google to build world-class mobile experiences.',
        'requirements': ['Proficient in Dart', 'Enrolled in CS degree'],
        'responsibilities': ['Write clean code', 'Fix UI bugs'],
        'duration': '3 Months', 'seatsLeft': 5, 'matchPercentage': 95, 'postedDays': 2,
        'website': 'https://careers.google.com', 'postedDate': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'skills': ['Flutter', 'Dart', 'Git'], 'verified': true, 'featured': true, 'trending': true,
      },
      {
        'company': 'Tesla', 'logo': '⚡', 'position': 'AI Software Intern',
        'location': 'Palo Alto, CA', 'type': 'Hybrid', 'salary': '\$4500/mo', 'price': 'Free',
        'deadline': '1 month left', 'description': 'Help build the future of sustainable energy. Work on computer vision and autopilot software.',
        'requirements': ['Python proficiency', 'Math background'],
        'responsibilities': ['Train neural networks', 'Data collection'],
        'duration': '6 Months', 'seatsLeft': 2, 'matchPercentage': 85, 'postedDays': 5,
        'website': 'https://tesla.com/careers', 'postedDate': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'skills': ['Python', 'AI', 'C++'], 'verified': true, 'featured': true, 'trending': true,
      },
      {
        'company': 'Be Practical Academy', 'logo': '🎓', 'position': 'Full-Stack Developer Program',
        'location': 'Remote', 'type': 'Remote', 'salary': 'Stipend based', 'price': '\$199',
        'deadline': 'Ongoing', 'description': 'A premium accelerated program focused on building real-world production apps.',
        'requirements': ['Basic Logic', 'Persistence'],
        'responsibilities': ['Build 5 live projects', 'Weekly code reviews'],
        'duration': '6 Months', 'seatsLeft': 50, 'matchPercentage': 100, 'postedDays': 1,
        'website': 'https://bepractical.com', 'postedDate': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'skills': ['React', 'Node.js', 'Firebase', 'Flutter'], 'verified': true, 'featured': true, 'trending': true,
      },
      {
        'company': 'Apple', 'logo': '🍎', 'position': 'iOS Developer Intern',
        'location': 'Cupertino, CA', 'type': 'Onsite', 'salary': '\$5500/mo', 'price': 'Free',
        'deadline': '3 weeks left', 'description': 'Create intuitive, beautiful applications for the Apple ecosystem.',
        'requirements': ['Swift', 'Objective-C', 'Design patterns'],
        'responsibilities': ['Develop iOS apps', 'Work with designers'],
        'duration': '3 Months', 'seatsLeft': 4, 'matchPercentage': 90, 'postedDays': 3,
        'website': 'https://jobs.apple.com', 'postedDate': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'skills': ['Swift', 'iOS', 'Xcode'], 'verified': true, 'featured': false, 'trending': true,
      },
      {
        'company': 'Meta', 'logo': '♾️', 'position': 'React Native Developer Intern',
        'location': 'Menlo Park, CA', 'type': 'Hybrid', 'salary': '\$5200/mo', 'price': 'Free',
        'deadline': '1 week left', 'description': 'Build cross-platform mobile apps using React Native.',
        'requirements': ['JavaScript', 'React', 'Redux'],
        'responsibilities': ['Build features', 'Optimize performance'],
        'duration': '3 Months', 'seatsLeft': 6, 'matchPercentage': 88, 'postedDays': 4,
        'website': 'https://metacareers.com', 'postedDate': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
        'skills': ['React Native', 'JavaScript', 'Redux'], 'verified': true, 'featured': true, 'trending': false,
      },
      {
        'company': 'Amazon', 'logo': '📦', 'position': 'Cloud Computing Intern',
        'location': 'Seattle, WA', 'type': 'Onsite', 'salary': '\$4800/mo', 'price': 'Free',
        'deadline': '2 weeks left', 'description': 'Work on highly scalable AWS services.',
        'requirements': ['AWS', 'Linux', 'Networking fundamentals'],
        'responsibilities': ['Manage servers', 'Optimize cloud architecture'],
        'duration': '6 Months', 'seatsLeft': 10, 'matchPercentage': 80, 'postedDays': 7,
        'website': 'https://amazon.jobs', 'postedDate': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        'skills': ['AWS', 'Linux', 'Cloud'], 'verified': true, 'featured': false, 'trending': true,
      },
      {
        'company': 'Netflix', 'logo': '🎬', 'position': 'Data Science Intern',
        'location': 'Los Gatos, CA', 'type': 'Remote', 'salary': '\$5100/mo', 'price': 'Free',
        'deadline': '1 month left', 'description': 'Analyze user viewing patterns and improve recommendation algorithms.',
        'requirements': ['Python', 'SQL', 'Machine Learning'],
        'responsibilities': ['Analyze data', 'Build predictive models'],
        'duration': '4 Months', 'seatsLeft': 3, 'matchPercentage': 92, 'postedDays': 2,
        'website': 'https://jobs.netflix.com', 'postedDate': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'skills': ['Data Science', 'Python', 'SQL'], 'verified': true, 'featured': true, 'trending': true,
      },
      {
        'company': 'Spotify', 'logo': '🎵', 'position': 'UI/UX Design Intern',
        'location': 'Stockholm, Sweden', 'type': 'Hybrid', 'salary': '\$4000/mo', 'price': 'Free',
        'deadline': '3 weeks left', 'description': 'Design user-centric interfaces for our millions of listeners.',
        'requirements': ['Figma', 'Prototyping', 'User Research'],
        'responsibilities': ['Create wireframes', 'Conduct user tests'],
        'duration': '3 Months', 'seatsLeft': 2, 'matchPercentage': 85, 'postedDays': 5,
        'website': 'https://lifeatspotify.com', 'postedDate': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'skills': ['UI/UX', 'Figma', 'Design'], 'verified': true, 'featured': false, 'trending': false,
      },
      {
        'company': 'Adobe', 'logo': '🎨', 'position': 'Graphic Design Intern',
        'location': 'San Jose, CA', 'type': 'Remote', 'salary': '\$3500/mo', 'price': 'Free',
        'deadline': '2 weeks left', 'description': 'Assist in creating visual content for marketing campaigns.',
        'requirements': ['Photoshop', 'Illustrator', 'Creativity'],
        'responsibilities': ['Design graphics', 'Edit photos'],
        'duration': '3 Months', 'seatsLeft': 4, 'matchPercentage': 78, 'postedDays': 8,
        'website': 'https://careers.adobe.com', 'postedDate': DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
        'skills': ['Graphic Design', 'Photoshop', 'Illustrator'], 'verified': true, 'featured': false, 'trending': false,
      },
      {
        'company': 'HubSpot', 'logo': '📈', 'position': 'Digital Marketing Intern',
        'location': 'Cambridge, MA', 'type': 'Remote', 'salary': '\$3000/mo', 'price': 'Free',
        'deadline': '1 month left', 'description': 'Learn and apply inbound marketing strategies.',
        'requirements': ['Marketing concepts', 'Analytics', 'Copywriting'],
        'responsibilities': ['Manage social media', 'Analyze campaign performance'],
        'duration': '4 Months', 'seatsLeft': 5, 'matchPercentage': 82, 'postedDays': 6,
        'website': 'https://hubspot.com/careers', 'postedDate': DateTime.now().subtract(const Duration(days: 6)).toIso8601String(),
        'skills': ['Marketing', 'SEO', 'Analytics'], 'verified': true, 'featured': false, 'trending': true,
      },
      {
        'company': 'Moz', 'logo': '🔍', 'position': 'SEO Specialist Intern',
        'location': 'Seattle, WA', 'type': 'Remote', 'salary': '\$3200/mo', 'price': 'Free',
        'deadline': '2 weeks left', 'description': 'Optimize website content for better search engine rankings.',
        'requirements': ['SEO knowledge', 'Google Analytics', 'HTML basics'],
        'responsibilities': ['Keyword research', 'On-page optimization'],
        'duration': '3 Months', 'seatsLeft': 2, 'matchPercentage': 75, 'postedDays': 10,
        'website': 'https://moz.com/about/jobs', 'postedDate': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        'skills': ['SEO', 'Google Analytics', 'Marketing'], 'verified': true, 'featured': false, 'trending': false,
      },
      {
        'company': 'Medium', 'logo': '✍️', 'position': 'Content Writing Intern',
        'location': 'San Francisco, CA', 'type': 'Remote', 'salary': '\$2800/mo', 'price': 'Free',
        'deadline': '3 weeks left', 'description': 'Write engaging articles on technology and design.',
        'requirements': ['Excellent writing skills', 'Research abilities'],
        'responsibilities': ['Draft articles', 'Edit content'],
        'duration': '3 Months', 'seatsLeft': 6, 'matchPercentage': 88, 'postedDays': 3,
        'website': 'https://jobs.medium.com', 'postedDate': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'skills': ['Content Writing', 'Copywriting', 'Editing'], 'verified': true, 'featured': false, 'trending': false,
      },
      {
        'company': 'CrowdStrike', 'logo': '🛡️', 'position': 'Cyber Security Intern',
        'location': 'Austin, TX', 'type': 'Onsite', 'salary': '\$4600/mo', 'price': 'Free',
        'deadline': '1 month left', 'description': 'Help protect systems against cyber threats.',
        'requirements': ['Networking', 'Linux', 'Security fundamentals'],
        'responsibilities': ['Monitor security logs', 'Vulnerability scanning'],
        'duration': '6 Months', 'seatsLeft': 3, 'matchPercentage': 84, 'postedDays': 5,
        'website': 'https://crowdstrike.com/careers', 'postedDate': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'skills': ['Cyber Security', 'Networking', 'Linux'], 'verified': true, 'featured': true, 'trending': true,
      },
      {
        'company': 'GitLab', 'logo': '🦊', 'position': 'DevOps Engineer Intern',
        'location': 'Remote', 'type': 'Remote', 'salary': '\$4200/mo', 'price': 'Free',
        'deadline': '2 weeks left', 'description': 'Automate and streamline the software development lifecycle.',
        'requirements': ['CI/CD', 'Docker', 'Linux'],
        'responsibilities': ['Maintain pipelines', 'Manage infrastructure'],
        'duration': '4 Months', 'seatsLeft': 4, 'matchPercentage': 86, 'postedDays': 4,
        'website': 'https://about.gitlab.com/jobs', 'postedDate': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
        'skills': ['DevOps', 'Docker', 'CI/CD'], 'verified': true, 'featured': false, 'trending': true,
      },
      {
        'company': 'Oracle', 'logo': '🗄️', 'position': 'Database Administration Intern',
        'location': 'Redwood City, CA', 'type': 'Hybrid', 'salary': '\$4000/mo', 'price': 'Free',
        'deadline': '3 weeks left', 'description': 'Manage and optimize large-scale enterprise databases.',
        'requirements': ['SQL', 'Database concepts', 'Linux'],
        'responsibilities': ['Monitor database performance', 'Backup and recovery'],
        'duration': '6 Months', 'seatsLeft': 2, 'matchPercentage': 79, 'postedDays': 6,
        'website': 'https://oracle.com/careers', 'postedDate': DateTime.now().subtract(const Duration(days: 6)).toIso8601String(),
        'skills': ['Database', 'SQL', 'Oracle'], 'verified': true, 'featured': false, 'trending': false,
      },
      {
        'company': 'Stripe', 'logo': '💳', 'position': 'FinTech Engineering Intern',
        'location': 'Remote', 'type': 'Remote', 'salary': '\$5500/mo', 'price': 'Free',
        'deadline': '2 weeks left', 'description': 'Build secure payment gateways and financial tools.',
        'requirements': ['Ruby', 'Java', 'Cryptography'],
        'responsibilities': ['Build APIs', 'Enhance security'],
        'duration': '3 Months', 'seatsLeft': 3, 'matchPercentage': 89, 'postedDays': 2,
        'website': 'https://stripe.com/jobs', 'postedDate': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'skills': ['Ruby', 'API Design', 'Security'], 'verified': true, 'featured': true, 'trending': true,
      },
      {
        'company': 'Notion', 'logo': '📝', 'position': 'Frontend Engineer Intern',
        'location': 'San Francisco, CA', 'type': 'Hybrid', 'salary': '\$4800/mo', 'price': 'Free',
        'deadline': '1 month left', 'description': 'Enhance the Notion desktop and web experience.',
        'requirements': ['React', 'TypeScript', 'CSS'],
        'responsibilities': ['Build reusable UI components', 'Optimize web vitals'],
        'duration': '4 Months', 'seatsLeft': 5, 'matchPercentage': 91, 'postedDays': 4,
        'website': 'https://notion.so/careers', 'postedDate': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
        'skills': ['React', 'TypeScript', 'Frontend'], 'verified': true, 'featured': false, 'trending': true,
      },
      {
        'company': 'SpaceX', 'logo': '🚀', 'position': 'Embedded Systems Intern',
        'location': 'Hawthorne, CA', 'type': 'Onsite', 'salary': '\$5000/mo', 'price': 'Free',
        'deadline': '3 weeks left', 'description': 'Write software for rockets and spacecraft.',
        'requirements': ['C/C++', 'RTOS', 'Hardware integration'],
        'responsibilities': ['Develop flight software', 'Test hardware sensors'],
        'duration': '6 Months', 'seatsLeft': 2, 'matchPercentage': 83, 'postedDays': 1,
        'website': 'https://spacex.com/careers', 'postedDate': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'skills': ['C++', 'Embedded', 'Hardware'], 'verified': true, 'featured': true, 'trending': false,
      },
      {
        'company': 'Airbnb', 'logo': '🏠', 'position': 'Mobile Engineer Intern',
        'location': 'Remote', 'type': 'Remote', 'salary': '\$5300/mo', 'price': 'Free',
        'deadline': '2 weeks left', 'description': 'Create seamless booking experiences for millions of travelers.',
        'requirements': ['Swift or Kotlin', 'Mobile Design Patterns'],
        'responsibilities': ['Build mobile screens', 'Fix user-reported bugs'],
        'duration': '3 Months', 'seatsLeft': 4, 'matchPercentage': 87, 'postedDays': 5,
        'website': 'https://careers.airbnb.com', 'postedDate': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'skills': ['Mobile', 'Swift', 'Kotlin'], 'verified': true, 'featured': false, 'trending': true,
      },
      {
        'company': 'Duolingo', 'logo': '🦉', 'position': 'EdTech Software Intern',
        'location': 'Pittsburgh, PA', 'type': 'Hybrid', 'salary': '\$4700/mo', 'price': 'Free',
        'deadline': '4 weeks left', 'description': 'Make education free and fun for everyone.',
        'requirements': ['Python', 'A/B Testing', 'Gamification concepts'],
        'responsibilities': ['Analyze learning paths', 'Implement new lessons'],
        'duration': '3 Months', 'seatsLeft': 6, 'matchPercentage': 82, 'postedDays': 3,
        'website': 'https://careers.duolingo.com', 'postedDate': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'skills': ['Python', 'Analytics', 'A/B Testing'], 'verified': true, 'featured': true, 'trending': false,
      },
      {
        'company': 'OpenAI', 'logo': '🤖', 'position': 'Machine Learning Research Intern',
        'location': 'San Francisco, CA', 'type': 'Onsite', 'salary': '\$6000/mo', 'price': 'Free',
        'deadline': '2 weeks left', 'description': 'Push the boundaries of artificial general intelligence.',
        'requirements': ['Deep Learning', 'PyTorch', 'Research experience'],
        'responsibilities': ['Train large models', 'Evaluate safety and alignment'],
        'duration': '6 Months', 'seatsLeft': 2, 'matchPercentage': 75, 'postedDays': 1,
        'website': 'https://openai.com/careers', 'postedDate': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'skills': ['PyTorch', 'Deep Learning', 'Python'], 'verified': true, 'featured': true, 'trending': true,
      }
    ];

    final batch = _db.batch();
    for (var data in internshipsData) {
      final docRef = collection.doc();
      batch.set(docRef, data);
    }
    await batch.commit();
  }

  Future<void> _seedSkills() async {
    final collection = _db.collection('skills');
    final snapshot = await collection.limit(1).get();
    
    if (snapshot.docs.isNotEmpty) return;
    
    debugPrint("Seeding Skills...");
    
    final List<Map<String, dynamic>> skillsData = [
      {
        'name': 'Flutter & Dart', 'category': 'Mobile', 'level': 4, 'xp': 750, 'maxXp': 1000, 'progress': 0.75,
        'lessons': [
          {'title': 'Riverpod State', 'content': 'Manage global app state with clean architecture.', 'codeSnippet': 'final userProvider = StateProvider((ref) => User());'},
          {'title': 'Awe-Inspiring UI', 'content': 'Using 3D depth and animations in Flutter.', 'codeSnippet': 'Widget build(context) => Container().animate().scale();'},
        ],
      },
      {
        'name': 'Python for AI', 'category': 'Data Science', 'level': 2, 'xp': 320, 'maxXp': 1000, 'progress': 0.32,
        'lessons': [
          {'title': 'Pandas Dataframes', 'content': 'Analyze huge data sets with Python.', 'codeSnippet': 'import pandas as pd\\ndf = pd.read_csv("data.csv")'},
          {'title': 'Neural Networks', 'content': 'Building a simple perceptron with PyTorch.', 'codeSnippet': 'import torch.nn as nn\\nmodel = nn.Sequential(nn.Linear(10, 1))'},
        ],
      },
      {
        'name': 'React.js Next', 'category': 'Web', 'level': 3, 'xp': 600, 'maxXp': 1000, 'progress': 0.60,
        'lessons': [
          {'title': 'Server Components', 'content': 'Modern React rendering techniques.', 'codeSnippet': 'export default async function Page() { ... }'},
        ],
      },
      {
        'name': 'Cyber Security', 'category': 'Security', 'level': 1, 'xp': 150, 'maxXp': 1000, 'progress': 0.15,
        'lessons': [
          {'title': 'Ethical Hacking', 'content': 'Understanding vulnerability scanning.', 'codeSnippet': ''},
        ],
      },
      {
        'name': 'UI/UX Design', 'category': 'Design', 'level': 2, 'xp': 400, 'maxXp': 1000, 'progress': 0.40,
        'lessons': [
          {'title': 'Figma Basics', 'content': 'Creating wireframes and prototypes.', 'codeSnippet': ''},
          {'title': 'User Research', 'content': 'Conducting interviews to understand user needs.', 'codeSnippet': ''},
        ],
      },
      {
        'name': 'Cloud Computing (AWS)', 'category': 'Cloud', 'level': 3, 'xp': 550, 'maxXp': 1000, 'progress': 0.55,
        'lessons': [
          {'title': 'EC2 Instances', 'content': 'Deploying virtual servers in the cloud.', 'codeSnippet': ''},
          {'title': 'S3 Storage', 'content': 'Managing objects and buckets.', 'codeSnippet': ''},
        ],
      },
      {
        'name': 'Digital Marketing', 'category': 'Marketing', 'level': 1, 'xp': 200, 'maxXp': 1000, 'progress': 0.20,
        'lessons': [
          {'title': 'SEO Fundamentals', 'content': 'Optimizing for search engines.', 'codeSnippet': ''},
        ],
      },
      {
        'name': 'DevOps', 'category': 'Cloud', 'level': 2, 'xp': 300, 'maxXp': 1000, 'progress': 0.30,
        'lessons': [
          {'title': 'Docker Basics', 'content': 'Containerizing applications.', 'codeSnippet': 'docker build -t myapp .'},
        ],
      },
      {
        'name': 'iOS Development', 'category': 'Mobile', 'level': 3, 'xp': 650, 'maxXp': 1000, 'progress': 0.65,
        'lessons': [
          {'title': 'SwiftUI', 'content': 'Building declarative UIs.', 'codeSnippet': 'Text("Hello, World!")'},
        ],
      },
      {
        'name': 'Android Development', 'category': 'Mobile', 'level': 4, 'xp': 800, 'maxXp': 1000, 'progress': 0.80,
        'lessons': [
          {'title': 'Kotlin Coroutines', 'content': 'Managing background tasks.', 'codeSnippet': 'GlobalScope.launch { ... }'},
        ],
      },
      {
        'name': 'Database Administration', 'category': 'Database', 'level': 2, 'xp': 450, 'maxXp': 1000, 'progress': 0.45,
        'lessons': [
          {'title': 'SQL Queries', 'content': 'Writing complex joins.', 'codeSnippet': 'SELECT * FROM users JOIN orders ON users.id = orders.user_id;'},
        ],
      },
      {
        'name': 'Machine Learning', 'category': 'Data Science', 'level': 3, 'xp': 700, 'maxXp': 1000, 'progress': 0.70,
        'lessons': [
          {'title': 'Scikit-learn', 'content': 'Building classical ML models.', 'codeSnippet': 'from sklearn.linear_model import LinearRegression'},
        ],
      },
      {
        'name': 'Content Writing', 'category': 'Marketing', 'level': 1, 'xp': 100, 'maxXp': 1000, 'progress': 0.10,
        'lessons': [
          {'title': 'Copywriting', 'content': 'Writing persuasive copy.', 'codeSnippet': ''},
        ],
      },
      {
        'name': 'Project Management', 'category': 'Management', 'level': 2, 'xp': 350, 'maxXp': 1000, 'progress': 0.35,
        'lessons': [
          {'title': 'Agile Methodology', 'content': 'Scrum and Kanban frameworks.', 'codeSnippet': ''},
        ],
      },
      {
        'name': 'Business Analysis', 'category': 'Management', 'level': 3, 'xp': 500, 'maxXp': 1000, 'progress': 0.50,
        'lessons': [
          {'title': 'Requirements Gathering', 'content': 'Eliciting needs from stakeholders.', 'codeSnippet': ''},
        ],
      }
    ];

    final batch = _db.batch();
    for (var data in skillsData) {
      final docRef = collection.doc();
      batch.set(docRef, data);
    }
    await batch.commit();
  }
}
