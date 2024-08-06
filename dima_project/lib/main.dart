import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/events/event_page.dart';
import 'package:dima_project/pages/chats/groups/group_chat_page.dart';
import 'package:dima_project/pages/login_or_home_page.dart';
import 'package:dima_project/pages/chats/private_chats/private_chat_page.dart';
import 'package:dima_project/pages/register_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/utils/shared_preferences_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SharedPreferencesHelper.saveNotification(message);
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
          return RegisterPage(
            user: user,
            databaseService: DatabaseService(),
          );
        }),
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) {
        int? index = state.extra as int?;
        return HomePage(index: index);
      },
    ),
    GoRoute(
        path: '/privateChat',
        builder: (BuildContext context, GoRouterState state) {
          Map<String, dynamic> map = state.extra as Map<String, dynamic>;
          PrivateChat privateChat = map['privateChat'] as PrivateChat;
          UserData user = map['user'] as UserData;
          return PrivateChatPage(
            privateChat: privateChat,
            user: user,
            canNavigate: false,
          );
        }),
    GoRoute(
        path: '/groupChat',
        builder: (BuildContext context, GoRouterState state) {
          Group group = state.extra as Group;
          return GroupChatPage(
            group: group,
            canNavigate: false,
          );
        }),
    GoRoute(
        path: '/event',
        builder: (BuildContext context, GoRouterState state) {
          String eventId = state.extra as String;
          return EventPage(eventId: eventId);
        }),
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
