import 'dart:typed_data';

import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/auth/auth_service.dart';
import 'package:dima_project/widgets/auth/categoriesform_widget.dart';
import 'package:dima_project/widgets/auth/imageform_widget.dart';
import 'package:dima_project/widgets/auth/registrationform_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  final User? user;
  const RegisterPage({super.key, required this.user});

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
  List<String> selectedCategories = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isEnteredWithGoogle = false;
  Uint8List selectedImagePath = Uint8List(0);

  @override
  void initState() {
    super.initState();
    if (widget.user != null && widget.user?.email != null) {
      _isEnteredWithGoogle = true;
      _currentPage = 2;
    }
  }

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
        page = ImageInsertPage(
          imagePath: selectedImagePath,
          imageInsertPageKey: (Uint8List selectedImagePath) {
            this.selectedImagePath = selectedImagePath;
          },
        );
        break;
      case 4:
        page = CategorySelectionForm(
          selectedCategories: selectedCategories,
        );
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
            if (_currentPage == 1 && !_isEnteredWithGoogle) {
              context.go('/');
            } else if (_currentPage == 2 && _isEnteredWithGoogle) {
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
                      onPressed: () =>
                          {if (_formKey.currentState!.validate()) managePage()},
                      color: CupertinoColors.systemPink,
                      child: _currentPage < 4
                          ? const Text('Next')
                          : _isEnteredWithGoogle
                              ? const Text("Confirm")
                              : const Text('Register'),
                    ),
                    const SizedBox(
                        height: 20), // Added spacing between button and text
                  ],
                ),
              ),
              const SizedBox(height: 20), // Added spacing between text and row
              !_isEnteredWithGoogle
                  ? Row(
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
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    selectedCategories.clear();
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPassword.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void managePage() {
    if (_currentPage == 3 && selectedImagePath.isEmpty) {
      debugPrint('Please select an image');
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Invalid choice'),
          content: const Text('Please select an image.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    if (_currentPage < 4) {
      setState(() {
        _currentPage = _currentPage + 1;
      });
    } else {
      if (selectedCategories.isEmpty) {
        debugPrint('Please select at least one category');
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Invalid choice'),
            content: const Text('Please select at least one category.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      } else {
        debugPrint('Registering user...');
        if (_isEnteredWithGoogle) {
          registerUserGoogle(
            UserData(
              name: _nameController.text,
              surname: _surnameController.text,
              email: widget.user!.email!,
              username: _usernameController.text,
              categories: selectedCategories,
              imagePath: selectedImagePath,
              password: '',
            ),
            widget.user!.uid,
          );
        } else {
          // Register the user
          registerUser(
            UserData(
              name: _nameController.text,
              surname: _surnameController.text,
              email: _emailController.text,
              password: _passwordController.text,
              username: _usernameController.text,
              categories: selectedCategories,
              imagePath: selectedImagePath,
            ),
          );
        }
      }
    }
  }

  void registerUser(UserData user) {
    // Register the user
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.registerUser(
      user,
    );
    context.go('/');
  }

  void registerUserGoogle(UserData userData, String uuid) {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.registerUserGoogle(userData, uuid);
    context.go('/home', extra: userData);
  }
}
