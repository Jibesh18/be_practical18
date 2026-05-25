import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/app_routes.dart';
import 'viewmodels/splash_viewmodel.dart';

void main() {
  runApp(const BePracticalApp());
}

class BePracticalApp extends StatelessWidget {
  const BePracticalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
      ],
      child: MaterialApp(
        title: 'Be Practical',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A3DB5),
          ),
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}