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
    const MyApp(),
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
        Group? group = data['group'] as Group?;
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
        return GroupInfo(group: group, uuid: uuid);
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
      theme: const CupertinoThemeData(
        primaryColor: Constants.primaryColor,
        primaryContrastingColor: Constants.primaryColorDark,
        scaffoldBackgroundColor: CupertinoColors.white,
      ),
      routerConfig: _router,
      title: "AGORAPP",
    );
  }
}
