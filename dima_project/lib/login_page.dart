import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          'Login',
          style: TextStyle(
            fontSize: 24, // Adjust font size as needed
            fontWeight: FontWeight.bold, // Adjust font weight as needed
            color: CupertinoColors.systemPink, // Adjust text color as needed
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
              child: IntrinsicHeight(
                child: Form(
                  key: formKey,
                  child: Container(
                    color: CupertinoColors.white,
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CupertinoTextFormFieldRow(
                          controller: _usernameController,
                          placeholder: 'Username',
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
                              return 'Please enter a username';
                            }
                            return null; // Return null if the input is valid
                          },
                        ),
                        CupertinoTextFormFieldRow(
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
                        ),
                        CupertinoButton(
                          onPressed: () {
                            // Validate the form before proceeding
                            if (formKey.currentState!.validate()) {
                              _checkCredentials(
                                  context,
                                  _usernameController.text,
                                  _passwordController.text);
                            }
                          },
                          color: CupertinoColors.systemPink,
                          child: const Text('Login'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
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
