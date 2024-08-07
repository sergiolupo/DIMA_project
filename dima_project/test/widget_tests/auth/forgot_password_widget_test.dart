import 'package:dima_project/widgets/auth/forgot_password_widget.dart';
import 'package:dima_project/widgets/auth/login_form_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/mock_auth_service.mocks.dart';

void main() {
  group('ForgotPasswordForm Tests', () {
    late TextEditingController usernameController;
    late MockAuthService mockAuthService;
    setUp(() {
      usernameController = TextEditingController();
      mockAuthService = MockAuthService();
    });

    testWidgets('ForgotPasswordForm renders correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: ForgotPasswordForm(usernameController,
              authService: mockAuthService),
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
              authService: mockAuthService),
        ),
      );

      await tester.tap(find.byType(CupertinoButton));
      await tester.pump();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets(
        'ForgotPasswordForm shows success dialog on successful password reset',
        (WidgetTester tester) async {
      when(mockAuthService.sendPasswordResetEmail('test@example.com'))
          .thenAnswer((_) => Future.value());

      usernameController.text = 'test@example.com';

      await tester.pumpWidget(
        CupertinoApp(
          home: ForgotPasswordForm(usernameController,
              authService: mockAuthService),
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
  });
}
