import 'package:dima_project/models/group.dart';
import 'package:dima_project/pages/groups/create_group_page.dart';
import 'package:dima_project/pages/groups/group_chat_page.dart';
import 'package:dima_project/pages/groups/group_info_page.dart';
import 'package:dima_project/pages/groups/list_chat_page.dart';
import 'package:dima_project/pages/login_or_home_page.dart';
import 'package:dima_project/pages/register_page.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginOrHomePage();
        }),
    GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        }),
    GoRoute(
        path: '/register',
        builder: (BuildContext context, GoRouterState state) {
          User? user = state.extra as User?;
          return RegisterPage(user: user);
        }),
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) {
        int? index = state.extra as int?;
        return HomePage(index: index);
      },
    ),
    GoRoute(
      path: '/chat',
      builder: (BuildContext context, GoRouterState state) {
        Map<String, dynamic> data = state.extra as Map<String, dynamic>;
        Group? group = data['group'] as Group;
        String uuid = data['uuid'] as String;
        return GroupChatPage(
          group: group,
          uuid: uuid,
        );
      },
    ),
    GoRoute(
      path: '/groupinfo',
      builder: (BuildContext context, GoRouterState state) {
        Map<String, dynamic> data = state.extra as Map<String, dynamic>;
        Group group = data['group'] as Group;
        String uuid = data['uuid'] as String;
        return GroupInfoPage(group: group, uuid: uuid);
      },
    ),
    GoRoute(
      path: '/groups',
      builder: (BuildContext context, GoRouterState state) {
        String uuid = state.extra as String;
        return ListChatPage(
          uuid: uuid,
        );
      },
    ),
    GoRoute(
      path: '/creategroup',
      builder: (BuildContext context, GoRouterState state) {
        String uuid = state.extra as String;
        return CreateGroupPage(uuid: uuid);
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp.router(
      theme: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? const CupertinoThemeData(
              brightness: Brightness.dark,
              primaryColor: Constants.primaryColorDark,
              primaryContrastingColor: Constants.primaryContrastingColorDark,
              scaffoldBackgroundColor: Constants.scaffoldBackgroundColorDark,
              barBackgroundColor: Constants.barBackgroundColorDark,
              textTheme: CupertinoTextThemeData(
                textStyle: TextStyle(
                  color: Constants.textColorDark,
                ),
              ),
            )
          : const CupertinoThemeData(
              brightness: Brightness.light,
              primaryColor: Constants.primaryColor,
              primaryContrastingColor: Constants.primaryContrastingColor,
              scaffoldBackgroundColor: Constants.scaffoldBackgroundColor,
              barBackgroundColor: Constants.barBackgroundColor,
              textTheme: CupertinoTextThemeData(
                textStyle: TextStyle(
                  color: Constants.textColor,
                ),
              ),
            ),
      routerConfig: _router,
      title: "AGORAPP",
    );
  }
}
