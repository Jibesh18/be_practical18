import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(icon: const Icon(Iconsax.edit_2), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildProfileHeader(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCompletion(),
                  const SizedBox(height: 20),
                  _buildInfoStats(),
                  const SizedBox(height: 24),

                  _buildSectionTitle('About Me'),
                  const SizedBox(height: 8),
                  _buildAboutSection(),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Skills'),
                  const SizedBox(height: 12),
                  _buildSkills(),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Projects'),
                  const SizedBox(height: 12),
                  _buildProjects(),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Education'),
                  const SizedBox(height: 12),
                  _buildEducation(),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Resume & Documents'),
                  const SizedBox(height: 12),
                  _buildResumeCard(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              const CircleAvatar(
                radius: 55,
                backgroundImage: AssetImage('assets/images/profilepic.png'),
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, size: 18, color: Colors.blue),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Bipin Ranabhat', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const Text('Aspiring Data Analyst', style: TextStyle(fontSize: 16, color: Colors.white70)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.location_on, color: Colors.white70, size: 20),
              SizedBox(width: 6),
              Text('Kathmandu, Nepal', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletion() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Profile Completion', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('78%', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.78,
              backgroundColor: Colors.grey[200],
              color: Colors.blue,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoStats() {
    return Row(
      children: [
        Expanded(child: _statCard(Iconsax.briefcase, '12', 'Applied')),
        const SizedBox(width: 12),
        Expanded(child: _statCard(Iconsax.bookmark, '24', 'Saved')),
        const SizedBox(width: 12),
        Expanded(child: _statCard(Iconsax.award, '5', 'Certified')),
      ],
    );
  }

  Widget _statCard(IconData icon, String count, String label) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue, size: 28),
            const SizedBox(height: 8),
            Text(count, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildAboutSection() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Passionate about data-driven decision making. Currently seeking internship opportunities in Data Analysis, Business Intelligence, and Machine Learning.',
          style: TextStyle(fontSize: 15, height: 1.6),
        ),
      ),
    );
  }

  Widget _buildSkills() {
    final skills = ['Python', 'SQL', 'Power BI', 'Tableau', 'Excel', 'Machine Learning'];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: skills
          .map((skill) => Chip(
        label: Text(skill),
        backgroundColor: Colors.blue.shade50,
        side: const BorderSide(color: Colors.blue),
      ))
          .toList(),
    );
  }

  Widget _buildProjects() {
    return Column(
      children: [
        _projectCard('E-commerce Sales Dashboard', 'Python & Power BI', '2 months ago'),
        const SizedBox(height: 12),
        _projectCard('Student Management System', 'Flutter + Firebase', '1 month ago'),
      ],
    );
  }

  Widget _projectCard(String title, String subtitle, String time) {
    return Card(
      child: ListTile(
        leading: const Icon(Iconsax.code, color: Colors.blue, size: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ),
    );
  }

  Widget _buildEducation() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Iconsax.book, color: Colors.blue),
              title: Text('B.Sc. Computer Science'),
              subtitle: Text('Tribhuvan University • 2022 - Present'),
              trailing: Text('3.75 CGPA'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeCard() {
    return Card(
      child: ListTile(
        leading: const Icon(Iconsax.document_text, color: Colors.blue, size: 40),
        title: const Text('Resume.pdf'),
        subtitle: const Text('Updated 3 days ago'),
        trailing: ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Resume downloaded (Demo)')),
            );
          },
          icon: const Icon(Iconsax.arrow_down),
          label: const Text('Download'),
        ),
      ),
    );
  }
}