import 'package:firebase_auth/firebase_auth.dart';

import '../domain/admin_auth_service.dart';

class FirebaseAdminAuthService implements AdminAuthService {
  FirebaseAdminAuthService(this._auth);

  final FirebaseAuth _auth;

  static const _allowedRoles = {
    'super_admin',
    'admin',
    'finance_reviewer',
    'data_manager',
    'support_operator',
    'read_only_auditor',
  };

  @override
  AdminAccount? get currentAdmin => _toAdminAccount(_auth.currentUser);

  @override
  Future<AdminAccount> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Force-refresh token to get latest custom claims
      final idTokenResult = await credential.user!.getIdTokenResult(true);
      final account = _toAdminAccountFromClaims(
        credential.user!,
        idTokenResult.claims,
      );
      if (account == null) {
        await _auth.signOut();
        throw const AdminAuthException(
          'This account does not have an administrator role.',
        );
      }
      return account;
    } on FirebaseAuthException catch (e) {
      throw AdminAuthException(_friendlyMessage(e.code));
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      throw const AdminAuthException(
        'Could not send reset link. Check the email and try again.',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException {
      throw const AdminAuthException('Sign-out failed. Please try again.');
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  AdminAccount? _toAdminAccount(User? user) {
    if (user == null) return null;
    // Use display name as role fallback — real role comes from custom claims
    // on next sign-in. For already-signed-in sessions we use a default role.
    return AdminAccount(email: user.email ?? '', role: 'admin');
  }

  AdminAccount? _toAdminAccountFromClaims(
    User user,
    Map<String, dynamic>? claims,
  ) {
    if (claims == null) return null;
    final rawRole = claims['role'];
    if (rawRole is! String) return null;
    final role = rawRole.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
    if (!_allowedRoles.contains(role)) return null;
    return AdminAccount(email: user.email ?? '', role: role);
  }

  String _friendlyMessage(String code) => switch (code) {
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' =>
          'Incorrect email or password. Please try again.',
        'user-disabled' => 'This account has been disabled.',
        'too-many-requests' =>
          'Too many attempts. Please wait a moment and try again.',
        'network-request-failed' =>
          'Network error. Check your connection and try again.',
        _ => 'Sign-in failed. Please try again.',
      };
}
