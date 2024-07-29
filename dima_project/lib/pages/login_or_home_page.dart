import 'package:dima_project/pages/home_page.dart';
import 'package:dima_project/pages/login_page.dart';
import 'package:dima_project/services/notification_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class LoginOrHomePage extends StatefulWidget {
  const LoginOrHomePage({super.key});

  @override
  LoginOrHomePageState createState() => LoginOrHomePageState();
}

class LoginOrHomePageState extends State<LoginOrHomePage> {
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    super.initState();

    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit();
    notificationServices.isTokenRefresh();
    notificationServices.getDeviceToken().then((value) {
      debugPrint('device token');
      debugPrint(value);
    });
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("ERROR DURING AUTHENTICATION");
        }
        if (snapshot.hasData && FirebaseAuth.instance.currentUser != null) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
