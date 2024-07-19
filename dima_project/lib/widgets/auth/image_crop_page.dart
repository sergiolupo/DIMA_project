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

  Future<void> _pickImage(bool isCamera) async {
    final pickedFile = await _picker.pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
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
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        trailing: CupertinoButton(
          padding: const EdgeInsets.all(0),
          onPressed: () => showSheet(),
          child: Text(
            'Edit',
            style: TextStyle(
                color: CupertinoTheme.of(context).textTheme.textStyle.color,
                fontWeight: FontWeight.bold),
          ),
        ),
        leading: CupertinoButton(
          padding: const EdgeInsets.all(0),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Row(
            children: [
              Icon(
                CupertinoIcons.back,
                color: CupertinoTheme.of(context).textTheme.textStyle.color,
                size: 30.0,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Text(
                  'Back',
                  style: TextStyle(
                      color:
                          CupertinoTheme.of(context).textTheme.textStyle.color),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                height: 500,
                color: CupertinoColors.lightBackgroundGray,
                child: _selectedImagePath.isNotEmpty
                    ? Image.memory(
                        _selectedImagePath,
                        fit: BoxFit.cover,
                      )
                    : _getDefaultImage(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton(
                  onPressed: () {
                    setState(() {
                      _selectedImagePath = Uint8List(0);
                      widget.imageInsertPageKey(_selectedImagePath);
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.delete,
                        color: CupertinoTheme.of(context)
                            .textTheme
                            .textStyle
                            .color,
                        size: 30,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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

  void showSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              showCameraOrGallery();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Set New Photo',
                style: TextStyle(color: CupertinoColors.black),
              ),
            ),
          ),
          CupertinoActionSheetAction(
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Remove Photo',
                  style: TextStyle(color: CupertinoColors.systemRed),
                )),
            onPressed: () {
              setState(() {
                _selectedImagePath = Uint8List(0);
                widget.imageInsertPageKey(_selectedImagePath);
              });
              Navigator.of(context).pop();
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel',
              style: TextStyle(color: CupertinoColors.black)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void showCameraOrGallery() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              _pickImage(true);
              Navigator.of(context).pop();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Camera',
                style: TextStyle(color: CupertinoColors.black),
              ),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              _pickImage(false);
              Navigator.of(context).pop();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Gallery',
                style: TextStyle(color: CupertinoColors.black),
              ),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel',
              style: TextStyle(color: CupertinoColors.black)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
