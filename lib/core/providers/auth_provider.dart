import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/admin_auth/domain/admin_auth_service.dart';

// ---------------------------------------------------------------------------
// Service provider — overridden at the ProviderScope level in app.dart so the
// concrete AdminAuthService injected from main.dart is used everywhere.
// ---------------------------------------------------------------------------

final adminAuthServiceProvider = Provider<AdminAuthService>((ref) {
  throw UnimplementedError(
    'adminAuthServiceProvider must be overridden in the ProviderScope.',
  );
});

// ---------------------------------------------------------------------------
// Auth state — holds the currently signed-in AdminAccount (or null).
// ---------------------------------------------------------------------------

class AuthNotifier extends StateNotifier<AdminAccount?> {
  AuthNotifier(this._service) : super(_service.currentAdmin);

  final AdminAuthService _service;

  AdminAccount? get currentAdmin => state;

  Future<AdminAccount> signIn({
    required String email,
    required String password,
  }) async {
    final account = await _service.signIn(email: email, password: password);
    state = account;
    return account;
  }

  Future<void> signOut() async {
    await _service.signOut();
    state = null;
  }

  /// Called after a successful sign-in that was triggered outside this
  /// notifier (e.g. the existing AdminLoginPage using the service directly).
  void refresh() {
    state = _service.currentAdmin;
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AdminAccount?>((ref) {
  final service = ref.watch(adminAuthServiceProvider);
  return AuthNotifier(service);
});
