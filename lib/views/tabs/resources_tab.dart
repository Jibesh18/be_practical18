import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../themes/app_colors.dart';
import '../../themes/app_textstyles.dart';
import '../../viewmodels/resource_provider.dart';

class ResourcesTab extends StatefulWidget {
  const ResourcesTab({super.key});

  @override
  State<ResourcesTab> createState() => _ResourcesTabState();
}

class _ResourcesTabState extends State<ResourcesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResourcesViewModel>().fetchResources();
    });
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  IconData _iconFromName(String name) {
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResourcesViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
          ? Center(child: Text(provider.errorMessage!))
          : CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Free Resources',
                      style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Upgrade your skills with free certificates',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final r = provider.resources[index];
                  return GestureDetector(
                    onTap: () => _open(r.url),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
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
                            child: Icon(
                              _iconFromName(r.iconName),
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        r.title,
                                        style: AppTextStyles.titleMedium,
                                      ),
                                    ),
                                    Container(
                                      padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.success
                                            .withOpacity(0.12),
                                        borderRadius:
                                        BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        r.category,
                                        style: AppTextStyles.labelSmall
                                            .copyWith(
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  r.provider,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  r.description,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.open_in_new_rounded,
                            size: 16,
                            color: AppColors.lightTextTertiary,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: provider.resources.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}