import 'dart:convert';

import 'package:dima_project/services/utils/storage_service.dart';
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
      return null; // Return null if googleAuth is null
    }
  }

  Future<void> registerUser(UserData user) async {
    // Register the user
    UserCredential userCredential =
        await _firebaseAuth.createUserWithEmailAndPassword(
            email: user.email, password: user.password);

    debugPrint('User Registered: ${userCredential.user!.uid}');

    String imageUrl = await StorageService.uploadImageToStorage(
        'profile_images/${userCredential.user!.uid}.jpg', user.imagePath);

    // Store additional user information including image URL in Firestore
    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'name': user.name,
      'surname': user.surname,
      'username': user.username,
      'email': user.email,
      'imageUrl': imageUrl,
      'selectedCategories': user.categories.toList(),
    });
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

  Future<void> registerUserGoogle(UserData user, String uuid) async {
    String imageUrl = await StorageService.uploadImageToStorage(
        'profile_images/$uuid.jpg', user.imagePath);

    // Store additional user information including image URL in Firestore
    await _firestore.collection('users').doc(uuid).set({
      'name': user.name,
      'surname': user.surname,
      'username': user.username,
      'email': user.email,
      'imageUrl': imageUrl,
      'selectedCategories': user.categories.toList(),
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
        imagePath: utf8.encode(documentSnapshot['imageUrl']),
        categories: documentSnapshot['selectedCategories']);
    return user;
  }
}
