import 'dart:typed_data';

import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/helper_functions.dart';
import 'package:dima_project/widgets/auth/categoriesform_widget.dart';
import 'package:dima_project/widgets/auth/image_crop_page.dart';
import 'package:dima_project/widgets/auth/registrationform_widget.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

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
  String pageName = 'Credentials Information';
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
        pageName = 'Personal Information';
        break;
      case 3:
        page = GestureDetector(
          onTap: () => {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => ImageCropPage(
                  imageType: 0,
                  imagePath: selectedImagePath,
                  imageInsertPageKey: (Uint8List selectedImagePath) {
                    setState(() {
                      this.selectedImagePath = selectedImagePath;
                    });
                  },
                ),
              ),
            )
          },
          child: CreateImageWidget.getUserImageMemory(
            selectedImagePath,
          ),
        );
        pageName = 'Image Selection';
        break;
      case 4:
        page = CategorySelectionForm(
          selectedCategories: selectedCategories,
        );
        pageName = 'Category Selection';
        break;
      default:
        page = CredentialsInformationForm(
          emailController: _emailController,
          passwordController: _passwordController,
          confirmPasswordController: _confirmPassword,
        );
        pageName = 'Credentials Information';
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
        middle: Text(
          pageName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.systemPink,
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
                  children: <Widget>[
                    page,
                    const SizedBox(height: 20.0),
                    CupertinoButton(
                      onPressed: () =>
                          {if (_formKey.currentState!.validate()) managePage()},
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      color: CupertinoColors.systemPink,
                      borderRadius: BorderRadius.circular(20),
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
                            context.go('/login');
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

  Future<void> managePage() async {
    if (_currentPage == 1) {
      bool isEmailTaken =
          await DatabaseService.isEmailTaken(_emailController.text);

      if (isEmailTaken) {
        debugPrint('Email is already taken');
        if (!mounted) return;
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Invalid choice'),
            content: const Text('Email is already taken.'),
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
    }

    if (_currentPage == 2) {
      bool isUsernameTaken =
          await DatabaseService.isUsernameTaken(_usernameController.text);
      if (isUsernameTaken) {
        debugPrint('Username is already taken');
        if (!mounted) return;
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Invalid choice'),
            content: const Text('Username is already taken.'),
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
    }

    if (_currentPage < 4) {
      setState(() {
        _currentPage = _currentPage + 1;
      });
    } else {
      if (!mounted) return;
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
              isSignedInWithGoogle: true,
            ),
            widget.user!.uid,
            selectedImagePath,
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
              isSignedInWithGoogle: false,
            ),
            selectedImagePath,
          );
        }
      }
    }
  }

  Future<void> registerUser(UserData user, Uint8List imagePath) async {
    // Register the user
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return const CupertinoAlertDialog(
          content: CupertinoActivityIndicator(),
        );
      },
    );

    await AuthService.registerUser(
      user,
      imagePath,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    context.go('/login');
  }

  void registerUserGoogle(
      UserData userData, String uuid, Uint8List imagePath) async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return const CupertinoAlertDialog(
          content: CupertinoActivityIndicator(),
        );
      },
    );
    try {
      await DatabaseService.registerUserWithUUID(userData, uuid, imagePath);
      await HelperFunctions.saveUserLoggedInStatus(true);
      await HelperFunctions.saveUid(uuid);
    } catch (e) {
      return;
    }
    debugPrint('Navigating to Home Page');

    if (!mounted) return;
    Navigator.of(context).pop();
    context.go('/home');
  }
}
