import 'package:flutter/material.dart';

import '../domain/admin_auth_service.dart';
import 'admin_login_page.dart';

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
  bool _isSigningOut = false;

  Future<void> _signOut() async {
    setState(() {
      _isSigningOut = true;
    });

    try {
      await widget.authService.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => AdminLoginPage(authService: widget.authService),
        ),
        (_) => false,
      );
    } on AdminAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSigningOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Admin Portal'),
        actions: [
          TextButton.icon(
            onPressed: _isSigningOut ? null : _signOut,
            icon: _isSigningOut
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout_rounded),
            label: const Text('Sign out'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  size: 34,
                  color: Color(0xFF167D8D),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Signed in to the admin portal',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text(widget.account.email),
                const SizedBox(height: 4),
                Text('Role: ${widget.account.role}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
