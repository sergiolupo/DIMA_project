import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class ImageInsertPage extends StatefulWidget {
  final Uint8List? imagePath;
  final ValueChanged<Uint8List> imageInsertPageKey;
  const ImageInsertPage(
      {super.key, this.imagePath, required this.imageInsertPageKey});

  @override
  ImageInsertPageState createState() => ImageInsertPageState();
}

class ImageInsertPageState extends State<ImageInsertPage> {
  final ImagePicker _picker = ImagePicker();
  Uint8List _selectedImagePath = Uint8List(0);

  @override
  void initState() {
    super.initState();
    _selectedImagePath = widget.imagePath ?? Uint8List(0);
  }

  void _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 500,
      maxWidth: 500,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImagePath = Uint8List.fromList(bytes);
        widget.imageInsertPageKey(_selectedImagePath);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ClipOval(
          child: Container(
            width: 100,
            height: 100,
            color: CupertinoColors.lightBackgroundGray,
            child: _selectedImagePath.isNotEmpty
                ? Image.memory(
                    _selectedImagePath,
                    fit: BoxFit.cover,
                  )
                : const Icon(
                    CupertinoIcons.photo,
                    size: 50,
                    color: CupertinoColors.systemGrey,
                  ),
          ),
        ),
        const SizedBox(height: 20),
        CupertinoButton.filled(
          onPressed: _pickImage,
          child: const Text('Pick an Image'),
        ),
      ],
    );
  }
}
