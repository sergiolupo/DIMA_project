import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';

class AuthService {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final String uid = _firebaseAuth.currentUser!.uid;

  static Future<UserData> signInWithEmailandPassword(
      String email, String password) async {
    debugPrint("Trying to Login...");
    UserCredential userCredential = await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);
    debugPrint("Signed In");
    UserData user = await DatabaseService.getUserData(userCredential.user!.uid);
    debugPrint("Registered");
    return user;
  }

  static Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint("Error Signing Out: $e");
    }
    debugPrint("Signed Out");
  }

  static Future<User?> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    if (googleAuth != null) {
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      return userCredential.user;
    } else {
      return null;
    }
  }

  static Future<void> registerUser(UserData user, Uint8List imagePath) async {
    // Register the user
    UserCredential userCredential =
        await _firebaseAuth.createUserWithEmailAndPassword(
            email: user.email, password: user.password!);

    debugPrint('User Registered: ${userCredential.user!.uid}');
    await DatabaseService.registerUserWithUUID(
        user, userCredential.user!.uid, imagePath);
  }

  static Future<void> deleteUser() {
    return _firebaseAuth.currentUser!.delete();
  }
}
