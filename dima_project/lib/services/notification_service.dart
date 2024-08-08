import 'dart:convert';

import 'package:app_settings/app_settings.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/events/event_page.dart';
import 'package:dima_project/pages/chats/groups/group_chat_page.dart';
import 'package:dima_project/pages/chats/private_chats/private_chat_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/shared_preferences_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:dima_project/models/message.dart' as chat_message;

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late final DatabaseService databaseService;

  NotificationService({required this.databaseService});

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
    await databaseService.updateToken(token!);

    messaging.onTokenRefresh.listen((event) async {
      if (FirebaseAuth.instance.currentUser == null) {
        return;
      }
      await databaseService.updateToken(event);
      ref.invalidate(userProvider(AuthService.uid));
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
    String? notificationType =
        await SharedPreferencesHelper().getNotificationType();
    String? notificationData =
        await SharedPreferencesHelper().getNotificationData();

    if (notificationType != null && notificationData != null) {
      debugPrint('notificationType');

      Map<String, dynamic> data =
          Map<String, dynamic>.from(json.decode(notificationData));
      if (!context.mounted) return;
      handleMessage(context, RemoteMessage(data: data));

      await SharedPreferencesHelper().clearNotification();
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
    if (message.data['type'] == 'private_chat') {
      Map<String, dynamic> map = {
        'privateChat': PrivateChat.fromMap(
            Map<String, dynamic>.from(message.data['private_chat'])),
        'user':
            UserData.fromMap(Map<String, dynamic>.from(message.data['user'])),
      };
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => PrivateChatPage(
                    privateChat: map['privateChat'],
                    user: map['user'],
                    canNavigate: false,
                  )));
    }
    if (message.data['type'] == 'group_chat') {
      Group group =
          Group.fromMap(Map<String, dynamic>.from(message.data['group']));
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => GroupChatPage(
                    group: group,
                    canNavigate: false,
                  )));
    }
    if (message.data['type'] == 'event') {
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => EventPage(
                    eventId: message.data['event_id'],
                  )));
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

  Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "dima-58cb8",
      "private_key_id": "c756bb63326247d468018e5cb6dc12d7ca04781f",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCPq56XmuUK7XJ+\nO2dpRw1J15P1oUJDNAPoiypeNt5QeW+YsfbOom/w0WY2Bz3bTMrpMo4qW+Pg+SdZ\n2HDkOxpICXP5vt5TygZqGKNofdDzz1RqIfkTM+5r3C1q3Aw3LwstMVzIJ86XYIGx\nQ0qhgunITb+H81Q1gpQSsc61seAmsAWk7ucNtHFOAL5Q0L2GlEAGWmFODqDY/nJl\nwg7H9XHhBnU1u6fFitT5c08o9/IwSM75+tYBzrjrA7rMEBatLVlsKrTm/O3PzrwS\nS0ysMEfyBCMlM7GTcZFEzVr78x0EVisQb2rnVjRmtO+Xy1YYn7r4U3w1ysAQEvSs\nBQTeqgHzAgMBAAECggEAM0ceyJ+JRlgveCx9oU6xyHxAG/hdbR0AlBwvmAbfXDur\ngAVswJ2rdHlYkMoO4tnKxma75RR9BgwHZoLg8CTEIZf2I9pjAebmWTHICQB29r42\nM9dCTf9IBolEUJKPbZbF13B53BqRGuhgAcOxvGm8RTiytrQ7hwm/DdkWnTUKeuPp\niUqJPuTlmuZofc9tUkta0X7XdhRuzosrZynbjtL0Z2lGz6YNYfQ4dAovieu3Grjk\nH9UD/osKS2fBLtgpleF2QAwMZeoXJJxBpVK5313mLXHxagGxg3W0JMuMA2vVAmjw\n0gsOBfbmmUbFOhgbksZeVA40uFhuSHdKuIpLsNI3eQKBgQDAbU9dIjp5wuZU5ihX\nQt7G6X1nLqsRLPl1wyu5O5RdlDiVg2u4WcKaz8OUzVYrtHvGdNtu8+/UWb/yZmzg\n0oQ4vVu99kx4T0AmS93+kIo73Nctt+u5EfquRE3gR8ckXLW1JU0kzAWG1jszoxmu\nsWeInG87i9xuMGMy9ex/MHZNnQKBgQC/IqzDvscskjS3wQ27Z2QfTgdxE/QEcBPO\nXpvdN+emHnKB+DzFcwKAZqlaHKTtUga5CLSWWYSSFfFl5Btll9KjZZ6/7yQKvjaW\n5WJyNmYxFPdjMxa0Ug/Zh5OvSrlvA/93XQLzR4gBsR5ao8+zK3EjolWxjI34NSUZ\nrFKAw+JAzwKBgHoaYsvkVlrBM8sXqO2GPzrVGoAI+wARG9KAIBSQG9stnKIzHH2E\nZ5o40BByI4XkJs6NhFhpbfu/X69/EwOuUbx3W+m0il2lXD1w0tMgALdvsRMPrAJp\nyDogmZIBufn24k6p9sOsuq0O784aZseVRu9G5MZSP3OkPK4vovwqUkd5AoGBAIzn\nCgePh5MjATwJVI83zAaL5k6FEBmJagBznGF7igjbXzzS/DHu9AQmKmhkv2y4UH5t\nnXtM6L8s7/VWMKA3SS/thRcnOyG0UdfxqB5cXf+G3kzB59XsvQR2vve1lXfysYyU\nA83GiMv+f0sAgegqeVB0psmpvSsiOoRvla6ZORzfAoGBAI+jxQ/9b1u3vrQW7K9M\ne0t+Caf4uPT+bZZhBu0XjuOhUJvcmzgB5fzeXVsM8YYmq1BohOA+Os5BZubXmUTf\noFHkaEi8xNBU4FtE0FFYOOjZBdUGT6+UE8o9XqzoCrBMzYoLn2M03S0YpRUOSjj6\nAFkYsN7hd5wTVtsyQT7tSUqJ\n-----END PRIVATE KEY-----\n",
      "client_email": "flutter-notification@dima-58cb8.iam.gserviceaccount.com",
      "client_id": "114105969686402355633",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/flutter-notification%40dima-58cb8.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };
    final List<String> scopes = [
      'https://www.googleapis.com/auth/firebase.messaging',
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
    ];
    http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);
    client.close();
    return credentials.accessToken.data;
  }

  Future<void> sendNotificationForPrivateChat(
      PrivateChat privateChat, chat_message.Message chatMessage) async {
    String deviceToken =
        await databaseService.getDeviceTokenPrivateChat(privateChat);

    if (deviceToken == '') return;
    final String serverAccessTokenKey = await getAccessToken();
    const endpoint =
        'https://fcm.googleapis.com/v1/projects/dima-58cb8/messages:send';

    debugPrint(deviceToken);
    Map<String, dynamic> message = {
      "message": {
        "notification": {
          "title": chatMessage.sender,
          "body": chatMessage.content,
        },
        "data": {
          "type": "private_chat",
          "private_chat": privateChat.id,
        },
        "token": deviceToken,
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpoint),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $serverAccessTokenKey',
      },
      body: jsonEncode(message),
    );
    debugPrint(response.body);
    if (response.statusCode == 200) {
      debugPrint('Notification sent');
    } else {
      debugPrint('Notification not sent');
    }
  }
}
