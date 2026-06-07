import 'package:flutter/material.dart';

class EmployerHomeScreen extends StatelessWidget {
  const EmployerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Employer Home Screen',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}