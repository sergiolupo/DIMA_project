import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        color: CupertinoColors.white,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UsernameInputField(_usernameController),
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
            CupertinoButton(
              onPressed: () {
                context.go('/forgotpassword');
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(color: CupertinoColors.activeBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkCredentials(
      BuildContext context, String email, String password) async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return const CupertinoAlertDialog(
          content: CupertinoActivityIndicator(),
        );
      },
    );

    try {
      debugPrint("Trying to Login...");
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      debugPrint("Signed In");
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
}

class UsernameInputField extends StatelessWidget {
  final TextEditingController _usernameController;

  const UsernameInputField(this._usernameController, {super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTextFormFieldRow(
      controller: _usernameController,
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
        if (value == null || value.isEmpty || !value.contains('@')) {
          return 'Please enter a valid email address';
        }
        return null; // Return null if the input is valid
      },
    );
  }
}

class PasswordInputField extends StatelessWidget {
  final TextEditingController _passwordController;

  const PasswordInputField(this._passwordController, {super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTextFormFieldRow(
      controller: _passwordController,
      placeholder: 'Password',
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
          return 'Please enter a password';
        }
        return null; // Return null if the input is valid
      },
      obscureText: true,
    );
  }
}
