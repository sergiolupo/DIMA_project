import 'package:dima_project/pages/options/delete_account_page.dart';
import 'package:dima_project/pages/options/request_page.dart';
import 'package:dima_project/pages/options/settings_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/notification_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/option_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OptionsPage extends ConsumerStatefulWidget {
  final AuthService authService;
  final NotificationService notificationService;
  const OptionsPage({
    super.key,
    required this.authService,
    required this.notificationService,
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
    final DatabaseService databaseService = ref.watch(databaseServiceProvider);
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OptionTile(
                  leading: const Icon(CupertinoIcons.bell),
                  onTap: () => {
                    Navigator.of(context, rootNavigator: true).push(
                        CupertinoPageRoute(
                            builder: (context) => ShowRequestPage(
                                databaseService: databaseService)))
                  },
                  title: const Text('Request'),
                ),
                OptionTile(
                  leading: const Icon(CupertinoIcons.settings),
                  title: const Text('Settings'),
                  onTap: () => Navigator.of(context, rootNavigator: true)
                      .push(CupertinoPageRoute(
                          builder: (context) => SettingsPage(
                                notificationService: widget.notificationService,
                              ))),
                ),
                OptionTile(
                  leading: const Icon(CupertinoIcons.trash),
                  title: const Text('Delete Account'),
                  onTap: () => deleteAccount(databaseService),
                ),
                OptionTile(
                  leading: const Icon(CupertinoIcons.arrow_right_to_line),
                  title: const Text('Exit'),
                  onTap: () async {
                    await _signOut(context, databaseService);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(
      BuildContext context, DatabaseService databaseService) async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return const CupertinoAlertDialog(
          content: CupertinoActivityIndicator(),
        );
      },
    );
    await databaseService.updateToken('');
    await widget.notificationService.unsubscribeAndClearTopics();
    await widget.authService.signOut();
    ref.invalidate(userProvider);
    ref.invalidate(followerProvider);
    ref.invalidate(followingProvider);
    ref.invalidate(groupsProvider);
    ref.invalidate(joinedEventsProvider);
    ref.invalidate(createdEventsProvider);
    ref.invalidate(eventProvider);
    if (!context.mounted) return;
    context.go('/login');
  }

  Future<void> deleteAccount(DatabaseService databaseService) async {
    BuildContext context1 = context;
    showCupertinoDialog(
      context: context,
      builder: (BuildContext newBuildContext) {
        context1 = newBuildContext;
        return const CupertinoAlertDialog(
          content: CupertinoActivityIndicator(),
        );
      },
    );

    final bool isSignedInWithGoogle =
        (await databaseService.getUserData(AuthService.uid))
            .isSignedInWithGoogle!;
    if (isSignedInWithGoogle) {
      if (!context1.mounted) return;
      Navigator.of(context1).pop();
      if (!mounted) return;
      showCupertinoDialog(
        context: context,
        builder: (BuildContext newContext) {
          return CupertinoAlertDialog(
            title: const Text('Delete Account'),
            content:
                const Text('Are you sure you want to delete your account?'),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(newContext).pop();
                },
              ),
              CupertinoDialogAction(
                  child: const Text('Yes'),
                  onPressed: () async {
                    Navigator.of(newContext).pop();
                    showCupertinoDialog(
                      context: context,
                      builder: (BuildContext newBuildContext) {
                        context1 = newBuildContext;
                        return const CupertinoAlertDialog(
                          content: CupertinoActivityIndicator(),
                        );
                      },
                    );
                    final bool isReauthenticated =
                        await widget.authService.reauthenticateUserWithGoogle();
                    if (isReauthenticated) {
                      await databaseService.updateToken('');
                      await databaseService.deleteUser();
                      await widget.notificationService
                          .unsubscribeAndClearTopics();
                      ref.invalidate(userProvider);
                      ref.invalidate(followerProvider);
                      ref.invalidate(followingProvider);
                      ref.invalidate(groupsProvider);
                      ref.invalidate(joinedEventsProvider);
                      ref.invalidate(createdEventsProvider);
                      ref.invalidate(eventProvider);
                      await widget.authService.deleteUser();
                      if (!context1.mounted) return;
                      Navigator.of(context1).pop();
                      if (!mounted) return;
                      context.go('/login');
                    } else {
                      if (!context1.mounted) return;
                      Navigator.of(context1).pop();
                      if (!mounted) return;
                      showCupertinoDialog(
                        context: context,
                        builder: (BuildContext newContext) {
                          return CupertinoAlertDialog(
                            title: const Text('Error'),
                            content: const Text(
                                'Failed to reauthenticate with Google account'),
                            actions: <CupertinoDialogAction>[
                              CupertinoDialogAction(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(newContext).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }),
            ],
          );
        },
      );
    } else {
      if (!context1.mounted) return;
      Navigator.of(context1).pop();
      if (!mounted) return;

      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => DeleteAccountPage(
            authService: widget.authService,
          ),
        ),
      );
    }
  }
}
