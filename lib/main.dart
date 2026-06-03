import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'routes/app_routes.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/splash_viewmodel.dart';
import 'themes/app_themes.dart';

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
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: MaterialApp(
        title: 'Be Practical',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}