import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/admin_auth_service.dart';

class SupabaseAdminAuthService implements AdminAuthService {
  const SupabaseAdminAuthService(this._client);

  final SupabaseClient _client;

  static const _allowedRoles = {
    'super_admin',
    'admin',
    'finance_reviewer',
    'data_manager',
    'support_operator',
    'read_only_auditor',
  };

  @override
  AdminAccount? get currentAdmin => _toAdminAccount(_client.auth.currentUser);

  @override
  Future<AdminAccount> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final account = _toAdminAccount(response.user);
      if (account == null) {
        await _client.auth.signOut();
        throw const AdminAuthException(
          'This account does not have an administrator role.',
        );
      }
      return account;
    } on AuthException {
      throw const AdminAuthException(
        'Sign-in failed. Check your email and password, then try again.',
      );
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException {
      throw const AdminAuthException(
        'Could not request a reset link. Check the email and try again.',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException {
      throw const AdminAuthException(
        'Sign-out failed. Please try again.',
      );
    }
  }

  AdminAccount? _toAdminAccount(User? user) {
    if (user == null) return null;

    final rawRole = user.appMetadata['role'];
    if (rawRole is! String) return null;

    final role = rawRole
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\s-]+'), '_');
    if (!_allowedRoles.contains(role)) return null;

    return AdminAccount(email: user.email ?? '', role: role);
  }
}
