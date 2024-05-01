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
}
