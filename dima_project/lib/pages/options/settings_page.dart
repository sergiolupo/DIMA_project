import 'dart:typed_data';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/services/storage_service.dart';
import 'package:dima_project/widgets/auth/categoriesform_widget.dart';
import 'package:dima_project/widgets/auth/image_crop_page.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends ConsumerState<SettingsPage> {
  bool isObscure = true;
  Uint8List? selectedImagePath;
  int _currentPage = 1;
  List<String> selectedCategories = [];
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _usernameController;
  late String _oldEmail;
  late String _oldUsername;
  late Uint8List _oldImage;
  bool isPublic = true;
  UserData? user;
  final String uid = AuthService.uid;
  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    user = await DatabaseService.getUserData(uid);
    if (user != null) {
      setState(() {
        _oldEmail = user!.email;
        _oldUsername = user!.username;
        _nameController = TextEditingController(text: user!.name);
        _surnameController = TextEditingController(text: user!.surname);
        _emailController = TextEditingController(text: user!.email);
        _passwordController = TextEditingController();
        _usernameController = TextEditingController(text: user!.username);
        isPublic = user!.isPublic ?? true;
        selectedCategories = user!.categories;
      });
      await _fetchProfileImage();
    }
  }

  Future<void> _fetchProfileImage() async {
    final image =
        await StorageService.downloadImageFromStorage(user!.imagePath!);
    setState(() {
      selectedImagePath = image;
      _oldImage = image;
    });
  }

  void _toggleObscure() {
    setState(() {
      isObscure = !isObscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    return selectedImagePath == null || user == null
        ? const Center(child: CupertinoActivityIndicator())
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
              middle: const Text('Settings'),
              leading: CupertinoButton(
                onPressed: () => _currentPage == 1
                    ? Navigator.of(context).pop()
                    : selectedCategories.isEmpty
                        ? _showDialog('Invalid choice',
                            'Please select at least one category')
                        : setState(() {
                            _currentPage = 1;
                          }),
                padding: const EdgeInsets.only(left: 10),
                child: Icon(
                  CupertinoIcons.back,
                  color: CupertinoTheme.of(context).primaryColor,
                ),
              ),
              trailing: _currentPage == 1
                  ? CupertinoButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: () async {
                        if (await _validatePage()) {
                          _saveUserData();

                          if (context.mounted) Navigator.of(context).pop();
                        }
                      },
                      child: Text(
                        'Done',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: CupertinoTheme.of(context).primaryColor,
                        ),
                      ))
                  : null,
            ),
            child: _currentPage == 1
                ? _buildMainPage()
                : CategorySelectionForm(
                    selectedCategories: selectedCategories,
                  ));
  }

  Widget _buildMainPage() {
    return Column(
      children: [
        GestureDetector(
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
            selectedImagePath!,
          ),
        ),
        const SizedBox(height: 30),
        _buildTextField('Name', user!.name, false, _nameController),
        _buildTextField('Surname', user!.surname, false, _surnameController),
        _buildTextField('Username', user!.username, false, _usernameController),
        _buildTextField('Email', user!.email, false, _emailController),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(right: 10.0, left: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: CupertinoTheme.of(context).primaryContrastingColor,
            ),
            child: Column(children: [
              CupertinoListTile(
                title: const Text('Categories'),
                leading: const Icon(FontAwesomeIcons.thList),
                trailing: const Icon(CupertinoIcons.forward),
                onTap: () {
                  setState(() {
                    _currentPage = 2;
                  });
                },
              ),
              Container(
                height: 1,
                color: CupertinoColors.separator,
              ),
              CupertinoListTile(
                title: const Text('Public Profile'),
                leading: isPublic
                    ? const Icon(CupertinoIcons.lock_open_fill)
                    : const Icon(CupertinoIcons.lock_fill),
                trailing: Transform.scale(
                  scale: 0.75,
                  child: CupertinoSwitch(
                    value: isPublic,
                    onChanged: (bool value) {
                      setState(() {
                        isPublic = value;
                      });
                    },
                  ),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 20),
        !user!.isSignedInWithGoogle!
            ? _buildTextField(
                'Password', user!.password, isObscure, _passwordController)
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildTextField(String labelText, String? placeholder, bool isObscure,
      TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.systemGrey),
          ),
          const SizedBox(height: 5),
          CupertinoTextField(
            placeholder: placeholder,
            controller: controller,
            padding: const EdgeInsets.all(15),
            obscureText: isObscure,
            suffix: labelText == 'Password'
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _toggleObscure,
                    child: Icon(
                      isObscure ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                      color: CupertinoColors.systemGrey,
                    ),
                  )
                : null,
            decoration: BoxDecoration(
              color: CupertinoTheme.of(context).primaryContrastingColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _validatePage() async {
    if (_nameController.text.isEmpty ||
        _surnameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        (_passwordController.text.isEmpty && !user!.isSignedInWithGoogle!) ||
        _usernameController.text.isEmpty) {
      _showDialog('Invalid choice', 'Please fill all the fields');
      return false;
    }
    debugPrint('Validating first page');
    if (_oldEmail != _emailController.text &&
        !_validateEmail(_emailController.text)) {
      _showDialog('Invalid choice', 'Invalid email.');
      return false;
    }
    if (_oldUsername != _usernameController.text &&
        !await _validateUsername(_usernameController.text)) {
      _showDialog('Invalid choice', 'Username is already taken.');
      return false;
    }
    if (_passwordController.text.length < 6 && !user!.isSignedInWithGoogle!) {
      _showDialog(
          'Invalid choice', 'Password must be at least 6 characters long.');
      return false;
    }
    return true;
  }

  bool _validateEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        caseSensitive: false, multiLine: false);
    if (!emailRegex.hasMatch(email)) {
      debugPrint('Invalid email');
      return false;
    }
    return true;
  }

  Future<bool> _validateUsername(String username) async {
    final isUsernameTaken = await DatabaseService.isUsernameTaken(username);
    if (isUsernameTaken) {
      debugPrint('Username is already taken');
      return false;
    }
    return true;
  }

  Future<void> _saveUserData() async {
    await DatabaseService.updateUserInformation(
      UserData(
        categories: selectedCategories,
        password: _passwordController.text,
        email: _emailController.text,
        name: _nameController.text,
        surname: _surnameController.text,
        username: _usernameController.text,
        uid: user!.uid,
        isPublic: isPublic,
      ),
      selectedImagePath!,
      _oldImage != selectedImagePath,
      user!.isPublic != isPublic,
    );
    debugPrint('User data updated');
    ref.invalidate(userProvider(user!.uid!));
  }

  void _showDialog(String title, String content) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
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
