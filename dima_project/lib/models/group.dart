import 'dart:typed_data';

class Group {
  final String name;
  final String id;
  final String? admin;
  final Uint8List? imagePath;
  final String? description;
  final List<String>? categories;
  Group({
    required this.name,
    required this.id,
    this.admin,
    this.imagePath,
    this.description,
    this.categories,
  });
}
