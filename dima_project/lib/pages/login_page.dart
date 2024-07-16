import 'package:dima_project/widgets/auth/forgotpassword_widget.dart';
import 'package:dima_project/widgets/auth/loginform_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  bool _showLogin = true;
  @override
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: !_showLogin
          ? CupertinoNavigationBar(
              leading: CupertinoNavigationBarBackButton(
                onPressed: () {
                  setState(() {
                    _showLogin = !_showLogin;
                  });
                },
              ),
              backgroundColor: CupertinoColors.white,
              middle: const Text(
                'AGORAPP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.systemPink,
                ),
              ),
            )
          : const CupertinoNavigationBar(
              backgroundColor: CupertinoColors.white,
              middle: Text(
                'AGORAPP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.systemPink,
                ),
              ),
            ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/logo.png',
              height: 200,
            ),
          ),
          _showLogin
              ? LoginForm(_usernameController)
              : ForgotPasswordForm(_usernameController),
          CupertinoButton(
            onPressed: () {
              setState(() {
                _showLogin = !_showLogin;
              });
            },
            child: Text(
              _showLogin ? 'Forgot Password?' : 'Back to Login',
              style: const TextStyle(color: CupertinoColors.activeBlue),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('Not a member?'),
            const SizedBox(width: 4),
            GestureDetector(
                onTap: () {
                  context.go('/register', extra: null);
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
}
