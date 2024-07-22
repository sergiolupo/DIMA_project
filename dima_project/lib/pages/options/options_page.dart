import 'package:dima_project/pages/options/request_page.dart';
import 'package:dima_project/pages/options/settings_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OptionsPage extends ConsumerStatefulWidget {
  final String uuid;
  const OptionsPage({super.key, required this.uuid});
  @override
  OptionsPageState createState() => OptionsPageState();
}

class OptionsPageState extends ConsumerState<OptionsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
          middle: Text(
            'Options',
            style: TextStyle(
                color: CupertinoTheme.of(context).primaryColor, fontSize: 18),
          ),
          leading: CupertinoButton(
            onPressed: () => Navigator.of(context).pop(),
            padding: const EdgeInsets.only(left: 10),
            child: Icon(
              CupertinoIcons.back,
              color: CupertinoTheme.of(context).primaryColor,
            ),
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
                                ShowRequestPage(uuid: widget.uuid)))
                  },
                  title: const Text('Request'),
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.settings),
                  title: const Text('Settings'),
                  onTap: () => Navigator.of(context, rootNavigator: true).push(
                      CupertinoPageRoute(
                          builder: (context) =>
                              SettingsPage(uuid: widget.uuid))),
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
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.arrow_right_to_line),
                  title: const Text('Delete Account'),
                  onTap: () => deleteAccount(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void deleteAccount() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext newContext) {
        return CupertinoAlertDialog(
          title: const Text('Delete Account'),
          content: const Text('Are you sure you want to delete your account?'),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(newContext).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text('Delete'),
              onPressed: () async {
                await DatabaseService.deleteUser(widget.uuid);
                ref.invalidate(userProvider);
                ref.invalidate(followerProvider);
                ref.invalidate(followingProvider);
                ref.invalidate(groupsProvider);
                ref.invalidate(joinedEventsProvider);
                ref.invalidate(createdEventsProvider);
                ref.invalidate(eventProvider);
                AuthService.signOut();
                AuthService.deleteUser();
                if (!mounted) return;
                Navigator.of(context).pop();
                if (!mounted) return;
                context.go('/login');
              },
            ),
          ],
        );
      },
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
