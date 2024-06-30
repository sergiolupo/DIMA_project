import 'dart:typed_data';

import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/storage_service.dart';
import 'package:dima_project/widgets/auth/categoriesform_widget.dart';
import 'package:dima_project/widgets/auth/imageform_widget.dart';
import 'package:flutter/cupertino.dart';

class SettingsPage extends StatefulWidget {
  final UserData user;
  const SettingsPage({super.key, required this.user});
  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  bool isObscure = true;
  Uint8List? selectedImagePath;
  int _currentPage = 1;
  List<String> selectedCategories = [];
  late final TextEditingController _nameController;
  late final TextEditingController _surnameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _usernameController;
  late final String _oldEmail;
  late final String _oldUsername;
  late final Uint8List _oldImage;

  @override
  void initState() {
    _oldEmail = widget.user.email;
    _oldUsername = widget.user.username;
    _nameController = TextEditingController(text: widget.user.name);
    _surnameController = TextEditingController(text: widget.user.surname);
    _emailController = TextEditingController(text: widget.user.email);
    _passwordController = TextEditingController();
    _usernameController = TextEditingController(text: widget.user.username);
    selectedCategories = widget.user.categories;
    getImageProfile();
    super.initState();
  }

  getImageProfile() async {
    await StorageService.downloadImageFromStorage(widget.user.imagePath!)
        .then((image) {
      setState(() {
        selectedImagePath = image;
        _oldImage = image;
      });
    });
  }

