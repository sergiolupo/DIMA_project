import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;

class StorageService {
  static Future<String> uploadImageToStorage(
      String childName, Uint8List file) async {
    final Reference ref = _storage.ref().child(childName);
    final UploadTask uploadTask = ref.putData(file);
    final TaskSnapshot taskSnapshot = await uploadTask;
    final String url = await taskSnapshot.ref.getDownloadURL();
    return url;
  }

  static Future<Uint8List> downloadImageFromStorage(String url) async {
    if (url == '') {
      return Uint8List(0);
    }
    final Reference ref = _storage.refFromURL(url);
    final Uint8List? data = await ref.getData();
    if (data == null) {
      throw Exception('Failed to download image');
    }
    return data;
  }

  static Future<void> deleteImageFromStorage(String url) {
    final Reference ref = _storage.refFromURL(url);
    return ref.delete();
  }
}
