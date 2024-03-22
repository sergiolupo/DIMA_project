import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/auth/auth_service.dart';
import 'package:dima_project/widgets/login/categoriesform_widget.dart';
import 'package:dima_project/widgets/login/registrationform_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  int _currentPage = 1;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (_currentPage) {
      case 2:
        page = PersonalInformationForm(
          nameController: _nameController,
          surnameController: _surnameController,
          usernameController: _usernameController,
        );
        break;
      case 3:
        page = const CategorySelectionPage();
        break;
      default:
        page = CredentialsInformationForm(
          emailController: _emailController,
          passwordController: _passwordController,
          confirmPasswordController: _confirmPassword,
        );
        break;
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          onPressed: () {
            if (_currentPage == 1) {
              context.go('/');
            } else {
              setState(() {
                _currentPage = _currentPage - 1;
              });
            }
          },
        ),
        middle: const Text(
          'Register',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.black,
          ),
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    page,
                    const SizedBox(height: 20.0),
                    CupertinoButton(
                      onPressed: () => {
                        //if (_formKey.currentState!.validate())
                        managePage()
                      },
                      color: CupertinoColors.systemPink,
                      child: _currentPage < 3
                          ? const Text('Next')
                          : const Text('Register'),
                    ),
                    const SizedBox(
                        height: 20), // Added spacing between button and text
                  ],
                ),
              ),
              const SizedBox(height: 20), // Added spacing between text and row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already a member?'),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      context.go('/');
                    },
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        color: CupertinoColors.activeBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void managePage() {
    if (_currentPage < 3) {
      setState(() {
        _currentPage = _currentPage + 1;
      });
    } else {
      // Register the user
      registerUser(User(
        name: _nameController.text,
        surname: _surnameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text,
      ));
    }
  }

  void registerUser(User user) {
    debugPrint(
        'Registering user: ${user.email} : ${user.password}, ${user.name} : ${user.surname}, ${user.username}');
    // Register the user
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.registerUser(user.email, user.password);
    context.go('/');
  }
}
