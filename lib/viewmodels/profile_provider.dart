import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/user.dart';
import 'auth_provider.dart';

final profileProvider = FutureProvider<User?>((ref) async {
  final authState = ref.watch(authProvider);
  return authState.user;
});
