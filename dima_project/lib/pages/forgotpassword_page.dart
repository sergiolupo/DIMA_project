import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../widgets/login/loginform_widget.dart';

class ForgotPasswordPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          'ForgotPassword',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.systemPink,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Container(
                color: CupertinoColors.white,
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Please enter your email to receive a password reset link',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      UsernameInputField(_usernameController),
                      CupertinoButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            resetPassword(
                              context,
                              _usernameController.text,
                            );
                          }
                        },
                        color: CupertinoColors.systemPink,
                        child: const Text(
                          'Reset Password',
                          style: TextStyle(
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> resetPassword(BuildContext context, String email) async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return const CupertinoAlertDialog(
          content: CupertinoActivityIndicator(),
        );
      },
    );

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      debugPrint("Password reset email sent");
      if (!context.mounted) return;
      Navigator.of(context).pop();

      // Show success dialog
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Success'),
            content: const Text(
                'A password reset email has been sent to the email address provided.'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  context.go('/');
                },
              ),
            ],
          );
        },
      );
    } catch (error) {
      String errorMessage = error.toString();
      int errorCodeIndex =
          errorMessage.indexOf(']') + 1; // Find the index after the error code
      String errorMessageSubstring =
          errorMessage.substring(errorCodeIndex).trim();
      debugPrint("Error sending password reset email: $error");
      if (!context.mounted) return;
      Navigator.of(context).pop();
      // Show error dialog
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text(
                'Failed to send password reset email: ${errorMessageSubstring.toString()}'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    }
  }
}
