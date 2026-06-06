import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/spacing.dart';
import '../components/buttons/primary_button.dart';
import '../components/buttons/secondary_button.dart';
import '../viewmodel/auth_provider.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  Timer? _pollingTimer;
  int _resendCooldown = 60;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    // Auto-check every 5 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkVerification();
    });
    _startCooldown();
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _checkVerification() async {
    final success = await ref.read(authProvider.notifier).checkVerificationStatus();
    if (success && mounted) {
      _pollingTimer?.cancel();
      _cooldownTimer?.cancel();
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _cooldownTimer?.cancel();
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
          onPressed: () {
            ref.read(authProvider.notifier).logout();
            context.go('/login');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_read_rounded, size: 80, color: AppColors.accent)
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 2.seconds, color: AppColors.primary),
            const SizedBox(height: 24),
            Text('Check your email',
                style: AppTextStyles.display.copyWith(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 32)
            ),
            const SizedBox(height: 16),
            const Text(
              'We sent a verification link to your email address. Please click the link to activate your account.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 48),
            
            if (authState.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(authState.error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            if (authState.successMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(authState.successMessage!, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
              ),

            PrimaryButton(
              label: "I've verified my email",
              isLoading: authState.isLoading,
              onPressed: _checkVerification,
            ),
            const SizedBox(height: 16),
            SecondaryButton(
              label: _resendCooldown > 0 ? "Resend Email in ${_resendCooldown}s" : "Resend Email",
              icon: Icons.refresh_rounded,
              onPressed: _resendCooldown > 0 ? () {} : () async {
                await ref.read(authProvider.notifier).resendVerification();
                _startCooldown();
              },
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
            const SizedBox(height: 16),
            const Text('Waiting for verification...', style: TextStyle(color: AppColors.muted, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
