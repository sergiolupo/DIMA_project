import 'dart:typed_data';

import 'package:dima_project/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class ImageInsertForm extends StatefulWidget {
  final Uint8List? imagePath;
  final ValueChanged<Uint8List> imageInsertPageKey;
  final bool? imageForGroup;
  const ImageInsertForm({
    super.key,
    this.imagePath,
    required this.imageInsertPageKey,
    this.imageForGroup,
  });

  @override
  ImageInsertFormState createState() => ImageInsertFormState();
}

class ImageInsertFormState extends State<ImageInsertForm> {
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
        Stack(
          children: [
            ClipOval(
              child: Container(
                width: 70,
                height: 70,
                color: CupertinoColors.lightBackgroundGray,
                child: _selectedImagePath.isNotEmpty
                    ? Image.memory(
                        _selectedImagePath,
                        fit: BoxFit.cover,
                      )
                    : /*const Icon(
                        CupertinoIcons.photo_camera_solid,
                        size: 50,
                        color: CupertinoColors.systemGrey,
                      ),*/
                    CupertinoButton(
                        onPressed: _pickImage,
                        child: Icon(CupertinoIcons.photo_camera_solid,
                            color: CupertinoTheme.of(context).primaryColor,
                            size: 30),
                      ),
              ),
            ),
            /*Positioned(
              bottom: 0,
              right: 0,
              child: CupertinoButton(
                onPressed: _pickImage,
                child: Icon(
                  CupertinoIcons.photo_camera,
                  color: CupertinoTheme.of(context).primaryColor,
                ),
              ),
            ),*/
          ],
        ),
      ],
    );
  }
}
