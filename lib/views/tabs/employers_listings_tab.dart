import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/internship_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_textstyles.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/employer_viewmodel.dart';

class EmployerListingsTab extends StatefulWidget {
  const EmployerListingsTab({super.key});

  @override
  State<EmployerListingsTab> createState() => _EmployerListingsTabState();
}

class _EmployerListingsTabState extends State<EmployerListingsTab> {
  final _searchC = TextEditingController();
  String _selectedType = 'All';
  String _selectedStatus = 'All';

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  String _statusLabel(InternshipModel item) {
    if (item.isEnded) return 'Ended';
    if (item.isPaused) return 'Paused';
    return 'Active';
  }

  bool _matches(InternshipModel item) {
    final q = _searchC.text.trim().toLowerCase();
    final matchesQuery = q.isEmpty ||
        item.title.toLowerCase().contains(q) ||
        item.company.toLowerCase().contains(q) ||
        item.skills.any((s) => s.toLowerCase().contains(q));
    final matchesType = _selectedType == 'All' || item.type == _selectedType;
    final matchesStatus =
        _selectedStatus == 'All' || _statusLabel(item) == _selectedStatus;
    return matchesQuery && matchesType && matchesStatus;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EmployerViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Center(child: Text('Not logged in'));
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Listings',
                    style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Manage your internship posts',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    )),
              ],
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchC,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search title, skill, location...',
                prefixIcon: const Icon(Iconsax.search_normal, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: ['All', 'Remote', 'On-site', 'Hybrid']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedType = v ?? 'All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    // NEW: 3-state filter now includes 'Ended'
                    items: ['All', 'Active', 'Paused', 'Ended']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedStatus = v ?? 'All'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // List
          Expanded(
            child: StreamBuilder<List<InternshipModel>>(
              stream: vm.getMyListings(user.uid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = (snap.data ?? []).where(_matches).toList();
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.briefcase, size: 56,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        const SizedBox(height: 16),
                        Text(
                          snap.data?.isEmpty == true
                              ? 'No listings yet.\nTap + to post one!'
                              : 'No results found.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: items.length,
                  itemBuilder: (context, i) => _ListingCard(listing: items[i], vm: vm),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final InternshipModel listing;
  final EmployerViewModel vm;

  const _ListingCard({required this.listing, required this.vm});

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditInternshipSheet(listing: listing, vm: vm),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Listing?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('This will permanently delete "${listing.title}".'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              vm.deleteInternship(listing.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // NEW: Confirmation dialog for ending an internship — explains this is
  // permanent and irreversible before allowing it.
  void _confirmEnd(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('End this internship?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
          'This permanently closes "${listing.title}". It will no longer be '
              'visible to interns and cannot be reopened. This is different from '
              'pausing — you cannot undo this action.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              vm.endInternship(listing.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightTextSecondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('End Internship', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _statusColor() {
    if (listing.isEnded) return AppColors.lightTextSecondary;
    if (listing.isPaused) return AppColors.warning;
    return AppColors.success;
  }

  String _statusLabel() {
    if (listing.isEnded) return 'Ended';
    if (listing.isPaused) return 'Paused';
    return 'Active';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _statusColor();
    final ended = listing.isEnded;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: ended
              ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
              : (listing.isLive
              ? AppColors.primary.withOpacity(0.25)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      // Ended listings appear slightly dimmed to signal they're inactive history
      child: Opacity(
        opacity: ended ? 0.7 : 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(listing.title,
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
                ),
                // Status badge — tappable to toggle ONLY when not ended
                GestureDetector(
                  onTap: ended
                      ? null
                      : () => vm.toggleStatus(listing.id, listing.isActive),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withOpacity(0.4)),
                    ),
                    child: Text(
                      _statusLabel(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${listing.company} · ${listing.location} · ${listing.type}',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(listing.stipend,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.success, fontWeight: FontWeight.w600,
                )),
            if (listing.skills.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6, runSpacing: 6,
                children: listing.skills.take(4).map((s) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(s,
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                )).toList(),
              ),
            ],
            const SizedBox(height: 14),
            if (ended)
            // Ended listings are read-only history — only Delete remains
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Iconsax.trash, size: 14),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showEditSheet(context),
                      icon: const Icon(Iconsax.edit, size: 14),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // NEW: End Internship button — permanent close
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmEnd(context),
                      icon: const Icon(Iconsax.slash, size: 14),
                      label: const Text('End'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.lightTextSecondary,
                        side: BorderSide(color: AppColors.lightTextSecondary.withOpacity(0.4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmDelete(context),
                      icon: const Icon(Iconsax.trash, size: 14),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error.withOpacity(0.4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ── Edit Internship Sheet ───────────────────────────────────────────────────

class _EditInternshipSheet extends StatefulWidget {
  final InternshipModel listing;
  final EmployerViewModel vm;

  const _EditInternshipSheet({required this.listing, required this.vm});

  @override
  State<_EditInternshipSheet> createState() => _EditInternshipSheetState();
}

class _EditInternshipSheetState extends State<_EditInternshipSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleC;
  late final TextEditingController _companyC;
  late final TextEditingController _locationC;
  late final TextEditingController _durationC;
  late final TextEditingController _stipendC;
  late final TextEditingController _descriptionC;
  late final TextEditingController _requirementsC;
  late final TextEditingController _skillC;
  late String _type;
  late List<String> _skills;

  @override
  void initState() {
    super.initState();
    final l = widget.listing;
    _titleC        = TextEditingController(text: l.title);
    _companyC      = TextEditingController(text: l.company);
    _locationC     = TextEditingController(text: l.location);
    _durationC     = TextEditingController(text: l.duration);
    _stipendC      = TextEditingController(text: l.stipend);
    _descriptionC  = TextEditingController(text: l.description);
    _requirementsC = TextEditingController(text: l.requirements);
    _skillC        = TextEditingController();
    _type          = l.type;
    _skills        = List.from(l.skills);
  }

  @override
  void dispose() {
    for (final c in [_titleC, _companyC, _locationC, _durationC,
      _stipendC, _descriptionC, _requirementsC, _skillC]) {
      c.dispose();
    }
    super.dispose();
  }

  void _addSkill() {
    final s = _skillC.text.trim();
    if (s.isEmpty || _skills.contains(s)) return;
    setState(() { _skills.add(s); _skillC.clear(); });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await widget.vm.updateInternship(
      id: widget.listing.id,
      title: _titleC.text.trim(),
      company: _companyC.text.trim(),
      location: _locationC.text.trim(),
      type: _type,
      duration: _durationC.text.trim(),
      stipend: _stipendC.text.trim(),
      description: _descriptionC.text.trim(),
      requirements: _requirementsC.text.trim(),
      skills: List.from(_skills),
      isActive: widget.listing.isActive,
      postedBy: widget.listing.postedBy,
      employerName: widget.listing.employerName,
      postedAt: widget.listing.postedAt,
    );
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? 'Internship updated!' : widget.vm.updateError ?? 'Something went wrong'),
      backgroundColor: success ? AppColors.success : AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.97,
      minChildSize: 0.6,
      builder: (_, scrollC) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBg : AppColors.lightBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text('Edit Internship',
                      style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.w800)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: scrollC,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _field(_titleC, 'Job Title', Iconsax.briefcase),
                    _field(_companyC, 'Company Name', Iconsax.building),
                    _field(_locationC, 'Location', Iconsax.location),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Work Type', style: AppTextStyles.labelMedium),
                          const SizedBox(height: 8),
                          Row(
                            children: ['Remote', 'On-site', 'Hybrid'].map((t) =>
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(t),
                                    selected: _type == t,
                                    onSelected: (_) => setState(() => _type = t),
                                    selectedColor: AppColors.primary.withOpacity(0.15),
                                    labelStyle: AppTextStyles.labelSmall.copyWith(
                                      color: _type == t ? AppColors.primary : null,
                                    ),
                                    checkmarkColor: AppColors.primary,
                                  ),
                                ),
                            ).toList(),
                          ),
                        ],
                      ),
                    ),
                    Row(children: [
                      Expanded(child: _field(_durationC, 'Duration', Iconsax.clock)),
                      const SizedBox(width: 12),
                      Expanded(child: _field(_stipendC, 'Stipend', Iconsax.money)),
                    ]),
                    _field(_descriptionC, 'Description', Iconsax.document, maxLines: 4),
                    _field(_requirementsC, 'Requirements', Iconsax.tick_circle, maxLines: 3),
                    Text('Required Skills', style: AppTextStyles.labelMedium),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: _skillC,
                          decoration: InputDecoration(
                            hintText: 'e.g. Flutter',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onFieldSubmitted: (_) => _addSkill(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filled(
                        onPressed: _addSkill,
                        icon: const Icon(Icons.add_rounded),
                        style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                      ),
                    ]),
                    if (_skills.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: _skills.map((s) => Chip(
                          label: Text(s, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                          backgroundColor: AppColors.primary.withOpacity(0.08),
                          deleteIcon: const Icon(Icons.close_rounded, size: 14, color: AppColors.primary),
                          onDeleted: () => setState(() => _skills.remove(s)),
                        )).toList(),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Consumer<EmployerViewModel>(
                      builder: (_, vm, __) => SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: vm.isUpdating ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: vm.isUpdating
                              ? const SizedBox(width: 22, height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                              : Text('Update Internship',
                              style: AppTextStyles.button.copyWith(color: Colors.white)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: maxLines == 1 ? Icon(icon, size: 20) : null,
          alignLabelWithHint: maxLines > 1,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
      ),
    );
  }
}