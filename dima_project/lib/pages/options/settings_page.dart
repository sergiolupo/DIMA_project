import 'dart:typed_data';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/storage_service.dart';
import 'package:dima_project/widgets/auth/categoriesform_widget.dart';
import 'package:dima_project/widgets/auth/image_crop_page.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';

class SettingsPage extends StatefulWidget {
  final String uuid;
  const SettingsPage({super.key, required this.uuid});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
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

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    user = await DatabaseService.getUserData(widget.uuid);
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
                    : setState(() => _currentPage = 1),
                padding: const EdgeInsets.only(left: 10),
                child: Icon(
                  CupertinoIcons.back,
                  color: CupertinoTheme.of(context).primaryColor,
                ),
              ),
            ),
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                children: [
                  _currentPage == 1 ? _buildFirstPage() : _buildSecondPage(),
                  const SizedBox(height: 20),
                  _buildActionButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
  }

  Widget _buildFirstPage() {
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
        _buildPublicProfileSwitch(),
        const SizedBox(height: 20),
        _buildTextField('Email', user!.email, false, _emailController),
        _buildTextField(
            'Password', user!.password, isObscure, _passwordController),
      ],
    );
  }

  Widget _buildSecondPage() {
    return CategorySelectionForm(
      selectedCategories: selectedCategories,
    );
  }

  Widget _buildTextField(String labelText, String? placeholder, bool isObscure,
      TextEditingController controller) {
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
              border: Border.all(color: CupertinoColors.systemGrey),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublicProfileSwitch() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Public Profile',
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.systemGrey),
        ),
        const SizedBox(width: 10),
        Transform.scale(
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
      ],
    );
  }

  Widget _buildActionButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CupertinoButton(
          onPressed: _handleActionButtonPress,
          padding: const EdgeInsets.symmetric(horizontal: 50),
          color: CupertinoColors.systemPink,
          borderRadius: BorderRadius.circular(20),
          child: Text(
            _currentPage == 1 ? 'NEXT' : 'SAVE',
            style: const TextStyle(
                fontSize: 15,
                letterSpacing: 2,
                color: CupertinoColors.white,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Future<void> _handleActionButtonPress() async {
    if (_currentPage == 1) {
      if (await _validateFirstPage()) {
        setState(() {
          _currentPage = 2;
        });
      }
    } else {
      if (selectedCategories.isEmpty) {
        _showDialog('Invalid choice', 'Please select at least one category');
      } else {
        await _saveUserData();
        if (mounted) Navigator.of(context).pop();
      }
    }
  }

  Future<bool> _validateFirstPage() async {
    if (_nameController.text.isEmpty ||
        _surnameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _usernameController.text.isEmpty) {
      _showDialog('Invalid choice', 'Please fill all the fields');
      return false;
    }
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
    if (_passwordController.text.length < 6) {
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
        uuid: user!.uuid,
        isPublic: isPublic,
      ),
      selectedImagePath!,
      _oldImage != selectedImagePath,
      user!.isPublic != isPublic,
    );
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
