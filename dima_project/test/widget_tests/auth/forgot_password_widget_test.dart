import 'package:dima_project/widgets/auth/forgot_password_widget.dart';
import 'package:dima_project/widgets/auth/login_form_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  Future<void> sendPasswordResetEmail(
      {ActionCodeSettings? actionCodeSettings, required String email}) async {
    return;
  }
}

void main() {
  group('ForgotPasswordForm Tests', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late TextEditingController usernameController;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      usernameController = TextEditingController();
    });

    testWidgets('ForgotPasswordForm renders correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: ForgotPasswordForm(usernameController,
              firebaseAuth: mockFirebaseAuth),
        ),
      );

      expect(
          find.text('Please enter your email to receive a password reset link'),
          findsOneWidget);
      expect(find.byType(EmailInputField), findsOneWidget);
      expect(find.byType(CupertinoButton), findsOneWidget);
    });

    testWidgets('ForgotPasswordForm validates email input',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: ForgotPasswordForm(usernameController,
              firebaseAuth: mockFirebaseAuth),
        ),
      );

      await tester.tap(find.byType(CupertinoButton));
      await tester.pump();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets(
        'ForgotPasswordForm shows success dialog on successful password reset',
        (WidgetTester tester) async {
      usernameController.text = 'test@example.com';

      await tester.pumpWidget(
        CupertinoApp(
          home: ForgotPasswordForm(usernameController,
              firebaseAuth: mockFirebaseAuth),
        ),
      );

      await tester.tap(find.byType(CupertinoButton));
      await tester.pump();

      expect(find.text('Success'), findsOneWidget);
      expect(
          find.text(
              'A password reset email has been sent to the email address provided.'),
          findsOneWidget);
    });

    testWidgets(
        'ForgotPasswordForm shows error dialog on failed password reset',
        (WidgetTester tester) async {
      usernameController.text = 'invalid_email';

      await tester.pumpWidget(
        CupertinoApp(
          home: ForgotPasswordForm(usernameController,
              firebaseAuth: mockFirebaseAuth),
        ),
      );

      await tester.tap(find.byType(CupertinoButton));
      await tester.pump();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });
  });
}
