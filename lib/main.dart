import 'package:be_practical18/viewmodels/applications_viewmodel.dart';
import 'package:be_practical18/viewmodels/community_viewmodel.dart';
import 'package:be_practical18/viewmodels/dashboard_viewmodel.dart';
import 'package:be_practical18/viewmodels/internships_viewmodel.dart';
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
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => InternshipsViewModel()),
        ChangeNotifierProvider(create: (_) => ApplicationsViewModel()),
        ChangeNotifierProvider(create: (_) => CommunityViewModel()),
      ],
      child: MaterialApp(
        title: 'Be Practical',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E3A8A),
            primary: const Color(0xFF1E3A8A),
            surface: const Color(0xFFFFFFFF),
            surfaceContainerHighest: const Color(0xFFEFF6FF),
          ),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Color(0xFF111827),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: IconThemeData(color: Color(0xFF111827)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),

        ),
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}