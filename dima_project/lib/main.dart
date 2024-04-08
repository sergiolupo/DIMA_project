import 'package:dima_project/pages/chat_page.dart';
import 'package:dima_project/pages/group_info.dart';
import 'package:dima_project/pages/login_home_page.dart';
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
          return const LoginHomePage();
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
        return const HomePage();
      },
    ),
    GoRoute(
      path: '/chat',
      builder: (BuildContext context, GoRouterState state) {
        String groupId =
            (state.extra as Map<String, dynamic>)['groupId'] as String;
        String groupName =
            (state.extra as Map<String, dynamic>)['groupName'] as String;
        String username =
            (state.extra as Map<String, dynamic>)['username'] as String;
        return ChatPage(
            groupId: groupId, groupName: groupName, username: username);
      },
    ),
    GoRoute(
      path: '/groupinfo',
      builder: (BuildContext context, GoRouterState state) {
        String groupId =
            (state.extra as Map<String, dynamic>)['groupId'] as String;
        String groupName =
            (state.extra as Map<String, dynamic>)['groupName'] as String;
        String admin = (state.extra as Map<String, dynamic>)['admin'] as String;
        return GroupInfo(
            groupId: groupId, groupName: groupName, adminName: admin);
      },
    ),
    GoRoute(
      path: '/search',
      builder: (BuildContext context, GoRouterState state) {
        return const SearchPage();
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
