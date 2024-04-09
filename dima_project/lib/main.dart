import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/chat_page.dart';
import 'package:dima_project/pages/groups/group_info.dart';
import 'package:dima_project/pages/groups/group_page.dart';
import 'package:dima_project/pages/login_or_home_page.dart';
import 'package:dima_project/pages/register_page.dart';
import 'package:dima_project/pages/search_page.dart';
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
        Group group = data['group'] as Group;
        String username = data['username'] as String;
        return ChatPage(group: group, username: username);
      },
    ),
    GoRoute(
      path: '/groupinfo',
      builder: (BuildContext context, GoRouterState state) {
        Map<String, dynamic> data = state.extra as Map<String, dynamic>;
        Group group = data['group'] as Group;
        String username = data['username'] as String;
        return GroupInfo(group: group, username: username);
      },
    ),
    GoRoute(
      path: '/search',
      builder: (BuildContext context, GoRouterState state) {
        UserData user = state.extra as UserData;
        return SearchPage(
          user: user,
        );
      },
    ),
    GoRoute(
      path: '/groups',
      builder: (BuildContext context, GoRouterState state) {
        UserData user = state.extra as UserData;

        return GroupPage(
          user: user,
        );
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp.router(
      theme: CupertinoThemeData(
        primaryColor: Constants().primaryColor,
        scaffoldBackgroundColor: CupertinoColors.white,
      ),
      routerConfig: _router,
      title: "AGORAPP",
    );
  }
}
