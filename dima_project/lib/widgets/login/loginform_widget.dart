import 'package:dima_project/services/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EmailInputField(_usernameController),
          PasswordInputField(_passwordController),
          CupertinoButton(
            onPressed: () {
              // Validate the form before proceeding
              if (_formKey.currentState!.validate()) {
                _checkCredentials(context, _usernameController.text,
                    _passwordController.text);
              }
            },
            color: CupertinoColors.systemPink,
            child: const Text('Login'),
          ),
          const SizedBox(height: 20),
          CupertinoButton(
              onPressed: () => _signInWithGoogle(context),
              color: CupertinoColors.systemBlue,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    FontAwesomeIcons.google,
                    color: CupertinoColors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Sign In with Google',
                    style: TextStyle(
                      color: CupertinoColors.white,
                    ),
                  ),
                ],
              )),
          CupertinoButton(
            onPressed: () {
              context.go('/forgotpassword');
            },
            child: const Text(
              'Forgot Password?',
              style: TextStyle(color: CupertinoColors.activeBlue),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('Not a member?'),
            const SizedBox(width: 4),
            GestureDetector(
                onTap: () {
                  context.go('/register');
                },
                child: const Text('Register now',
                    style: TextStyle(
                        color: CupertinoColors.activeBlue,
                        fontWeight: FontWeight.bold))),
          ]),
        ],
      ),
    );
  }

  void _checkCredentials(BuildContext context, String email, String password) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return const CupertinoAlertDialog(
          content: CupertinoActivityIndicator(),
        );
      },
    );

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      authService.signInWithEmailandPassword(
        email,
        password,
      );
      if (!context.mounted) return;
      Navigator.of(context).pop();
      debugPrint("Navigating to Home Page");
      context.go('/home');
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      debugPrint("Failed to login: $e");
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Login Failed'),
            content: const Text('Invalid username or password'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return const CupertinoAlertDialog(
          content: CupertinoActivityIndicator(),
        );
      },
    );

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.signInWithGoogle();

      if (!context.mounted) return;
      Navigator.of(context).pop();
      debugPrint("Navigating to Home Page");
      context.go('/home');
    } catch (e) {
      Navigator.of(context).pop();
      // Handle other exceptions
      debugPrint("Failed to login: $e");
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Login Failed'),
            content:
                const Text('Failed to login with Google. Please try again.'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}

class PasswordInputField extends StatelessWidget {
  final TextEditingController _passwordController;
  final bool isConfirmPassword;
  final TextEditingController? confirmValue;

  const PasswordInputField(
    this._passwordController, {
    this.isConfirmPassword = false,
    this.confirmValue,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTextFormFieldRow(
      controller: _passwordController,
      placeholder: isConfirmPassword ? 'Confirm password' : 'Password',
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: CupertinoColors.systemGrey4,
          width: 2.0,
        ),
      ),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a ${isConfirmPassword ? 'password' : 'password'}';
        }
        if (isConfirmPassword && value != confirmValue?.text) {
          return 'Passwords do not match';
        }
        return null; // Return null if the input is valid
      },
      obscureText: true,
    );
  }
}

class EmailInputField extends StatelessWidget {
  final TextEditingController _emailController;

  const EmailInputField(this._emailController, {super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTextFormFieldRow(
      controller: _emailController,
      placeholder: 'Email',
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: CupertinoColors.systemGrey4,
          width: 2.0,
        ),
      ),
      validator: (String? value) {
        final RegExp emailRegex = RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
          caseSensitive: false,
          multiLine: false,
        );
        if (value == null || value.isEmpty || !emailRegex.hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null; // Return null if the input is valid
      },
    );
  }
}
