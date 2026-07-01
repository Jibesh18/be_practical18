import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class CommunityPostDetailScreen extends StatefulWidget {
  final String question;
  final String author;

  const CommunityPostDetailScreen({
    super.key,
    required this.question,
    required this.author,
  });

  @override
  State<CommunityPostDetailScreen> createState() => _CommunityPostDetailScreenState();
}

class _CommunityPostDetailScreenState extends State<CommunityPostDetailScreen> {
  final TextEditingController _answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discussion')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.question, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Asked by ${widget.author}', style: const TextStyle(color: Colors.grey)),

            const Divider(height: 30),

            const Text('Answers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            _answerCard('Great question! Start with understanding the company and common tools used.', 'Rahul Sharma'),
            _answerCard('Focus on SQL, Python, and Power BI. Practice mock interviews.', 'Priya Thapa'),
            _answerCard('LeetCode + "Cracking the Coding Interview" book is very helpful.', 'Sujan KC'),

            const SizedBox(height: 30),

            const Text('Add Your Answer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            TextField(
              controller: _answerController,
              decoration: const InputDecoration(
                hintText: 'Write your answer here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_answerController.text.trim().isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Answer posted successfully!')),
                    );
                    _answerController.clear();
                  }
                },
                child: const Text('Post Answer'),
              ),
            ),
          ],
        ),
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