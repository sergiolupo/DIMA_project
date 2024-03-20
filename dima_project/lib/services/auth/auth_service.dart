import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential> signInWithEmailandPassword(
      String email, String password) async {
    try {
      debugPrint("Trying to Login...");
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      debugPrint("Signed In");
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e);
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    debugPrint("Signed Out");
  }

  Future<UserCredential> signUpWithEmailandPassword(
      String email, String password) async {
    try {
      debugPrint("Trying to Register...");
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      debugPrint("Registered");
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e);
    }
  }
}
