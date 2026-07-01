import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/application_model.dart';
import '../../models/internship_model.dart';
import '../../services/ai_services.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_textstyles.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/employer_viewmodel.dart';

const _kLogoBlue   = Color(0xFF1D4BAE);
const _kBlueBright = Color(0xFF4A7FE0);

// FIXED: Removed `required this.employerId` constructor parameter.
// The widget now reads the employer UID from AuthViewModel internally,
// exactly like EmployerListingsTab, EmployerProfileTab, etc.
// This is why `const EmployerSuggestionsTab()` now compiles correctly.
class EmployerSuggestionsTab extends StatefulWidget {
  const EmployerSuggestionsTab({super.key}); // ← FIXED: no more required employerId

  @override
  State<EmployerSuggestionsTab> createState() => _EmployerSuggestionsTabState();
}

class _EmployerSuggestionsTabState extends State<EmployerSuggestionsTab> {
  Map<String, String?> _aiResults = {}; // internshipId → AI suggestion text
  Map<String, bool> _loading = {};      // internshipId → isLoading

  Future<void> _getAISuggestion(
      BuildContext context,
      InternshipModel listing,
      List<ApplicationModel> applicants,
      ) async {
    if (_loading[listing.id] == true) return;

    setState(() => _loading[listing.id] = true);

    try {
      final applicantDetails = applicants.map((a) =>
      '- ${a.applicantName} (${a.applicantEmail}) – Status: ${a.status}'
      ).join('\n');

      final prompt = '''
You are an expert HR advisor helping an employer choose the best intern.

Internship: ${listing.title}
Company: ${listing.company}
Location: ${listing.type} · ${listing.location}
Duration: ${listing.duration}
Required Skills: ${listing.skills.join(', ')}
Description: ${listing.description}
Requirements: ${listing.requirements}

Applicants who applied:
$applicantDetails

Based on the internship requirements and applicant information available, provide:
1. A brief analysis of what kind of candidate would be ideal (2-3 sentences)
2. If there are applicants, suggest which ones seem most promising based on their names/emails and the role, and why
3. 3-4 specific interview questions the employer should ask to identify the best fit
4. One red flag to watch out for when selecting

Keep your response concise, practical, and actionable. Format with clear sections.
''';

      final response = await _fetchSuggestion(prompt, listing);
      setState(() => _aiResults[listing.id] = response);
    } catch (e) {
      setState(() => _aiResults[listing.id] = 'Could not get AI suggestions. Please try again.');
    } finally {
      setState(() => _loading[listing.id] = false);
    }
  }

