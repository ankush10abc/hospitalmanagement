// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hospitalmanagement/app/app.dart';
import 'package:hospitalmanagement/features/admin_auth/domain/admin_auth_service.dart';

void main() {
  testWidgets('admin sign-in validates fields before submission', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      HospitalAdminApp(authService: _FakeAdminAuthService()),
    );

    await tester.ensureVisible(find.byKey(const Key('auth-submit-button')));
    await tester.tap(find.byKey(const Key('auth-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Enter your email address.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
  });

  testWidgets('valid admin credentials open the signed-in portal', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      HospitalAdminApp(authService: _FakeAdminAuthService()),
    );
    await tester.enterText(
      find.byKey(const Key('email-field')),
      'admin@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('password-field')),
      'not-a-real-password',
    );
    await tester.ensureVisible(find.byKey(const Key('auth-submit-button')));
    await tester.tap(find.byKey(const Key('auth-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Signed in to the admin portal'), findsOneWidget);
    expect(find.text('admin@example.com'), findsOneWidget);
  });

  testWidgets('missing Supabase configuration is reported to the user', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const HospitalAdminApp(authService: UnconfiguredAdminAuthService()),
    );
    await tester.enterText(
      find.byKey(const Key('email-field')),
      'admin@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('password-field')),
      'not-a-real-password',
    );
    await tester.ensureVisible(find.byKey(const Key('auth-submit-button')));
    await tester.tap(find.byKey(const Key('auth-submit-button')));
    await tester.pump();

    expect(
      find.textContaining('Set SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY'),
      findsOneWidget,
    );
  });

  testWidgets('password recovery can return to sign in', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      HospitalAdminApp(authService: _FakeAdminAuthService()),
    );

    await tester.tap(find.byKey(const Key('forgot-password-button')));
    await tester.pumpAndSettle();
    expect(find.text('Reset your password'), findsOneWidget);

    await tester.tap(find.byKey(const Key('back-to-sign-in-button')));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
  });
}

class _FakeAdminAuthService implements AdminAuthService {
  @override
  AdminAccount? currentAdmin;

  @override
  Future<AdminAccount> signIn({
    required String email,
    required String password,
  }) async {
    return AdminAccount(email: email, role: 'admin');
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() async {
    currentAdmin = null;
  }
}
