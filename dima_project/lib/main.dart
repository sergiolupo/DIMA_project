import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/groups/create_group_page.dart';
import 'package:dima_project/pages/groups/group_chat_page.dart';
import 'package:dima_project/pages/groups/group_info_page.dart';
import 'package:dima_project/pages/groups/list_chat_page.dart';
import 'package:dima_project/pages/login_or_home_page.dart';
import 'package:dima_project/pages/register_page.dart';
import 'package:dima_project/pages/search_page.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/widgets/home/user_profile/show_followers_page.dart';
import 'package:dima_project/widgets/home/user_profile/show_groups_page.dart';
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
        UserData user = data['user'] as UserData;
        return GroupChatPage(
          group: group,
          user: user,
        );
      },
    ),
    GoRoute(
      path: '/groupinfo',
      builder: (BuildContext context, GoRouterState state) {
        Map<String, dynamic> data = state.extra as Map<String, dynamic>;
        Group group = data['group'] as Group;
        UserData user = data['user'] as UserData;
        return GroupInfo(group: group, user: user);
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
        return ListChatPage(
          user: user,
        );
      },
    ),
    GoRoute(
      path: '/creategroup',
      builder: (BuildContext context, GoRouterState state) {
        UserData user = state.extra as UserData;
        return CreateGroupPage(user: user);
      },
    ),
    GoRoute(
      path: '/showgroups',
      builder: (BuildContext context, GoRouterState state) {
        Map<String, dynamic> data = state.extra as Map<String, dynamic>;
        UserData user = data['user'] as UserData;
        UserData? visitor = data['visitor'] as UserData?;
        return ShowGroupsPage(user: user, visitor: visitor);
      },
    ),
    GoRoute(
      path: '/showfollowers',
      builder: (BuildContext context, GoRouterState state) {
        Map<String, dynamic> data = state.extra as Map<String, dynamic>;
        UserData user = data['user'] as UserData;
        UserData? visitor = data['visitor'] as UserData?;
        bool followers = data['followers'] as bool;
        return ShowFollowers(
            user: user, visitor: visitor, followers: followers);
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
