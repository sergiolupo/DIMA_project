import 'dart:typed_data';

import 'package:dima_project/services/storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dima_project/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<UserData> signInWithEmailandPassword(
      String email, String password) async {
    debugPrint("Trying to Login...");
    UserCredential userCredential = await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);
    debugPrint("Signed In");
    UserData user = await getUserData(userCredential.user!.uid);
    debugPrint("Registered");
    return user;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    debugPrint("Signed Out");
  }

  Future<User?> signInWithGoogle() async {
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

  Future<void> registerUser(UserData user) async {
    // Register the user
    UserCredential userCredential =
        await _firebaseAuth.createUserWithEmailAndPassword(
            email: user.email, password: user.password!);

    debugPrint('User Registered: ${userCredential.user!.uid}');
    await registerUserWithUUID(user, userCredential.user!.uid);
  }

  Future<bool> checkUserExist(String email) async {
    debugPrint('Checking if user exists... $email');
    final QuerySnapshot result = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    if (documents.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> registerUserWithUUID(UserData user, String uuid) async {
    String imageUrl = await StorageService.uploadImageToStorage(
        'profile_images/$uuid.jpg', user.imagePath as Uint8List);

    List<Map<String, dynamic>> serializedList =
        user.categories.map((item) => {'value': item}).toList();
    await _firestore.collection('users').doc(uuid).set({
      'name': user.name,
      'surname': user.surname,
      'username': user.username,
      'email': user.email,
      'imageUrl': imageUrl,
      'selectedCategories': serializedList,
    });
  }

  Future<UserData> getUserData(String uid) async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(uid).get();
    UserData user = UserData(
        name: documentSnapshot['name'],
        surname: documentSnapshot['surname'],
        username: documentSnapshot['username'],
        email: documentSnapshot['email'],
        password: '',
        imagePath: await StorageService.downloadImageFromStorage(
            documentSnapshot['imageUrl']),
        categories: documentSnapshot['selectedCategories']
            .map((categoryMap) => categoryMap['value'].toString())
            .toList()
            .cast<String>());
    return user;
  }

  Future<String> findUUID(String email) async {
    final QuerySnapshot result = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    if (documents.isNotEmpty) {
      return documents[0].id;
    } else {
      return '';
    }
  }

  Future<void> updateUserData(UserData user) async {
    String uuid = await findUUID(user.email);
    String imageUrl = await StorageService.uploadImageToStorage(
        'profile_images/$uuid.jpg', user.imagePath as Uint8List);

    List<Map<String, dynamic>> serializedList =
        user.categories.map((item) => {'value': item}).toList();
    await _firestore.collection('users').doc(uuid).update({
      'name': user.name,
      'surname': user.surname,
      'username': user.username,
      'email': user.email,
      'imageUrl': imageUrl,
      'selectedCategories': serializedList,
    });
  }
}
