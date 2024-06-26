import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/options/settings_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class OptionsPage extends StatefulWidget {
  final UserData user;
  const OptionsPage({super.key, required this.user});
  @override
  _OptionsPageState createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoColors.systemPink,
          middle: Text('Options'),
          leading: CupertinoButton(
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.only(left: 10),
            color: CupertinoColors.systemPink,
            child: Icon(CupertinoIcons.back),
          )),
      child: SafeArea(
        child: ListView(
          children: [
            /*Container(
              color: CupertinoColors.systemBlue,
              child: Column(
                children: [
                  SizedBox(height: 20),
                  ClipOval(
                      child: CreateImageWidget.getUserImage(
                          widget.user.imagePath!)),
                  SizedBox(height: 10),
                  Text(widget.user.name,
                      style: TextStyle(color: CupertinoColors.white)),
                  Text(widget.user.email,
                      style: TextStyle(color: CupertinoColors.white)),
                  SizedBox(height: 20),
                ],
              ),
            ),*/
            CupertinoListSection(
              children: [
                CupertinoListTile(
                  leading: Icon(CupertinoIcons.heart),
                  title: Text('Favorites'),
                  onTap: () => null,
                ),
                CupertinoListTile(
                  leading: Icon(CupertinoIcons.person),
                  title: Text('Friends'),
                  onTap: () => null,
                ),
                CupertinoListTile(
                  leading: Icon(CupertinoIcons.share),
                  title: Text('Share'),
                  onTap: () => null,
                ),
                CupertinoListTile(
                  leading: Icon(CupertinoIcons.bell),
                  title: Text('Request'),
                ),
              ],
            ),
            CupertinoListSection(
              children: [
                CupertinoListTile(
                  leading: Icon(CupertinoIcons.settings),
                  title: Text('Settings'),
                  onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) =>
                              SettingsPage(user: widget.user))),
                ),
                CupertinoListTile(
                  leading: Icon(CupertinoIcons.doc),
                  title: Text('Policies'),
                  onTap: () => null,
                ),
              ],
            ),
            CupertinoListSection(
              children: [
                CupertinoListTile(
                  leading: Icon(CupertinoIcons.arrow_right_to_line),
                  title: Text('Exit'),
                  onTap: () => _signOut(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CupertinoListTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final VoidCallback? onTap;

  CupertinoListTile({required this.leading, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            leading,
            SizedBox(width: 16),
            Expanded(child: title),
            Icon(CupertinoIcons.forward),
          ],
        ),
      ),
    );
  }
}

class CupertinoListSection extends StatelessWidget {
  final List<Widget> children;

  CupertinoListSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

void _signOut(BuildContext context) {
  DatabaseService.updateActiveStatus(false);
  AuthService.signOut();
  context.go('/login');
}
