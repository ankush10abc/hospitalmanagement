import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../users/domain/user_entities.dart';
import '../data/firebase_user_service.dart';
import '../domain/admin_auth_service.dart';

final _userServiceProvider = Provider((_) => FirebaseUserService());

class CreateUserPage extends ConsumerStatefulWidget {
  const CreateUserPage({super.key});

  @override
  ConsumerState<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends ConsumerState<CreateUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();

  AdminRole _selectedRole = AdminRole.readOnlyAuditor;
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _mobileCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final result = await ref.read(_userServiceProvider).createUser(
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
            role: _selectedRole.name,
            mobile: _mobileCtrl.text.trim().isEmpty
                ? null
                : _mobileCtrl.text.trim(),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User ${result.email} created successfully.'),
          backgroundColor: const Color(0xFF1A7F4B),
        ),
      );
      _formKey.currentState!.reset();
      _nameCtrl.clear();
      _emailCtrl.clear();
      _passwordCtrl.clear();
      _mobileCtrl.clear();
      setState(() => _selectedRole = AdminRole.readOnlyAuditor);
    } on AdminAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create User',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2E3D),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Add a new administrator or consultant account',
                style: TextStyle(fontSize: 14, color: Color(0xFF667786)),
              ),
              const SizedBox(height: 28),
              _FormCard(
                formKey: _formKey,
                nameCtrl: _nameCtrl,
                emailCtrl: _emailCtrl,
                passwordCtrl: _passwordCtrl,
                mobileCtrl: _mobileCtrl,
                selectedRole: _selectedRole,
                obscurePassword: _obscurePassword,
                isSubmitting: _isSubmitting,
                onRoleChanged: (r) => setState(() => _selectedRole = r!),
                onTogglePassword: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                onSubmit: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.mobileCtrl,
    required this.selectedRole,
    required this.obscurePassword,
    required this.isSubmitting,
    required this.onRoleChanged,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController mobileCtrl;
  final AdminRole selectedRole;
  final bool obscurePassword;
  final bool isSubmitting;
  final ValueChanged<AdminRole?> onRoleChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field(
              label: 'Full Name',
              controller: nameCtrl,
              hint: 'Dr. Rajesh Kumar',
              icon: Icons.person_outline_rounded,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter full name.' : null,
            ),
            const SizedBox(height: 20),
            _field(
              label: 'Email Address',
              controller: emailCtrl,
              hint: 'name@organization.com',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter email.';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
                  return 'Enter a valid email.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _field(
              label: 'Mobile (optional)',
              controller: mobileCtrl,
              hint: '+91 98765 43210',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            // Password
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF344A59),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: passwordCtrl,
                  obscureText: obscurePassword,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter a password.';
                    if (v.length < 6) return 'Minimum 6 characters.';
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Minimum 6 characters',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: onTogglePassword,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Role dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Role',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF344A59),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<AdminRole>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                  ),
                  items: AdminRole.values
                      .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(r.label),
                          ))
                      .toList(),
                  onChanged: onRoleChanged,
                ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: isSubmitting ? null : onSubmit,
                icon: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.person_add_rounded, size: 20),
                label: Text(isSubmitting ? 'Creating...' : 'Create User'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF344A59),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
          ),
        ),
      ],
    );
  }
}
