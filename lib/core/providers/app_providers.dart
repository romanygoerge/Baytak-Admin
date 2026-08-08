import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/data/models/user_model.dart';

// ─── Supabase Client Provider ───────────────────────────────────────

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final isFirebaseConfiguredProvider = Provider<bool>((ref) {
  return true; // Maintained for backwards compatibility in router
});

// ─── Auth State Providers ────────────────────────────────────────────

final authStateChangesProvider = StreamProvider<User?>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.auth.onAuthStateChange.map((data) => data.session?.user);
});

final currentFirebaseUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateChangesProvider).valueOrNull ?? ref.watch(supabaseClientProvider).auth.currentUser;
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(currentFirebaseUserProvider) != null;
});

// ─── Current User Document Provider ──────────────────────────────────

final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final user = ref.watch(currentFirebaseUserProvider);
  if (user == null) return Stream.value(null);

  final supabase = ref.watch(supabaseClientProvider);
  return supabase
      .from('profiles')
      .stream(primaryKey: ['id'])
      .eq('id', user.id)
      .map((data) {
    if (data.isEmpty) return null;
    return UserModel.fromJson(data.first);
  });
});

// ─── App Settings Providers ──────────────────────────────────────────

final themeProvider = StateProvider<bool>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  return user?.darkMode ?? false;
});

final localeProvider = StateProvider<String>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  return user?.language ?? 'ar';
});

