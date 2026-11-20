import 'package:flutter/material.dart';

import '../domain/admin_auth_service.dart';
import 'admin_home_page.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({required this.authService, super.key});

  final AdminAuthService authService;

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

enum _AuthView { signIn, passwordRecovery }

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  _AuthView _view = _AuthView.signIn;
  bool _isPasswordVisible = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (_view == _AuthView.passwordRecovery) {
        await widget.authService.sendPasswordReset(
          _emailController.text.trim(),
        );
        if (!mounted) return;
        _showMessage(
          'If an account exists for this email, a reset link will be sent.',
        );
      } else {
        final account = await widget.authService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => AdminHomePage(
              account: account,
              authService: widget.authService,
            ),
          ),
        );
      }
    } on AdminAuthException catch (error) {
      if (mounted) _showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email address.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  Widget _buildBrandPanel({required bool compact}) {
    final padding = compact ? 22.0 : 44.0;
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF102D42), Color(0xFF155D6B)],
        ),
        borderRadius: BorderRadius.circular(compact ? 20 : 26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Care & Capital',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 22 : 52),
          Text(
            compact
                ? 'Hospital Admin Portal'
                : 'Clarity for every\nhealthcare investment.',
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 21 : 34,
              height: 1.2,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'A secure workspace to manage hospital projects, '
            'configuration, and financial assumptions.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.76),
              fontSize: 15,
              height: 1.55,
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: 36),
            const _FeatureLine(
              icon: Icons.admin_panel_settings_outlined,
              text: 'Role-based administrative access',
            ),
            const SizedBox(height: 18),
            const _FeatureLine(
              icon: Icons.fact_check_outlined,
              text: 'Governed project configuration',
            ),
            const SizedBox(height: 18),
            const _FeatureLine(
              icon: Icons.history_rounded,
              text: 'Traceable changes and review history',
            ),
          ],
          if (!compact) ...[
            const Spacer(),
            Text(
              'ADMINISTRATOR ACCESS',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.62),
                fontSize: 11,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAuthForm() {
    final isRecovery = _view == _AuthView.passwordRecovery;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isRecovery ? 'Reset your password' : 'Welcome back',
            style: const TextStyle(
              color: Color(0xFF172B3A),
              fontSize: 28,
              height: 1.2,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            isRecovery
                ? 'Enter the email for your admin account.'
                : 'Sign in with your administrator account to continue.',
            style: const TextStyle(
              color: Color(0xFF667786),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Email address',
            style: TextStyle(
              color: Color(0xFF344A59),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            key: const Key('email-field'),
            controller: _emailController,
            validator: _validateEmail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: isRecovery
                ? TextInputAction.done
                : TextInputAction.next,
            autofillHints: const [AutofillHints.username, AutofillHints.email],
            decoration: const InputDecoration(
              hintText: 'name@organization.com',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
          ),
          if (!isRecovery) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  'Password',
                  style: TextStyle(
                    color: Color(0xFF344A59),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  key: const Key('forgot-password-button'),
                  onPressed: () {
                    setState(() {
                      _view = _AuthView.passwordRecovery;
                    });
                    _formKey.currentState?.reset();
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Forgot password?'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('password-field'),
              controller: _passwordController,
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Enter your password.'
                  : null,
              obscureText: !_isPasswordVisible,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: _isPasswordVisible
                      ? 'Hide password'
                      : 'Show password',
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: FilledButton(
              key: const Key('auth-submit-button'),
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isRecovery ? 'Send reset link' : 'Sign in'),
            ),
          ),
          if (isRecovery) ...[
            const SizedBox(height: 14),
            TextButton.icon(
              key: const Key('back-to-sign-in-button'),
              onPressed: () {
                setState(() {
                  _view = _AuthView.signIn;
                });
                _formKey.currentState?.reset();
              },
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Back to sign in'),
            ),
          ],
          const SizedBox(height: 26),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shield_outlined,
                size: 17,
                color: Color(0xFF66808E),
              ),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Admin access is verified by the platform service.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF71828D),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 32 : 20,
                vertical: isWide ? 28 : 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (isWide ? 56 : 40),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: isWide
                        ? IntrinsicHeight(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: _buildBrandPanel(compact: false),
                                ),
                                const SizedBox(width: 28),
                                Expanded(
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 30,
                                      vertical: 36,
                                    ),
                                    child: _buildAuthForm(),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildBrandPanel(compact: true),
                              const SizedBox(height: 22),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 12,
                                ),
                                child: _buildAuthForm(),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FeatureLine extends StatelessWidget {
  const _FeatureLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 19, color: const Color(0xFF8DD9D7)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
