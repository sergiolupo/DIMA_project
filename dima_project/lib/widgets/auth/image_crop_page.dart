import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class ImageCropPage extends StatefulWidget {
  final Uint8List? imagePath;
  final ValueChanged<Uint8List> imageInsertPageKey;
  final int imageType; // 0 for user, 1 for group, 2 for event

  const ImageCropPage({
    super.key,
    this.imagePath,
    required this.imageInsertPageKey,
    required this.imageType,
  });

  @override
  ImageCropPageState createState() => ImageCropPageState();
}

class ImageCropPageState extends State<ImageCropPage> {
  final ImagePicker _picker = ImagePicker();
  late Uint8List _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _selectedImagePath = widget.imagePath ?? Uint8List(0);
  }

  Future<void> _pickImage() async {
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
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 20),
        ClipOval(
          child: Container(
            width: 300,
            height: 300,
            color: CupertinoColors.lightBackgroundGray,
            child: _selectedImagePath.isNotEmpty
                ? Image.memory(
                    _selectedImagePath,
                    fit: BoxFit.cover,
                  )
                : _getDefaultImage(),
          ),
        ),
        CupertinoButton(
          onPressed: _pickImage,
          child: const Row(
            children: [
              Icon(
                CupertinoIcons.pencil,
                color: CupertinoColors.white,
              ),
              Text('Pick Image'),
            ],
          ),
        ),
        CupertinoButton(
          onPressed: () {
            setState(() {
              _selectedImagePath = Uint8List(0);
              widget.imageInsertPageKey(_selectedImagePath);
            });
          },
          child: const Row(
            children: [
              Icon(
                CupertinoIcons.delete,
                color: CupertinoColors.white,
              ),
              Text('Delete Image'),
            ],
          ),
        ),
        CupertinoButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Row(
            children: [
              Icon(
                CupertinoIcons.check_mark,
                color: CupertinoColors.white,
              ),
              Text('Save Image'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _getDefaultImage() {
    switch (widget.imageType) {
      case 1:
        return Image.asset(
          'assets/default_group_image.png',
          fit: BoxFit.cover,
        );
      case 2:
        return Image.asset(
          'assets/default_event_image.png',
          fit: BoxFit.cover,
        );
      default:
        return Image.asset(
          'assets/default_user_image.png',
          fit: BoxFit.cover,
        );
    }
  }
}
