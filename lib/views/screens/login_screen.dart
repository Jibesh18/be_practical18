import 'package:be_practical18/views/screens/role_selection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../routes/app_routes.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_textstyles.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final authVM = context.read<AuthViewModel>();
    final success = await authVM.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      final role = await authVM.fetchUserRole();
      if (!mounted) return;
      if (role == 'employer') {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.employerHome, (route) => false);
      } else if (role == 'internSeeker') {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.internHome, (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account not found. Please register first.')),
        );
      }
    } else if (authVM.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authVM.errorMessage!), backgroundColor: AppColors.error),
      );
    }
  }

  // REPLACE the _loginWithGoogle method in login_screen.dart with this:

  Future<void> _loginWithGoogle() async {
    final authVM = context.read<AuthViewModel>();
    final credential = await authVM.signInWithGoogleAndCheckRole();
    if (!mounted) return;
    if (credential == null) return; // user cancelled

    final user = credential.user;
    if (user == null) return;

    // Check if user already has a role (returning user)
    final role = await authVM.fetchUserRole();
    if (!mounted) return;

    if (role == 'employer') {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.employerHome, (_) => false);
    } else if (role == 'internSeeker') {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.internHome, (_) => false);
    } else {
      // New Google user — no role yet → show role selection screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RoleSelectionScreen(
            name: user.displayName ?? '',
            email: user.email ?? '',
            uid: user.uid,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Logo — white background, bigger, no colored tint
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.12),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Image.asset(
                      'assets/images/logobp.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text('BP', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Be Practical',
                    style: AppTextStyles.headlineLarge.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sign in to your account',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 32),

                  // Card
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.black.withOpacity(0.08)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('EMAIL ADDRESS'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _emailController,
                          hint: 'you@example.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your email' : null,
                        ),
                        const SizedBox(height: 20),

                        _buildLabel('PASSWORD'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _passwordController,
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              color: Colors.black38,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Please enter your password' : null,
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () async {
                              if (_emailController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Enter your email first')),
                                );
                                return;
                              }
                              final authVM = context.read<AuthViewModel>();
                              final success = await authVM.resetPassword(_emailController.text.trim());
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(success ? 'Password reset email sent!' : authVM.errorMessage ?? 'Something went wrong')),
                              );
                            },
                            child: Text(
                              'Forgot Password?',
                              style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Consumer<AuthViewModel>(
                          builder: (context, authVM, _) => SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: authVM.isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              child: authVM.isLoading
                                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                  : Text('SIGN IN', style: AppTextStyles.button.copyWith(color: Colors.white, letterSpacing: 1.2)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(children: [
                          Expanded(child: Divider(color: Colors.black.withOpacity(0.1))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('OR', style: AppTextStyles.labelSmall.copyWith(color: Colors.black38)),
                          ),
                          Expanded(child: Divider(color: Colors.black.withOpacity(0.1))),
                        ]),
                        const SizedBox(height: 16),

                        Consumer<AuthViewModel>(
                          builder: (context, authVM, _) => SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: OutlinedButton.icon(
                              onPressed: authVM.isLoading ? null : _loginWithGoogle,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.black.withOpacity(0.15)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              icon: Image.asset('assets/images/google.png', height: 22, width: 22),
                              label: Text('Continue with Google', style: AppTextStyles.button.copyWith(color: Colors.black87, fontSize: 14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ", style: AppTextStyles.bodyMedium.copyWith(color: Colors.black54)),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.register),
                        child: Text(
                          'Create One',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.labelSmall.copyWith(
        color: Colors.black45,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
        validator: validator,
      ),
    );
  }
}