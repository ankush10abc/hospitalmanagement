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
