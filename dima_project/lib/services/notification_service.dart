import 'package:app_settings/app_settings.dart';
import 'package:dima_project/pages/login_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('user granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('user provisional permission');
    } else {
      AppSettings.openAppSettings(type: AppSettingsType.notification);
    }
  }

  void initLocalNotifications(
      BuildContext context, RemoteMessage message) async {
    var initializationSettings = const InitializationSettings(
      iOS: DarwinInitializationSettings(),
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) {
      handleMessage(context, message);
    });
  }

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint(message.notification!.title.toString());
      debugPrint(message.notification!.body.toString());
      debugPrint(message.data.toString());
      forgroundMessage();
      initLocalNotifications(context, message);
    });
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    debugPrint(token);
    return token!;
  }

  void setupToken(WidgetRef ref) async {
    String? token = await FirebaseMessaging.instance.getToken();
    await DatabaseService.updateToken(token!);

    messaging.onTokenRefresh.listen((event) {
      if (FirebaseAuth.instance.currentUser == null) {
        return;
      }
      ref.invalidate(userProvider(AuthService.uid));
      DatabaseService.updateToken(event);
    });
  }

  Future<void> setUpInteractMessage(BuildContext context) async {
    //when app is terminated
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('initialMessage');
      if (!context.mounted) return;
      handleMessage(context, initialMessage);
    }
    //when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('onMessageOpenedApp');
      handleMessage(
        context,
        message,
      );
    });
  }

  void handleMessage(BuildContext context, RemoteMessage message) {
    //handle notification function
    if (message.data['type'] == 'message') {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => const LoginPage()));
    }
  }

  Future forgroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}
