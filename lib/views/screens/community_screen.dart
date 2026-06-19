import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:be_practical18/models/community_post.dart';
import 'package:be_practical18/viewmodels/community_viewmodel.dart';


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
              const Text('Success Stories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '🎉 Congratulations to Sujal who got selected as Data Science Intern at F1Soft!\n\n"Never stop applying and keep learning" - Sujal',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Iconsax.add),
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
        trailing: Text(post.answers, style: const TextStyle(color: Colors.blue)),
      ),
    );
  }
}