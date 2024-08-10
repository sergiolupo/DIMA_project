import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/notification_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/shared_preferences_helper.dart';
import 'package:dima_project/widgets/auth/login_form_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DeleteAccountPage extends ConsumerStatefulWidget {
  final AuthService authService;
  final SharedPreferencesHelper sharedPreferencesHelper;
  const DeleteAccountPage({
    super.key,
    required this.authService,
    required this.sharedPreferencesHelper,
  });
  @override
  DeleteAccountPageState createState() => DeleteAccountPageState();
}

class DeleteAccountPageState extends ConsumerState<DeleteAccountPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final DatabaseService databaseService = ref.watch(databaseServiceProvider);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        middle: Text(
          'Confirm Account Deletion',
          style: TextStyle(
            color: CupertinoTheme.of(context).primaryColor,
            fontSize: 18,
          ),
        ),
        leading: CupertinoButton(
          onPressed: () => Navigator.of(context).pop(),
          padding: const EdgeInsets.only(left: 10),
          child: Icon(
            CupertinoIcons.back,
            color: CupertinoTheme.of(context).primaryColor,
          ),
        ),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter your email and password to delete your account',
                style: TextStyle(
                  color: CupertinoTheme.of(context).primaryColor,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              EmailInputField(_emailController),
              PasswordInputField(_passwordController),
              const SizedBox(height: 10),
              CupertinoButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }

                  if (await checkReauthentication()) {
                    BuildContext context1 = context;
                    if (!context.mounted) return;
                    showCupertinoDialog(
                      context: context,
                      builder: (BuildContext newBuildContext) {
                        context1 = newBuildContext;
                        return const CupertinoAlertDialog(
                          content: CupertinoActivityIndicator(),
                        );
                      },
                    );
                    await databaseService.updateToken('');
                    await widget.sharedPreferencesHelper.clearNotification();
                    await databaseService.deleteUser();
                    await NotificationService(databaseService: databaseService)
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
                    if (!context.mounted) return;
                    context.go('/login');
                  } else {
                    if (!context.mounted) return;
                    showCupertinoDialog(
                      context: context,
                      builder: (BuildContext newContext) {
                        return CupertinoAlertDialog(
                          title: const Text('Error'),
                          content: const Text(
                              'The email or password you entered is incorrect'),
                          actions: <CupertinoDialogAction>[
                            CupertinoDialogAction(
                              child: const Text('OK'),
                              onPressed: () {
                                if (!context.mounted) return;
                                setState(() {
                                  _emailController.clear();
                                  _passwordController.clear();
                                });

                                Navigator.of(newContext).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text(
                  'Delete Account',
                  style: TextStyle(
                    color: CupertinoTheme.of(context).primaryColor,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> checkReauthentication() {
    return widget.authService
        .reauthenticateUser(_emailController.text, _passwordController.text);
  }
}
