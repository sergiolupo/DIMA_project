import 'dart:typed_data';

class Group {
  final String name;
  final String id;
  final String? admin;
  final Uint8List? imagePath;
  Group({
    required this.name,
    required this.id,
    this.admin,
    this.imagePath,
  });
}
