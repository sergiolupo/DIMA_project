import 'package:dima_project/utils/constants.dart';
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
  final TextEditingController _passwordController = TextEditingController();

  bool _showLogin = true;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        leading: !_showLogin
            ? CupertinoNavigationBarBackButton(
                color: CupertinoTheme.of(context).primaryColor,
                onPressed: () {
                  setState(() {
                    _showLogin = !_showLogin;
                  });
                },
              )
            : null,
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        middle: Text(
          'AGORAPP',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: CupertinoTheme.of(context).primaryColor,
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (MediaQuery.of(context).size.width > Constants.limitWidth)
                Expanded(
                  child: Image.asset(
                    'assets/images/landing.png',
                    fit: BoxFit.contain,
                  ),
                ),
              SizedBox(
                width: MediaQuery.of(context).size.width > Constants.limitWidth
                    ? 600
                    : MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/logoDark.png',
                        height: 200,
                      ),
                    ),
                    _showLogin
                        ? LoginForm(_usernameController, _passwordController)
                        : ForgotPasswordForm(_usernameController),
                    CupertinoButton(
                      onPressed: () {
                        setState(() {
                          _showLogin = !_showLogin;
                        });
                      },
                      child: Text(
                        _showLogin ? 'Forgot Password?' : 'Back to Login',
                        style: TextStyle(
                            color: CupertinoTheme.of(context).primaryColor),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Not a member?'),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            context.go('/register', extra: null);
                          },
                          child: Text(
                            'Register now',
                            style: TextStyle(
                              color: CupertinoTheme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
