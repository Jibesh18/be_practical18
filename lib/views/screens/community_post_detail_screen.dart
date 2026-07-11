import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/community_answer.dart';
import '../../models/community_post.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_textstyles.dart';
import '../../viewmodels/community_viewmodel.dart';

class CommunityPostDetailScreen extends StatefulWidget {
  final CommunityPost post;
  const CommunityPostDetailScreen({super.key, required this.post});

  @override
  State<CommunityPostDetailScreen> createState() => _CommunityPostDetailScreenState();
}

class _CommunityPostDetailScreenState extends State<CommunityPostDetailScreen> {
  final _answerController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _sendAnswer() async {
    final text = _answerController.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    final vm = context.read<CommunityViewModel>();
    final success = await vm.addAnswer(postId: widget.post.id, text: text);
    if (!mounted) return;
    setState(() => _sending = false);

    if (success) {
      _answerController.clear();
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.answerError ?? 'Something went wrong.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vm = context.watch<CommunityViewModel>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        title: Text('Discussion',
            style: AppTextStyles.titleMedium.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            )),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Question ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.post.question,
                          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Iconsax.user, size: 14,
                              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                          const SizedBox(width: 4),
                          Text(widget.post.authorName,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Answers ──
                Text('Answers',
                    style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                StreamBuilder<List<CommunityAnswer>>(
                  stream: vm.answersFor(widget.post.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final answers = snapshot.data ?? [];
                    if (answers.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'No answers yet — be the first to help!',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: answers
                          .map((a) => Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.text, style: AppTextStyles.bodyMedium),
                            const SizedBox(height: 8),
                            Text(a.authorName,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                      ))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),

          // ── Reply box ──
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _answerController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Write an answer...',
                        filled: true,
                        fillColor: isDark ? AppColors.darkBg : AppColors.lightDivider,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _sending
                      ? const SizedBox(
                    width: 40, height: 40,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                      : IconButton.filled(
                    onPressed: _sendAnswer,
                    icon: const Icon(Icons.send_rounded, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      foregroundColor: isDark ? AppColors.darkBg : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}