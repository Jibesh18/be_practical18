import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/community_post.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_textstyles.dart';
import '../../viewmodels/community_viewmodel.dart';
import '../screens/community_post_detail_screen.dart';

// FIXED: this class used to be named CommunityScreen, but intern_screen.dart
// imports and uses it as CommunityTab — that mismatch would have caused a
// build error the moment this file was actually compiled alongside the
// redesigned home screen. Renamed here to match.
class CommunityTab extends StatelessWidget {
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vm = context.watch<CommunityViewModel>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        title: Text('Community',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            )),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAskQuestionSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ask'),
        backgroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        foregroundColor: isDark ? AppColors.darkBg : Colors.white,
      ),
      body: StreamBuilder<List<CommunityPost>>(
        stream: vm.posts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Something went wrong loading the community.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
              ),
            );
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.people,
                        size: 56,
                        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                    const SizedBox(height: 16),
                    Text('No discussions yet',
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(
                      'Ask the first question and get the community talking.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              Text('Recent Discussions',
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ...posts.map((post) => _PostCard(post: post, isDark: isDark)),
            ],
          );
        },
      ),
    );
  }

  void _showAskQuestionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AskQuestionSheet(),
    );
  }
}

class _PostCard extends StatelessWidget {
  final CommunityPost post;
  final bool isDark;
  const _PostCard({required this.post, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CommunityPostDetailScreen(post: post)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.question,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Iconsax.user, size: 14,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                const SizedBox(width: 4),
                Text(post.authorName,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    )),
                const Spacer(),
                Icon(Iconsax.message, size: 14,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                const SizedBox(width: 4),
                Text(post.answersLabel,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AskQuestionSheet extends StatefulWidget {
  const _AskQuestionSheet();

  @override
  State<_AskQuestionSheet> createState() => _AskQuestionSheetState();
}

class _AskQuestionSheetState extends State<_AskQuestionSheet> {
  final _controller = TextEditingController();
  bool _posting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_posting) return;
    setState(() => _posting = true);

    final vm = context.read<CommunityViewModel>();
    final success = await vm.addPost(_controller.text);

    if (!mounted) return;
    setState(() => _posting = false);

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.postError ?? 'Something went wrong.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBg : AppColors.lightBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text('Ask the community',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              autofocus: true,
              minLines: 2,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'e.g. How to prepare for a Flutter internship interview?',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _posting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  foregroundColor: isDark ? AppColors.darkBg : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _posting
                    ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
                    : const Text('Post question'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}