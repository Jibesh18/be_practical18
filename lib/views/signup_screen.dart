import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/auth_provider.dart';
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
  String _selectedRole = 'Student'; 

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

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(top: -100, right: -50, child: _GlowOrb(color: const Color(0xFF1565C0).withValues(alpha: 0.1), size: 400)),
          Positioned(bottom: -50, left: -50, child: _GlowOrb(color: const Color(0xFF42A5F5).withValues(alpha: 0.1), size: 350)),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
                      ),
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
                          const _BrandLogoBox().animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
                          const SizedBox(height: 16),
                          Text(
                            'Be Practical',
                            style: AppTextStyles.display.copyWith(
                              color: const Color(0xFF1565C0),
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                          ).animate().fadeIn(delay: 200.ms),
                          Text(
                            'Start your professional journey',
                            style: AppTextStyles.bodyLarge.copyWith(color: Colors.black45),
                          ).animate().fadeIn(delay: 300.ms),
                          const SizedBox(height: 40),

                          Container(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(color: Colors.black.withValues(alpha: 0.08), width: 1.5),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 30, offset: const Offset(0, 15))
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("CREATE ACCOUNT AS:", style: AppTextStyles.caption.copyWith(color: Colors.black54, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _RoleTab(
                                            label: 'Student',
                                            isSelected: _selectedRole == 'Student',
                                            onTap: () => setState(() => _selectedRole = 'Student'),
                                          ),
                                        ),
                                        Expanded(
                                          child: _RoleTab(
                                            label: 'Company',
                                            isSelected: _selectedRole == 'Company',
                                            onTap: () => setState(() => _selectedRole = 'Company'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  
                                  _PremiumField(label: 'FULL NAME', hint: 'Anish Gautam', icon: Icons.person_outline_rounded, controller: _nameController),
                                  const SizedBox(height: 24),
                                  _PremiumField(label: 'EMAIL ADDRESS', hint: 'you@example.com', icon: Icons.alternate_email_rounded, controller: _emailController, keyboardType: TextInputType.emailAddress),
                                  const SizedBox(height: 24),
                                  _PremiumField(label: 'PASSWORD', hint: '••••••••', icon: Icons.lock_outline_rounded, controller: _passwordController, obscureText: true),
                                  const SizedBox(height: 32),
                                  
                                  PrimaryButton(
                                    label: 'JOIN AS ${_selectedRole.toUpperCase()}',
                                    isLoading: authState.isLoading,
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        final bool success = await ref.read(authProvider.notifier).signUp(
                                          _emailController.text.trim(),
                                          _passwordController.text.trim(),
                                          _nameController.text.trim(),
                                          _selectedRole,
                                        );
                                        if (success && context.mounted) context.push('/verify');
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

                          const SizedBox(height: 32),
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: RichText(
                              text: TextSpan(
                                text: "Already have an account? ",
                                style: AppTextStyles.body.copyWith(color: Colors.black54),
                                children: [
                                  TextSpan(
                                    text: 'Sign In',
                                    style: AppTextStyles.body.copyWith(
                                      color: const Color(0xFF1565C0),
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(delay: 600.ms),
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

class _RoleTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleTab({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1565C0) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [
            BoxShadow(color: const Color(0xFF1565C0).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))
          ] : [],
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumField extends StatefulWidget {
  final String label, hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;

  const _PremiumField({required this.label, required this.hint, required this.icon, required this.controller, this.obscureText = false, this.keyboardType});

  @override
  State<_PremiumField> createState() => _PremiumFieldState();
}

class _PremiumFieldState extends State<_PremiumField> {
  late bool _isObscure;
  @override
  void initState() { super.initState(); _isObscure = widget.obscureText; }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.caption.copyWith(color: Colors.black54, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: TextFormField(
            controller: widget.controller,
            obscureText: _isObscure,
            keyboardType: widget.keyboardType,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(color: Colors.black26),
              prefixIcon: Icon(widget.icon, color: const Color(0xFF1565C0), size: 20),
              suffixIcon: widget.obscureText ? IconButton(icon: Icon(_isObscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.black38, size: 20), onPressed: () => setState(() => _isObscure = !_isObscure)) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            ),
            validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
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
      width: 90, height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB), Color(0xFF90CAF9)],
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Image.asset('assets/images/applogo.png', fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.school_rounded, size: 40, color: Color(0xFF1565C0))),
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
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)])),
  );
}

