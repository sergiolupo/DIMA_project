import 'package:dima_project/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:dima_project/pages/userprofile_page.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatefulWidget {
  final UserData user;
  const SettingsPage({super.key, required this.user});
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isObscure = true;
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemPink,
        middle: const Text('Settings'),
        leading: CupertinoButton(
          onPressed: () => {
            Navigator.of(context).pop(),
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
                Center(
                    child: Stack(
                  children: [
                    CreateImageWidget.getUserImage(widget.user.imagePath!),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 4,
                              color: CupertinoColors.white,
                            ),
                            color: CupertinoColors.systemPink,
                          ),
                          child: const Icon(
                            CupertinoIcons.pencil,
                            color: CupertinoColors.white,
                          ),
                        ))
                  ],
                )),
                const SizedBox(
                  height: 30,
                ),
                _buildTextField('Name', widget.user.name, false),
                _buildTextField('Surname', widget.user.surname, false),
                _buildTextField('Username', widget.user.username, false),
                _buildTextField('Email', widget.user.email, false),
                _buildTextField('Password', widget.user.password, isObscure),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) =>
                                  UserProfile(user: widget.user))),
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      borderRadius: BorderRadius.circular(20),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(
                          fontSize: 15,
                          letterSpacing: 2,
                          color: CupertinoColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () {},
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      color: CupertinoColors.systemPink,
                      borderRadius: BorderRadius.circular(20),
                      child: const Text(
                        'SAVE',
                        style: TextStyle(
                          fontSize: 15,
                          letterSpacing: 2,
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )),
      ),
    );
  }
}

Widget _buildTextField(String labelText, String? placeholder, bool isObscure) {
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
          padding: const EdgeInsets.all(15),
          obscureText: isObscure,
          suffix: isObscure
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    /*setState(() {
                      isObscure = !isObscure;
                    });*/
                  },
                  child: const Icon(
                    CupertinoIcons.eye,
                    color: CupertinoColors.activeGreen,
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
