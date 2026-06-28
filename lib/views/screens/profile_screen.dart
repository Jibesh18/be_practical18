import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/profile.png'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Bipin Ranabhat',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const Text(
                    'Flutter Developer Intern',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCompletion(),
                  const SizedBox(height: 24),

                  _buildSectionTitle('About Me'),
                  const Text(
                    'Passionate Computer Science student looking for opportunities in mobile development. '
                        'Love building beautiful and functional apps with Flutter.',
                    style: TextStyle(fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Education'),
                  _buildEducationCard(),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Skills'),
                  _buildSkills(),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Projects'),
                  _buildProjects(),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Social Links'),
                  _buildSocialLinks(),
                  const SizedBox(height: 24),

                  _buildResumeCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCompletion() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Profile Completion', style: TextStyle(fontWeight: FontWeight.w600)),
            const Text('78%', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: 0.78,
          backgroundColor: Colors.grey[300],
          color: Colors.blue,
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEducationCard() {
    return Card(
      child: ListTile(
        leading: const Icon(Iconsax.book, color: Colors.blue),
        title: const Text('B.Sc. Computer Science'),
        subtitle: const Text('Tribhuvan University • 2022 - 2026'),
      ),
    );
  }

  Widget _buildSkills() {
    final skills = ['Flutter', 'Dart', 'Firebase', 'UI/UX', 'Git', 'REST API'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills.map((skill) => Chip(
        label: Text(skill),
        backgroundColor: Colors.blue.withOpacity(0.1),
        labelStyle: const TextStyle(color: Colors.blue),
      )).toList(),
    );
  }

  Widget _buildProjects() {
    return Column(
      children: [
        _projectCard('E-commerce App', 'Flutter + Firebase'),
        _projectCard('Weather App', 'API Integration'),
      ],
    );
  }

  Widget _projectCard(String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Iconsax.code, color: Colors.purple),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
  Widget _buildSocialLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialImage('assets/images/linked resized.jpg', () {}),      // LinkedIn
        const SizedBox(width: 24),
        _socialImage('assets/images/github logo resized.png', () {}), // GitHub
        const SizedBox(width: 24),
        _socialImage('assets/images/instagram logo resized.jpg', () {}), // Instagram
        const SizedBox(width: 24),
        _socialImage('assets/images/facebook resized.png', () {}),             // Portfolio / Website (you can change)
      ],
    );
  }

  Widget _socialImage(String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Image.asset(
            imagePath,
            width: 45,
            height: 45,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
  Widget _buildResumeCard() {
    return Card(
      child: ListTile(
        leading: const Icon(Iconsax.document_download, color: Colors.green),
        title: const Text('Resume'),
        subtitle: const Text('Bipin_Ranabhat_Resume.pdf'),
        trailing: ElevatedButton(
          onPressed: () {},
          child: const Text('Download'),
        ),
      ),
    );
  }
}