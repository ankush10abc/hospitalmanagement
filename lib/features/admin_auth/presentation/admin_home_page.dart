import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/admin_auth_service.dart';

/// Legacy home page — kept to satisfy the import in admin_login_page.dart.
///
/// When the app uses GoRouter (MaterialApp.router), Navigator.pushReplacement
/// to this page still works because go_router builds on top of Navigator.
/// This widget immediately redirects to /dashboard using go_router so the
/// user lands in the proper shell experience.
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({
    required this.account,
    required this.authService,
    super.key,
  });

  final AdminAccount account;
  final AdminAuthService authService;

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  void initState() {
    super.initState();
    // Redirect to the shell dashboard on first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go('/dashboard');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a brief loading screen while the redirect fires.
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
