import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/community_post.dart';
import '../../viewmodels/community_viewmodel.dart';
import 'community_post_detail_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Consumer<CommunityViewModel>(
        builder: (context, viewModel, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Recent Discussions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...viewModel.posts.map((post) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CommunityPostCard(post: post),
              )),

              const SizedBox(height: 30),

              // Success Stories Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Success Stories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () => _showShareJourneyDialog(context),
                    icon: const Icon(Iconsax.add, size: 18),
                    label: const Text('Share Your Journey'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '🎉 Congratulations to Sujal who got selected as Data Science Intern at F1Soft!\n\n'
                        '"Never stop applying and keep learning" - Sujal',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAskQuestionDialog(context),
        child: const Icon(Iconsax.add),
      ),
    );
  }

  // Ask Question Dialog
  void _showAskQuestionDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ask a Question'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'What do you want to ask?'),
          maxLines: 4,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Question posted!')),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  // Share Journey Dialog
  void _showShareJourneyDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController storyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Your Success Story'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Title (e.g. Got Selected at XYZ)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: storyController,
              decoration: const InputDecoration(hintText: 'Share your journey...'),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (storyController.text.trim().isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Success story shared! 🎉')),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Share Story'),
          ),
        ],
      ),
    );
  }
}

class CommunityPostCard extends StatelessWidget {
  final CommunityPost post;

  const CommunityPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Iconsax.people)),
        title: Text(post.question, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(post.author),
        trailing: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommunityPostDetailScreen(
                  question: post.question,
                  author: post.author,
                ),
              ),
            );
          },
          child: Text(
            post.answers,
            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}