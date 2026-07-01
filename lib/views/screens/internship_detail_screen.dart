import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';   // Uncomment later

class InternshipDetailScreen extends StatelessWidget {
  final String id;
  final String title;
  final String company;
  final String location;
  final String stipend;

  const InternshipDetailScreen({
    super.key,
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.stipend,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(company, style: const TextStyle(fontSize: 18)),
            Text('$location • Full-time', style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 20),
            Text('₹$stipend / month', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),

            const SizedBox(height: 30),

            const Text('About the Company', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text(
              'ABC Tech is a leading software company in Nepal specializing in mobile and web development.',
              style: TextStyle(fontSize: 15, height: 1.5),
            ),

            const SizedBox(height: 24),

            const Text('Job Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text(
              '• Develop cross-platform mobile applications using Flutter\n'
                  '• Work with Firebase backend\n'
                  '• Collaborate with senior developers\n'
                  '• Learn modern software development practices',
              style: TextStyle(fontSize: 15, height: 1.6),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Application submitted successfully!')),
                  );
                },
                child: const Text('Apply for this Position'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


//Later when you connect Firebase, you can replace the hardcoded data with this:
// Future to fetch from Firebase
// Future<DocumentSnapshot> getInternshipDetails(String id) async {
//   return await FirebaseFirestore.instance.collection('internships').doc(id).get();
// }