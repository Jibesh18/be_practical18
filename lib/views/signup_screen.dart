import 'dart:ui';
import 'package:flutter/material.dart';import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/spacing.dart';
import '../components/buttons/primary_button.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: _GlowOrb(color: AppColors.secondary, size: 300),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: -30, end: 30, duration: 5.seconds),

          Positioned(
            bottom: -100,
            right: -50,
            child: _GlowOrb(color: AppColors.accent, size: 350),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
              .moveX(begin: -40, end: 40, duration: 6.seconds),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 22),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Column(
                        children: [
                          const _BrandLogoBox().animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                          const SizedBox(height: 24),
                          Text(
                            'Join Be Practical',
                            style: AppTextStyles.display.copyWith(
                              color: Colors.black,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.2,
                            ),
                          ).animate().fadeIn().slideY(begin: 0.2),

                          Text(
                            'Master the future with real-world skills',
                            style: AppTextStyles.bodyLarge.copyWith(color: Colors.black54),
                          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),

                          const SizedBox(height: 32),

                          Container(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(color: Colors.black.withOpacity(0.08), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                )
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _PremiumField(
                                    label: 'FULL NAME',
                                    hint: 'John Doe',
                                    icon: Icons.person_outline_rounded,
                                    controller: _nameController,
                                  ),
                                  const SizedBox(height: 24),
                                  _PremiumField(
                                    label: 'GMAIL ADDRESS',
                                    hint: 'you@gmail.com',
                                    icon: Icons.alternate_email_rounded,
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 24),
                                  _PremiumField(
                                    label: 'SECURE PASSWORD',
                                    hint: '••••••••',
                                    icon: Icons.lock_outline_rounded,
                                    controller: _passwordController,
                                    obscureText: true,
                                  ),
                                  const SizedBox(height: 40),
                                  PrimaryButton(
                                    label: 'CREATE PREMIUM ACCOUNT',
                                    isLoading: authState.isLoading,
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        final bool success = await ref.read(authProvider.notifier).signUp(
                                          _emailController.text.trim(),
                                          _passwordController.text.trim(),
                                          _nameController.text.trim(),
                                        );
                                        if (success && context.mounted) {
                                          context.push('/verify');
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                          const SizedBox(height: 40),

                          GestureDetector(
                            onTap: () => context.pop(),
                            child: RichText(
                              text: TextSpan(
                                text: "Already registered? ",
                                style: AppTextStyles.body.copyWith(color: Colors.black54),
                                children: [
                                  TextSpan(
                                    text: 'Sign In',
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(delay: 400.ms),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;

  const _PremiumField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  State<_PremiumField> createState() => _PremiumFieldState();
}

class _PremiumFieldState extends State<_PremiumField> {
  late bool _isObscure;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.caption.copyWith(
            color: Colors.black45,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: TextFormField(
            controller: widget.controller,
            obscureText: _isObscure,
            keyboardType: widget.keyboardType,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(color: Colors.black.withOpacity(0.2)),
              prefixIcon: Icon(widget.icon, color: AppColors.secondary, size: 20),
              suffixIcon: widget.obscureText
                  ? IconButton(
                icon: Icon(_isObscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.black38, size: 20),
                onPressed: () => setState(() => _isObscure = !_isObscure),
              )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Field required';
              if (widget.keyboardType == TextInputType.emailAddress && !v.contains('@')) return 'Invalid email';
              if (widget.obscureText && v.length < 6) return 'Min 6 characters';
              return null;
            },
          ),
        ),
      ],
    );
  }
}

class _BrandLogoBox extends StatelessWidget {
  const _BrandLogoBox();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [AppColors.accent, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(4, 4),
            blurRadius: 10,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Image.asset(
          'assets/images/applogo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Text('BP', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
          ),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowOrb({required this.color, required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0)],
        ),
      ),
    );
  }
}