import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/resource_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_textstyles.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/internship_viewmodel.dart';
import '../../viewmodels/resource_provider.dart';
import '../screens/intern_detail_screen.dart';
import '../widgets/internship_card.dart';
import '../widgets/incomplete_profile_dialog.dart';

// FIXED: This used to be a bare Column with no Scaffold, which was fine
// while it lived inside InternHomeTab's IndexedStack (that Scaffold
// supplied the Material ancestor every TextField/FilterChip needs). Now
// that Search is reached via Navigator.push instead of a bottom-nav tab,
// it needs its own Scaffold — otherwise TextField/FilterChip crash with
// "No Material widget found" and the search bar appears broken.
//
// UPDATED: converted to StatefulWidget so it can fetch resources once on
// load (same pattern ResourcesTab already uses), and added an Internships/
// Resources toggle so one search box covers both — previously this only
// ever searched InternshipModel fields, so resources were unreachable
// from search entirely.
class InternSearchTab extends StatefulWidget {
  const InternSearchTab({super.key});

  @override
  State<InternSearchTab> createState() => _InternSearchTabState();
}

enum _SearchScope { internships, resources }

class _InternSearchTabState extends State<InternSearchTab> {
  _SearchScope _scope = _SearchScope.internships;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResourcesViewModel>().fetchResources();
    });
  }

  Future<void> _openResource(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This resource has no link yet.')),
      );
      return;
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  IconData _resourceIcon(String name) {
    switch (name) {
      case 'phone':
        return Icons.phone_android_rounded;
      case 'code':
        return Icons.code_rounded;
      case 'design':
        return Icons.design_services_rounded;
      case 'cloud':
        return Icons.cloud_rounded;
      case 'web':
        return Icons.web_rounded;
      case 'school':
      default:
        return Icons.school_rounded;
    }
  }

  List<ResourceModel> _filterResources(List<ResourceModel> all, String query) {
    if (query.isEmpty) return all;
    final q = query.toLowerCase();
    return all.where((r) =>
    r.title.toLowerCase().contains(q) ||
        r.provider.toLowerCase().contains(q) ||
        r.category.toLowerCase().contains(q) ||
        r.description.toLowerCase().contains(q)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final internVM = context.watch<InternshipViewModel>();
    final resourcesVM = context.watch<ResourcesViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Search',
            style: AppTextStyles.titleMedium.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontWeight: FontWeight.w600,
            )),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Search bar ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                onChanged: internVM.setSearchQuery,
                decoration: InputDecoration(
                  hintText: _scope == _SearchScope.internships
                      ? 'Search by title, company, skill...'
                      : 'Search resources, providers, categories...',
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

            // ── Internships / Resources toggle ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _ScopeChip(
                      label: 'Internships',
                      selected: _scope == _SearchScope.internships,
                      onTap: () => setState(() => _scope = _SearchScope.internships),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ScopeChip(
                      label: 'Resources',
                      selected: _scope == _SearchScope.resources,
                      onTap: () => setState(() => _scope = _SearchScope.resources),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── Filter chips (internships only) ────────────────────────────────
            if (_scope == _SearchScope.internships)
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
              child: _scope == _SearchScope.internships
                  ? StreamBuilder(
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
              )
                  : Builder(
                builder: (context) {
                  if (resourcesVM.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final filtered = _filterResources(resourcesVM.resources, internVM.searchQuery);

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
                          Text('No resources found', style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final r = filtered[index];
                      return GestureDetector(
                        onTap: () => _openResource(context, r.url),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(_resourceIcon(r.iconName), color: AppColors.primary, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(r.title, style: AppTextStyles.titleMedium,
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                    if (r.provider.isNotEmpty)
                                      Text(r.provider,
                                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                                    const SizedBox(height: 4),
                                    Text(r.description,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary,
                                        ),
                                        maxLines: 2, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.open_in_new_rounded, size: 16,
                                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScopeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;
  const _ScopeChip({required this.label, required this.selected, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : (isDark ? AppColors.darkSurface : AppColors.lightDivider),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
            style: AppTextStyles.labelMedium.copyWith(
              color: selected ? Colors.white : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              fontWeight: FontWeight.w600,
            )),
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

    final authVM = context.read<AuthViewModel>();
    final profile = await authVM.getUserProfile(widget.userId!);
    if (!(profile?.isProfileComplete ?? false)) {
      if (!mounted) return;
      showIncompleteProfileDialog(context);
      return;
    }

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
              ? 'Applied to ${widget.internship.company}!'
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
      onTap: _openDetail,
      onApply: (widget.userId == null || (_hasApplied ?? false)) ? null : _apply,
    );
  }
}