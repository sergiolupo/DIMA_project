import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;

class StorageService {
  static Future<String> uploadImageToStorage(
      String chilName, Uint8List file) async {
    final Reference ref = _storage.ref().child(chilName);
    final UploadTask uploadTask = ref.putData(file);
    final TaskSnapshot taskSnapshot = await uploadTask;
    final String url = await taskSnapshot.ref.getDownloadURL();
    return url;
  }

  static Future<Uint8List?> downloadImageFromStorage(String url) async {
    final ref = _storage.refFromURL(url);
    final Uint8List? bytes = await ref.getData();
    return bytes;
  }
}
