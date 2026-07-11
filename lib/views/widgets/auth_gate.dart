import 'package:be_practical18/views/screens/intern_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../screens/employer_home_screen.dart';
import '../screens/login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.read<AuthViewModel>();

    return StreamBuilder<User?>(
      stream: authVM.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final user = authSnapshot.data;
        if (user == null) return const LoginScreen();

        return FutureBuilder<String?>(
          future: authVM.fetchUserRoleWithRetry(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            switch (roleSnapshot.data) {
              case 'internSeeker':
                return const InternHomeTab();
              case 'employer':
                return const EmployerHomeScreen();
              default:
                return const LoginScreen();
            }
          },
        );
      },
    );
  }
}