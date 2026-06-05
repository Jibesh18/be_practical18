import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MainScreen {
  home,
  internships,
  skills,
  notifications,
  profile,
}

final currentScreenProvider = StateProvider<MainScreen>((ref) => MainScreen.home);

final onboardingCompleteProvider = StateProvider<bool>((ref) => false);
