import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/spacing.dart';
import '../components/buttons/primary_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address first.'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      await ref.read(authProvider.notifier).forgotPassword(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset link sent to $email ✨'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
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
          Positioned(top: -100, right: -50, child: _GlowOrb(color: const Color(0xFF7FA9D8).withValues(alpha: 0.1), size: 400)),
          Positioned(bottom: -50, left: -50, child: _GlowOrb(color: const Color(0xFFAFC8E8).withValues(alpha: 0.1), size: 350)),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    const _BrandLogo().animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Be Practical', 
                      style: AppTextStyles.display.copyWith(color: Colors.black, fontSize: 40, fontWeight: FontWeight.w900)
                    ),
                    Text(
                      'Log in to your verified account', 
                      style: AppTextStyles.bodyLarge.copyWith(color: Colors.black54)
                    ),
                    const SizedBox(height: AppSpacing.xl2),

                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.black12, width: 1.5),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 30, offset: const Offset(0, 15))
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _AuthTextField(
                              label: 'EMAIL ADDRESS',
                              hint: 'you@example.com',
                              icon: Icons.email_outlined,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            _AuthTextField(
                              label: 'PASSWORD',
                              hint: '••••••••',
                              icon: Icons.lock_outline,
                              controller: _passwordController,
                              obscureText: true,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _handleForgotPassword,
                                child: Text(
                                  'Forgot Password?',
                                  style: AppTextStyles.label.copyWith(
                                    color: const Color(0xFF1E3A8A),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            PrimaryButton(
                              label: 'SIGN IN',
                              isLoading: authState.isLoading,
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  ref.read(authProvider.notifier).login(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                    const SizedBox(height: AppSpacing.xl3),

                    GestureDetector(
                      onTap: () => context.push('/signup'),
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: AppTextStyles.body.copyWith(color: Colors.black54),
                          children: [
                            TextSpan(
                              text: 'Create One',
                              style: AppTextStyles.body.copyWith(
                                color: const Color(0xFF2563EB),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 700.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthTextField extends StatefulWidget {
  final String label, hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;

  const _AuthTextField({required this.label, required this.hint, required this.icon, required this.controller, this.obscureText = false, this.keyboardType});

  @override
  State<_AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<_AuthTextField> {
  late bool _obscureText;
  @override
  void initState() { super.initState(); _obscureText = widget.obscureText; }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label, 
          style: AppTextStyles.caption.copyWith(color: Colors.black45, fontWeight: FontWeight.w900, letterSpacing: 1.5)
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.03), 
            borderRadius: BorderRadius.circular(16), 
            border: Border.all(color: Colors.black.withValues(alpha: 0.05))
          ),
          child: TextFormField(
            controller: widget.controller,
            obscureText: _obscureText,
            keyboardType: widget.keyboardType,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(color: Colors.black26),
              prefixIcon: Icon(widget.icon, color: const Color(0xFF1E3A8A), size: 20),
              suffixIcon: widget.obscureText ? IconButton(icon: Icon(_obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.black38, size: 20), onPressed: () => setState(() => _obscureText = !_obscureText)) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
        ),
      ],
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFDCE7F5),
            Color(0xFFAFC8E8),
            Color(0xFF7FA9D8),
          ],
        ),
        border: Border.all(color: const Color(0xFFC0C8D2), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 85,
          height: 85,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset(
                  'assets/images/applogo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 40,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ),
            ),
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
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0)],
      ),
    ),
  );
}

