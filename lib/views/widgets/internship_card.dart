import 'package:flutter/material.dart';
import '../../models/internship_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_textstyles.dart';

class InternshipCard extends StatelessWidget {
  final InternshipModel internship;
  final VoidCallback? onApply;
  final VoidCallback? onTap;
  final bool isApplied;
  final bool isApplying;

  const InternshipCard({
    super.key,
    required this.internship,
    this.onApply,
    this.onTap,
    this.isApplied = false,
    this.isApplying = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? AppColors.darkBorder
                : const Color(0xFFE8EDF5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row: avatar + title + type badge ──────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CompanyAvatar(name: internship.company),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          internship.title,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          internship.company,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _TypeBadge(type: internship.type),
                ],
              ),

              const SizedBox(height: 14),
              _Divider(isDark: isDark),
              const SizedBox(height: 12),

              // ── Meta row: location · duration · stipend ────────────────
              Wrap(
                spacing: 18,
                runSpacing: 6,
                children: [
                  _MetaChip(
                    icon: Icons.location_on_outlined,
                    label: internship.location,
                    isDark: isDark,
                  ),
                  _MetaChip(
                    icon: Icons.schedule_rounded,
                    label: internship.duration,
                    isDark: isDark,
                  ),
                  _MetaChip(
                    icon: Icons.payments_outlined,
                    label: internship.stipend,
                    isDark: isDark,
                    highlight: true,
                  ),
                ],
              ),

              // ── Skills ────────────────────────────────────────────────
              if (internship.skills.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: internship.skills
                      .take(4)
                      .map((s) => _SkillChip(label: s))
                      .toList(),
                ),
              ],

              const SizedBox(height: 14),

              // ── Apply button ──────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 46,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: isApplied
                      ? _AppliedBadge(key: const ValueKey('applied'))
                      : ElevatedButton(
                    key: const ValueKey('apply'),
                    onPressed: isApplying ? null : onApply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                      AppColors.primary.withOpacity(0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isApplying
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      'Apply Now',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

class _CompanyAvatar extends StatelessWidget {
  final String name;
  const _CompanyAvatar({required this.name});

  /// Pick a consistent accent colour from the company name
  Color _avatarColor() {
    const colours = [
      Color(0xFF4F46E5),
      Color(0xFF0EA5E9),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
    ];
    return colours[name.codeUnitAt(0) % colours.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _avatarColor();
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25), width: 1.2),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  Color get _color {
    switch (type.toLowerCase()) {
      case 'remote':
        return const Color(0xFF10B981); // green
      case 'on-site':
        return const Color(0xFF3B82F6); // blue
      default:
        return const Color(0xFFF59E0B); // amber for hybrid
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final bool highlight;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.isDark,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlight
        ? const Color(0xFF10B981)
        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  const _SkillChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.18),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AppliedBadge extends StatelessWidget {
  const _AppliedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.35),
          width: 1.2,
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded,
              size: 18, color: Color(0xFF10B981)),
          SizedBox(width: 8),
          Text(
            'Applied',
            style: TextStyle(
              color: Color(0xFF10B981),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: isDark
          ? AppColors.darkBorder.withOpacity(0.5)
          : const Color(0xFFEEF2F8),
    );
  }
}