import 'dart:typed_data';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/categories_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/widgets/categories_form_widget.dart';
import 'package:dima_project/pages/image_crop_page.dart';
import 'package:dima_project/widgets/create_image_widget.dart';
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
  late TextEditingController _usernameController;
  late String _oldUsername;
  late bool _oldIsPublic;
  bool isPublic = true;
  String? defaultImage;
  final String uid = AuthService.uid;
  @override
  void initState() {
    super.initState();
    ref.read(userProvider(uid));
  }

  void _toggleObscure() {
    setState(() {
      isObscure = !isObscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider(uid));
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
          middle: const Text('Settings'),
          leading: CupertinoButton(
            onPressed: () => _currentPage == 1
                ? Navigator.of(context).pop()
                : selectedCategories.isEmpty
                    ? _showDialog(
                        'Invalid choice', 'Please select at least one category')
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
                      if (!context.mounted) return;
                      BuildContext buildContext = context;
                      // Show the loading dialog
                      showCupertinoDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext newContext) {
                          buildContext = newContext;
                          return const CupertinoAlertDialog(
                            content: CupertinoActivityIndicator(),
                          );
                        },
                      );
                      await _saveUserData();
                      // Close the loading dialog
                      if (buildContext.mounted) {
                        Navigator.of(buildContext).pop();
                      }
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
            ? _buildMainPage(user)
            : CategoriesForm(
                selectedCategories: selectedCategories,
              ));
  }

  Widget _buildMainPage(AsyncValue<UserData> user) {
    return user.when(
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (error, stack) => Text('Error: $error'),
        data: (user) {
          _nameController = TextEditingController(text: user.name);
          _surnameController = TextEditingController(text: user.surname);
          _usernameController = TextEditingController(text: user.username);
          _oldUsername = user.username;
          _oldIsPublic = user.isPublic!;
          selectedCategories = user.categories;
          return Column(
            children: [
              GestureDetector(
                onTap: () => {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => ImageCropPage(
                        defaultImage: defaultImage ?? user.imagePath!,
                        imageType: 0,
                        imagePath: selectedImagePath,
                        imageInsertPageKey: (Uint8List selectedImagePath) {
                          setState(() {
                            this.selectedImagePath = selectedImagePath;
                            defaultImage = '';
                          });
                        },
                      ),
                    ),
                  )
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: selectedImagePath == null
                      ? CreateImageWidget.getUserImage(
                          user.imagePath!,
                          MediaQuery.of(context).size.width >
                                  Constants.limitWidth
                              ? 2
                              : 1)
                      : CreateImageWidget.getUserImageMemory(
                          selectedImagePath!,
                          MediaQuery.of(context).size.width >
                              Constants.limitWidth),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField('Name', user.name, _nameController),
              _buildTextField('Surname', user.surname, _surnameController),
              _buildTextField('Username', user.username, _usernameController),
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
                      leading: const Icon(FontAwesomeIcons.tableList),
                      trailing: const Icon(CupertinoIcons.forward),
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => CategoriesPage(
                              selectedCategories: selectedCategories,
                            ),
                          ),
                        );
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
            ],
          );
        });
  }

  Widget _buildTextField(
      String labelText, String? placeholder, TextEditingController controller) {
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
        _usernameController.text.isEmpty) {
      _showDialog('Invalid choice', 'Please fill all the fields');
      return false;
    }
    debugPrint('Validating first page');

    if (_oldUsername != _usernameController.text &&
        !await _validateUsername(_usernameController.text)) {
      _showDialog('Invalid choice', 'Username is already taken.');
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
        email: '',
        name: _nameController.text,
        surname: _surnameController.text,
        username: _usernameController.text,
        uid: AuthService.uid,
        isPublic: isPublic,
      ),
      selectedImagePath,
      selectedImagePath != null,
      _oldIsPublic != isPublic,
    );

    debugPrint('User data updated');
    ref.invalidate(userProvider(AuthService.uid));
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
    _usernameController.dispose();
    super.dispose();
  }
}
