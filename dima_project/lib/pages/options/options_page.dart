import 'package:dima_project/pages/options/request_page.dart';
import 'package:dima_project/pages/options/settings_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OptionsPage extends ConsumerStatefulWidget {
  const OptionsPage({
    super.key,
  });
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
                            builder: (context) => const ShowRequestPage()))
                  },
                  title: const Text('Request'),
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.settings),
                  title: const Text('Settings'),
                  onTap: () => Navigator.of(context, rootNavigator: true).push(
                      CupertinoPageRoute(
                          builder: (context) => const SettingsPage())),
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.doc),
                  title: const Text('Policies'),
                  onTap: () => {},
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.trash),
                  title: const Text('Delete Account'),
                  onTap: () => deleteAccount(),
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.arrow_right_to_line),
                  title: const Text('Exit'),
                  onTap: () async {
                    await _signOut(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return const CupertinoAlertDialog(
          content: CupertinoActivityIndicator(),
        );
      },
    );
    try {
      await DatabaseService.updateToken('');
      AuthService.signOut();
      ref.invalidate(userProvider);
      ref.invalidate(followerProvider);
      ref.invalidate(followingProvider);
      ref.invalidate(groupsProvider);
      ref.invalidate(joinedEventsProvider);
      ref.invalidate(createdEventsProvider);
      ref.invalidate(eventProvider);
      if (!context.mounted) return;
      context.go('/login');
    } catch (e) {
      debugPrint("Failed to sign out: $e");
    }
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
                Navigator.of(newContext).pop();
                showCupertinoDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const CupertinoAlertDialog(
                      content: CupertinoActivityIndicator(),
                    );
                  },
                );
                await DatabaseService.updateToken('');
                await DatabaseService.deleteUser();
                ref.invalidate(userProvider);
                ref.invalidate(followerProvider);
                ref.invalidate(followingProvider);
                ref.invalidate(groupsProvider);
                ref.invalidate(joinedEventsProvider);
                ref.invalidate(createdEventsProvider);
                ref.invalidate(eventProvider);
                await AuthService.deleteUser();
                if (!mounted) return;
                Navigator.of(context).pop();
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
