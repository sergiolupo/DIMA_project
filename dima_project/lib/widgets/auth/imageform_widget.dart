import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class ImageInsertForm extends StatefulWidget {
  final Uint8List? imagePath;
  final ValueChanged<Uint8List> imageInsertPageKey;
  final int imageType; // 0 for user, 1 for group, 2 for event
  const ImageInsertForm({
    super.key,
    this.imagePath,
    required this.imageInsertPageKey,
    required this.imageType,
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
                width: 100,
                height: 100,
                color: CupertinoColors.lightBackgroundGray,
                child: _selectedImagePath.isNotEmpty
                    ? Image.memory(
                        _selectedImagePath,
                        fit: BoxFit.cover,
                      )
                    : widget.imageType == 1
                        ? Image.asset(
                            'assets/default_group_image.png',
                            fit: BoxFit.cover,
                          )
                        : widget.imageType == 2
                            ? Image.asset(
                                'assets/default_event_image.png',
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/default_user_image.png',
                                fit: BoxFit.cover,
                              ),
              ),
            ),
            Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 4,
                      color: CupertinoColors.white,
                    ),
                    color: CupertinoColors.systemPink,
                  ),
                  child: GestureDetector(
                    onTap: () => {
                      setState(() {
                        _selectedImagePath = Uint8List(0);
                        widget.imageInsertPageKey(_selectedImagePath);
                      })
                    },
                    child: const Icon(
                      CupertinoIcons.delete,
                      color: CupertinoColors.white,
                    ),
                  ),
                )),
            Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 4,
                      color: CupertinoColors.white,
                    ),
                    color: CupertinoColors.systemPink,
                  ),
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: const Icon(
                      CupertinoIcons.pencil,
                      color: CupertinoColors.white,
                    ),
                  ),
                ))
          ],
        ),
      ],
    );
  }
}
