import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  Future<void> saveNotification(RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notificationType', message.data['type']);
    await prefs.setString('notificationData', message.data.toString());
  }

  Future<String?> getNotificationType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('notificationType');
  }

  Future<String?> getNotificationData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('notificationData');
  }

  Future<void> clearNotification() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notificationType');
    await prefs.remove('notificationData');
  }
}