  void toggleObscure() {
    setState(() {
      isObscure = !isObscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (_currentPage) {
      case 1:
        page = firstPage();
        break;
      case 2:
        page = secondPage();
        break;
      default:
        page = firstPage();
    }
    return selectedImagePath == null
        ? const Center(
            child: CupertinoActivityIndicator(),
          )
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              backgroundColor: CupertinoColors.systemPink,
              middle: const Text('Settings'),
              leading: CupertinoButton(
                onPressed: () => {
                  if (_currentPage == 1)
                    {
                      Navigator.of(context).pop(),
                    }
                  else
                    {
                      setState(() {
                        _currentPage = 1;
                      })
                    }
                },
                padding: const EdgeInsets.only(left: 10),
                color: CupertinoColors.systemPink,
                child: const Icon(CupertinoIcons.back),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.only(left: 15, top: 20, right: 15),
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: ListView(
                  children: [
                    page,
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CupertinoButton(
                          onPressed: () async {
                            if (_currentPage == 1) {
                              if (_nameController.text.isEmpty ||
                                  _surnameController.text.isEmpty ||
                                  _emailController.text.isEmpty ||
                                  _passwordController.text.isEmpty ||
                                  _usernameController.text.isEmpty) {
                                showCupertinoDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CupertinoAlertDialog(
                                      title: const Text('Invalid choice'),
                                      content: const Text(
                                          'Please fill all the fields'),
                                      actions: <CupertinoDialogAction>[
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
                                return;
                              }
                              if (_oldEmail != _emailController.text) {
                                //check if the mail is valid
                                bool isEmailTaken =
                                    await DatabaseService.isEmailTaken(
                                        _emailController.text);

                                if (isEmailTaken) {
                                  debugPrint('Email is already taken');
                                  if (!context.mounted) return;
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                      title: const Text('Invalid choice'),
                                      content:
                                          const Text('Email is already taken.'),
                                      actions: [
                                        CupertinoDialogAction(
                                          child: const Text('OK'),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                  );
                                  return;
                                }

                                final RegExp emailRegex = RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  caseSensitive: false,
                                  multiLine: false,
                                );
                                if (!emailRegex
                                    .hasMatch(_emailController.text)) {
                                  debugPrint('Invalid email');
                                  if (!context.mounted) return;
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                      title: const Text('Invalid choice'),
                                      content: const Text('Invalid email.'),
                                      actions: [
                                        CupertinoDialogAction(
                                          child: const Text('OK'),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                  );
                                  return;
                                }
                              }
                              if (_oldUsername != _usernameController.text) {
                                //check if the username is valid
                                bool isUsernameTaken =
                                    await DatabaseService.isUsernameTaken(
                                        _usernameController.text);
                                if (isUsernameTaken) {
                                  debugPrint('Username is already taken');
                                  if (!context.mounted) return;
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                      title: const Text('Invalid choice'),
                                      content: const Text(
                                          'Username is already taken.'),
                                      actions: [
                                        CupertinoDialogAction(
                                          child: const Text('OK'),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                  );
                                  return;
                                }
                              }
                              if (_passwordController.text.length < 6) {
                                debugPrint('Password is too short');
                                if (!context.mounted) return;
                                showCupertinoDialog(
                                  context: context,
                                  builder: (context) => CupertinoAlertDialog(
                                    title: const Text('Invalid choice'),
                                    content: const Text(
                                        'Password must be at least 6 characters long.'),
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
                              setState(() {
                                _currentPage = 2;
                              });
                            } else {
                              // Save the user data
                              if (selectedCategories.isEmpty) {
                                showCupertinoDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CupertinoAlertDialog(
                                      title: const Text('Invalid choice'),
                                      content: const Text(
                                          'Please select at least one category'),
                                      actions: <CupertinoDialogAction>[
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
                                return;
                              } else {
                                await DatabaseService.updateUserInformation(
                                  UserData(
                                    categories: selectedCategories,
                                    password: _passwordController.text,
                                    email: _emailController.text,
                                    name: _nameController.text,
                                    surname: _surnameController.text,
                                    username: _usernameController.text,
                                    uuid: widget.user.uuid,
                                  ),
                                  selectedImagePath!,
                                  _oldImage == selectedImagePath ? false : true,
                                );
                              }
                              if (!context.mounted) return;
                              Navigator.of(context).pop();
                            }
                          },
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          color: CupertinoColors.systemPink,
                          borderRadius: BorderRadius.circular(20),
                          child: Text(
                            _currentPage == 1 ? 'NEXT' : 'SAVE',
                            style: const TextStyle(
                              fontSize: 15,
                              letterSpacing: 2,
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildTextField(String labelText, String? placeholder, bool isObscure,
      TextEditingController controller) {
    // Determine whether to show the eye icon based on the labelText
    bool showEyeIcon = labelText == 'Password';

    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 5),
          CupertinoTextField(
            placeholder: placeholder,
            controller: controller,
            padding: const EdgeInsets.all(15),
            obscureText: isObscure,
            suffix: showEyeIcon
                ? isObscure
                    ? CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: toggleObscure,
                        child: const Icon(
                          CupertinoIcons.eye_slash,
                          color: CupertinoColors.systemGrey,
                        ),
                      )
                    : CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: toggleObscure,
                        child: const Icon(
                          CupertinoIcons.eye,
                          color: CupertinoColors.systemGrey,
                        ),
                      )
                : null,
            decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.systemGrey),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget firstPage() {
    return Column(
      children: [
        widget.user.imagePath != null
            ? ImageInsertForm(
                imageForGroup: false,
                imagePath: selectedImagePath,
                imageInsertPageKey: (Uint8List selectedImagePath) {
                  this.selectedImagePath = selectedImagePath;
                },
              )
            : ImageInsertForm(
                imageForGroup: false,
                imagePath: selectedImagePath,
                imageInsertPageKey: (Uint8List selectedImagePath) {
                  this.selectedImagePath = selectedImagePath;
                },
              ),
        const SizedBox(
          height: 30,
        ),
        _buildTextField('Name', widget.user.name, false, _nameController),
        _buildTextField(
            'Surname', widget.user.surname, false, _surnameController),
        _buildTextField(
            'Username', widget.user.username, false, _usernameController),
        _buildTextField('Email', widget.user.email, false, _emailController),
        _buildTextField(
            'Password', widget.user.password, isObscure, _passwordController),
      ],
    );
  }

  Widget secondPage() {
    return CategorySelectionForm(
      selectedCategories: selectedCategories,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
