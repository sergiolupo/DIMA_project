import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/options/settings_page.dart';
import 'package:dima_project/pages/requests_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class OptionsPage extends StatefulWidget {
  final UserData user;
  const OptionsPage({super.key, required this.user});
  @override
  OptionsPageState createState() => OptionsPageState();
}

class OptionsPageState extends State<OptionsPage> {
  Stream<int>? _numFollowRequests;
  @override
  void initState() {
    init();
    super.initState();
  }

  init() {
    _numFollowRequests =
        DatabaseService.getFollowRequests(widget.user.uuid!).map(
      (event) {
        return event.length;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _numFollowRequests == null
        ? const Center(child: CupertinoActivityIndicator())
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
                backgroundColor: CupertinoColors.systemPink,
                middle: const Text('Options'),
                leading: CupertinoButton(
                  onPressed: () => Navigator.of(context).pop(),
                  padding: const EdgeInsets.only(left: 10),
                  color: CupertinoColors.systemPink,
                  child: const Icon(CupertinoIcons.back),
                )),
            child: SafeArea(
              child: ListView(
                children: [
                  CupertinoListSection(
                    children: [
                      CupertinoListTile(
                        leading: const Icon(CupertinoIcons.heart),
                        title: const Text('Favorites'),
                        onTap: () => {},
                      ),
                      CupertinoListTile(
                        leading: const Icon(CupertinoIcons.person),
                        title: const Text('Friends'),
                        onTap: () => {},
                      ),
                      CupertinoListTile(
                        leading: const Icon(CupertinoIcons.share),
                        title: const Text('Share'),
                        onTap: () => {},
                      ),
                      CupertinoListTile(
                        leading: const Icon(CupertinoIcons.bell),
                        onTap: () => {
                          Navigator.of(context, rootNavigator: true).push(
                              CupertinoPageRoute(
                                  builder: (context) =>
                                      RequestsPage(uuid: widget.user.uuid!)))
                        },
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Request'),
                            StreamBuilder<int>(
                              stream: _numFollowRequests,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return snapshot.data! > 0
                                      ? Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: CupertinoColors.systemRed,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            snapshot.data.toString(),
                                            style: const TextStyle(
                                              color: CupertinoColors.white,
                                            ),
                                          ),
                                        )
                                      : const SizedBox();
                                } else {
                                  return const SizedBox();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      CupertinoListTile(
                        leading: const Icon(CupertinoIcons.settings),
                        title: const Text('Settings'),
                        onTap: () => Navigator.of(context, rootNavigator: true)
                            .push(CupertinoPageRoute(
                                builder: (context) =>
                                    SettingsPage(user: widget.user))),
                      ),
                      CupertinoListTile(
                        leading: const Icon(CupertinoIcons.doc),
                        title: const Text('Policies'),
                        onTap: () => {},
                      ),
                      CupertinoListTile(
                        leading: const Icon(CupertinoIcons.arrow_right_to_line),
                        title: const Text('Exit'),
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

  const CupertinoListTile(
      {super.key, required this.leading, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 16),
            Expanded(child: title),
            const Icon(CupertinoIcons.forward),
          ],
        ),
      ),
    );
  }
}

class CupertinoListSection extends StatelessWidget {
  final List<Widget> children;

  const CupertinoListSection({super.key, required this.children});

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
