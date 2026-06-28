import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class CommunityPostDetailScreen extends StatelessWidget {
  final String question;
  final String author;

  const CommunityPostDetailScreen({
    super.key,
    required this.question,
    required this.author,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussion'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Asked by $author', style: const TextStyle(color: Colors.grey)),
            const Divider(height: 30),

            const Text('Answers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Sample Answers
            _answerCard('Great question! First, understand the company culture...', 'Rahul Sharma'),
            _answerCard('Focus on behavioral questions and system design.', 'Priya Thapa'),
            _answerCard('Practice on LeetCode and read "Cracking the Coding Interview".', 'Sujan KC'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new answer
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Answer posted!')),
          );
        },
        child: const Icon(Iconsax.add),
      ),
    );
  }

  Widget _answerCard(String answer, String author) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(answer),
            const SizedBox(height: 8),
            Text('— $author', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}