  Future<String> _fetchSuggestion(String prompt, InternshipModel listing) async {
    // Real Gemini API call via the shared AIService.
    const systemPrompt =
        'You are an expert HR advisor helping employers evaluate internship '
        'candidates. Be concise, practical, and structured with clear sections.';
    return AIService.ask(
      prompt: prompt,
      systemPrompt: systemPrompt,
      maxOutputTokens: 800,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EmployerViewModel>();
    final authVM = context.watch<AuthViewModel>(); // ← ADDED: read uid here
    final employerId = authVM.currentUser?.uid ?? ''; // ← ADDED
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              border: Border(bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_kLogoBlue, _kBlueBright],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Iconsax.magic_star, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI Candidate Picks',
                              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800)),
                          Text('Get smart suggestions for each listing',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Listings with AI suggestions
          Expanded(
            child: StreamBuilder<List<InternshipModel>>(
              stream: vm.getMyListings(employerId), // ← FIXED: uses local variable
              builder: (context, listSnap) {
                if (listSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final listings = listSnap.data ?? [];
                if (listings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.magic_star, size: 64,
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                        const SizedBox(height: 16),
                        Text('No listings yet.\nPost an internship to get AI suggestions.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            )),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: listings.length,
                  itemBuilder: (context, i) {
                    final listing = listings[i];
                    return StreamBuilder<List<ApplicationModel>>(
                      stream: vm.getApplicantsForInternship(listing.id, employerId),
                      builder: (context, appSnap) {
                        final applicants = appSnap.data ?? [];
                        return _ListingAICard(
                          listing: listing,
                          applicants: applicants,
                          aiResult: _aiResults[listing.id],
                          isLoading: _loading[listing.id] ?? false,
                          isDark: isDark,
                          onGetSuggestion: () => _getAISuggestion(context, listing, applicants),
                        );
                      },
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

// ── Listing AI Card ───────────────────────────────────────────────────────────

class _ListingAICard extends StatefulWidget {
  final InternshipModel listing;
  final List<ApplicationModel> applicants;
  final String? aiResult;
  final bool isLoading;
  final bool isDark;
  final VoidCallback onGetSuggestion;

  const _ListingAICard({
    required this.listing,
    required this.applicants,
    required this.aiResult,
    required this.isLoading,
    required this.isDark,
    required this.onGetSuggestion,
  });

  @override
  State<_ListingAICard> createState() => _ListingAICardState();
}

class _ListingAICardState extends State<_ListingAICard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasSuggestion = widget.aiResult != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasSuggestion
              ? _kLogoBlue.withOpacity(0.3)
              : (widget.isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Listing info header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: _kLogoBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      widget.listing.company.isNotEmpty ? widget.listing.company[0].toUpperCase() : '?',
                      style: const TextStyle(color: _kLogoBlue, fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.listing.title,
                          style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Iconsax.people, size: 12,
                              color: widget.isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.applicants.length} applicant${widget.applicants.length != 1 ? 's' : ''}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: _kLogoBlue, fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4, height: 4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(widget.listing.type,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: widget.isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.listing.isActive
                        ? const Color(0xFF10B981).withOpacity(0.12)
                        : AppColors.warning.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.listing.isActive ? 'Active' : 'Paused',
                    style: TextStyle(
                      color: widget.listing.isActive ? const Color(0xFF10B981) : AppColors.warning,
                      fontSize: 10, fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Skills chips
          if (widget.listing.skills.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Wrap(
                spacing: 6, runSpacing: 6,
                children: widget.listing.skills.take(4).map((s) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kLogoBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _kLogoBlue.withOpacity(0.2)),
                  ),
                  child: Text(s, style: const TextStyle(color: _kLogoBlue, fontSize: 11, fontWeight: FontWeight.w600)),
                )).toList(),
              ),
            ),

          const Divider(height: 1),

          // AI suggestion area
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!hasSuggestion && !widget.isLoading) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: widget.applicants.isEmpty ? null : widget.onGetSuggestion,
                      icon: const Icon(Iconsax.magic_star, size: 18),
                      label: Text(
                        widget.applicants.isEmpty ? 'No applicants yet' : 'Get AI Suggestions',
                        style: AppTextStyles.button.copyWith(fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kLogoBlue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: widget.isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  if (widget.applicants.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Share this listing to get applicants, then use AI to pick the best fit.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: widget.isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                        ),
                      ),
                    ),
                ] else if (widget.isLoading) ...[
                  Row(
                    children: [
                      SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: _kLogoBlue),
                      ),
                      const SizedBox(width: 12),
                      Text('Analysing applicants & role...',
                          style: AppTextStyles.bodyMedium.copyWith(color: _kLogoBlue)),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_kLogoBlue, _kBlueBright],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Iconsax.magic_star, color: Colors.white, size: 14),
                      ),
                      const SizedBox(width: 8),
                      Text('AI Suggestions',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: _kLogoBlue, fontWeight: FontWeight.w700,
                          )),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _expanded = !_expanded),
                        child: Row(
                          children: [
                            Text(_expanded ? 'Collapse' : 'Expand',
                                style: AppTextStyles.labelSmall.copyWith(color: _kLogoBlue)),
                            Icon(
                              _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              color: _kLogoBlue, size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 250),
                    crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    firstChild: Text(
                      widget.aiResult!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: widget.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        height: 1.6,
                      ),
                    ),
                    secondChild: Text(
                      widget.aiResult!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: widget.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: widget.onGetSuggestion,
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Refresh suggestions'),
                    style: TextButton.styleFrom(
                      foregroundColor: _kLogoBlue,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}