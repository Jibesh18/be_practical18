import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/spacing.dart';
import '../components/buttons/primary_button.dart';
import '../viewmodel/auth_provider.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final code = ref.read(authProvider).generatedCode;
      if (code != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('GMAIL: Your Be Practical code is $code'),
            duration: const Duration(seconds: 10),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Text('Verify Gmail',
                style: AppTextStyles.display.copyWith(color: Colors.black, fontWeight: FontWeight.w900)
            ),
            const SizedBox(height: 12),
            const Text(
              'Enter the 4-digit code sent to your email to activate your account.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 48),
            Container(
              width: 240,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accent, width: 2),
                boxShadow: [
                  BoxShadow(color: AppColors.accent.withOpacity(0.1), blurRadius: 20)
                ],
              ),
              child: TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 40, letterSpacing: 20, fontWeight: FontWeight.bold, color: Colors.black),
                decoration: const InputDecoration(border: InputBorder.none, counterText: ""),
              ),
            ).animate().shake(),
            const Spacer(),
            if (authState.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(authState.error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            PrimaryButton(
              label: 'VERIFY & FINISH',
              isLoading: authState.isLoading,
              onPressed: () async {
                final bool success = await ref.read(authProvider.notifier).verifyCode(_codeController.text);
                if (success && context.mounted) {
                  context.go('/home');
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}