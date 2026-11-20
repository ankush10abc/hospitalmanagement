class AdminAccount {
  const AdminAccount({required this.email, required this.role});

  final String email;
  final String role;
}

abstract interface class AdminAuthService {
  AdminAccount? get currentAdmin;

  Future<AdminAccount> signIn({
    required String email,
    required String password,
  });

  Future<void> sendPasswordReset(String email);

  Future<void> signOut();
}

class AdminAuthException implements Exception {
  const AdminAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class UnconfiguredAdminAuthService implements AdminAuthService {
  const UnconfiguredAdminAuthService();

  static const _message =
      'Authentication is not configured. Set SUPABASE_URL and '
      'SUPABASE_PUBLISHABLE_KEY when starting the app.';

  @override
  AdminAccount? get currentAdmin => null;

  @override
  Future<AdminAccount> signIn({
    required String email,
    required String password,
  }) async {
    throw const AdminAuthException(_message);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    throw const AdminAuthException(_message);
  }

  @override
  Future<void> signOut() async {
    throw const AdminAuthException(_message);
  }
}
