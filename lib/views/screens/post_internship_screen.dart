import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class PostInternshipScreen extends StatefulWidget {
  const PostInternshipScreen({super.key});

  @override
  State<PostInternshipScreen> createState() => _PostInternshipScreenState();
}

class _PostInternshipScreenState extends State<PostInternshipScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post New Internship')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(decoration: const InputDecoration(labelText: 'Internship Title'),),
              const SizedBox(height: 16),
              TextFormField(decoration: const InputDecoration(labelText: 'Location'),),
              const SizedBox(height: 16),
              TextFormField(decoration: const InputDecoration(labelText: 'Stipend'),),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 5,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Post Internship', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}