import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../view/splash_screen.dart';
import '../view/onboarding_screen.dart';
import '../view/login_screen.dart';
import '../view/signup_screen.dart';
import '../view/verification_screen.dart';
import '../view/home_screen.dart';
import '../view/profile_screen.dart';
import '../view/internships_screen.dart';
import '../view/internship_detail_screen.dart';
import '../view/skills_screen.dart';
import '../view/notifications_screen.dart';
import '../view/privacy_screen.dart';
import '../viewmodel/auth_provider.dart';
import '../viewmodel/screen_state_provider.dart';
import '../components/navigation/bottom_nav_bar.dart';
import '../viewmodel/notification_provider.dart';
import '../viewmodel/internship_provider.dart';

// 1. Stable Router Notifier: This prevents the entire app from "Restarting"
// when the user state changes (like typing in a login box).
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen(authProvider, (_, __) => notifyListeners());
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final auth = _ref.read(authProvider);
    final path = state.matchedLocation;

    // A. While app is initializing, stay on Splash
    if (!auth.isInitialized) return '/splash';

    // B. Handle logic once initialized
    if (path == '/splash') {
      return auth.isAuthenticated ? '/home' : '/onboarding';
    }

    // C. Handle Verification Page
    if (auth.isVerifying && path != '/verify') return '/verify';

    // D. Protect Dashboard routes
    final bool isGuestRoute = ['/login', '/signup', '/onboarding', '/verify'].contains(path);
    if (!auth.isAuthenticated && !isGuestRoute) {
      return '/login';
    }

    // E. Prevent logged-in users from seeing Auth screens
    if (auth.isAuthenticated && isGuestRoute) {
      return '/home';
    }

    return null;
  }
}

final routerNotifierProvider = Provider((ref) => RouterNotifier(ref));

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      // Auth Flow
      GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (c, s) => const SignUpScreen()),
      GoRoute(path: '/verify', builder: (c, s) => const VerificationScreen()),

      // Standalone Pages
      GoRoute(path: '/privacy', builder: (c, s) => const PrivacyScreen()),
      GoRoute(
        path: '/internship/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return FutureBuilder(
            future: ref.read(internshipServiceProvider).getById(id),
            builder: (ctx, snap) {
              if (snap.hasData && snap.data != null) {
                return InternshipDetailScreen(internship: snap.data!);
              }
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            },
          );
        },
      ),

      // Main Dashboard Shell (With Persistent Bottom Navigation)
      ShellRoute(
        builder: (context, state, child) => MainApp(child: child),
        routes: [
          GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
          GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
          GoRoute(path: '/internships', builder: (c, s) => const InternshipsScreen()),
          GoRoute(path: '/notifications', builder: (c, s) => const NotificationsScreen()),
          GoRoute(path: '/skills', builder: (c, s) => const SkillsScreen()),
        ],
      ),
    ],
  );
});

class MainApp extends ConsumerWidget {
  final Widget child;
  const MainApp({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentScreen = ref.watch(currentScreenProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavBar(
        currentScreen: currentScreen,
        onScreenChanged: (screen) => ref.read(currentScreenProvider.notifier).state = screen,
        unreadCount: unreadCount,
      ),
    );
  }
}