import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_textstyles.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/internship_viewmodel.dart';
import '../screens/intern_detail_screen.dart';
import '../widgets/internship_card.dart';

class InternSearchTab extends StatelessWidget {
  const InternSearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    final internVM = context.watch<InternshipViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: internVM.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search by title, company, skill...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: internVM.searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: internVM.clearFilters,
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
              ),
            ),
          ),

          // ── Filter chips ────────────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (final type in ['All', 'Remote', 'On-site', 'Hybrid'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(type),
                      selected: internVM.selectedType == type,
                      onSelected: (_) => internVM.setType(type),
                      selectedColor: AppColors.primary.withOpacity(0.15),
                      checkmarkColor: AppColors.primary,
                      labelStyle: AppTextStyles.labelSmall.copyWith(
                        color: internVM.selectedType == type
                            ? AppColors.primary
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Results ─────────────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder(
              stream: internVM.allInternships,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading internships',
                      style: AppTextStyles.bodyMedium,
                    ),
                  );
                }

                final all = snapshot.data ?? [];
                final filtered = internVM.applyFilters(all);

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No internships found',
                          style: AppTextStyles.bodyMedium,
                        ),
                        TextButton(
                          onPressed: internVM.clearFilters,
                          child: const Text('Clear filters'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final internship = filtered[index];
                    return _ApplyableSearchCard(
                      internship: internship,
                      userId: user?.uid,
                      userName: user?.displayName,
                      userEmail: user?.email,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Stateful wrapper so each card tracks its own applying state
/// and checks applied status independently.
class _ApplyableSearchCard extends StatefulWidget {
  final dynamic internship; // InternshipModel
  final String? userId;
  final String? userName;
  final String? userEmail;

  const _ApplyableSearchCard({
    required this.internship,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<_ApplyableSearchCard> createState() => _ApplyableSearchCardState();
}

class _ApplyableSearchCardState extends State<_ApplyableSearchCard> {
  bool _applying = false;
  // null = not checked yet, true/false = checked
  bool? _hasApplied;

  @override
  void initState() {
    super.initState();
    _checkApplied();
  }

  Future<void> _checkApplied() async {
    if (widget.userId == null) return;
    final vm = context.read<InternshipViewModel>();
    final result = await vm.hasApplied(widget.internship.id, widget.userId!);
    if (mounted) setState(() => _hasApplied = result);
  }

  Future<void> _apply() async {
    if (widget.userId == null || _applying) return;
    setState(() => _applying = true);

    final vm = context.read<InternshipViewModel>();
    final success = await vm.apply(
      internship: widget.internship,
      applicantId: widget.userId!,
      applicantName: widget.userName ?? 'Anonymous',
      applicantEmail: widget.userEmail ?? '',
    );

    if (!mounted) return;
    setState(() {
      _applying = false;
      if (success) _hasApplied = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Applied to ${widget.internship.company}! 🎉'
              : vm.applyError ?? 'Something went wrong.',
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ← ADDED: navigates to the detail screen on tap
  void _openDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InternshipDetailScreen(internship: widget.internship),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InternshipCard(
      internship: widget.internship,
      isApplied: _hasApplied ?? false,
      isApplying: _applying,
      onTap: _openDetail,   // ← ADDED: was missing before
      // If no user logged in OR already applied → no onApply
      onApply: (widget.userId == null || (_hasApplied ?? false)) ? null : _apply,
    );
  }
}