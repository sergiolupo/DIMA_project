import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  static String userLoggedInKey = "LOGGEDINKEY";
  static String uidKey = "UIDKEY";

  static Future<bool> saveUserLoggedInStatus(bool isLoggedIn) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(userLoggedInKey, isLoggedIn);
  }

  static Future<bool> saveUid(String uid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(uidKey, uid);
    return true;
  }

  static Future<bool?> getUserLoggedInStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(userLoggedInKey);
  }

  static Future<String?> getUid() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(uidKey);
  }

  static Future<UserData> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    debugPrint(prefs.getString(uidKey)!);
    String? uid = prefs.getString(uidKey);
    return DatabaseService.getUserData(uid!);
  }

  static void setUserLoggedInStatus(bool bool) {}
}
