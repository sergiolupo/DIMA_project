import 'dart:typed_data';

import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/widgets/create_image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class ImageCropPage extends StatefulWidget {
  final Uint8List? imagePath;
  final ValueChanged<Uint8List> imageInsertPageKey;
  final int imageType; // 0 for user, 1 for group, 2 for event
  final String defaultImage;
  const ImageCropPage({
    super.key,
    this.imagePath,
    required this.imageInsertPageKey,
    required this.imageType,
    required this.defaultImage,
  });

  @override
  ImageCropPageState createState() => ImageCropPageState();
}

class ImageCropPageState extends State<ImageCropPage> {
  final ImagePicker _picker = ImagePicker();
  Uint8List _selectedImagePath = Uint8List(0);
  String defaultImage = '';
  @override
  void initState() {
    super.initState();
    _selectedImagePath = widget.imagePath ?? Uint8List(0);
    defaultImage = widget.defaultImage;
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
        leading: GestureDetector(
          onTap: () {
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
      child: Stack(children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width > Constants.limitWidth
                    ? MediaQuery.of(context).size.height
                    : MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width > Constants.limitWidth
                    ? MediaQuery.of(context).size.height * 0.83
                    : MediaQuery.of(context).size.width,
                child: _selectedImagePath.isNotEmpty
                    ? Image.memory(
                        _selectedImagePath,
                        fit: BoxFit.cover,
                      )
                    : _getDefaultImage(),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 15,
          right: 5,
          child: CupertinoButton(
            onPressed: () {
              setState(() {
                _selectedImagePath = Uint8List(0);
                widget.imageInsertPageKey(_selectedImagePath);
                defaultImage = '';
              });
            },
            child: Icon(
              CupertinoIcons.delete,
              color: CupertinoTheme.of(context).textTheme.textStyle.color,
              size: 20,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _getDefaultImage() {
    switch (widget.imageType) {
      case 1:
        return CreateImageWidget.getGroupImage(defaultImage);
      case 2:
        return CreateImageWidget.getEventImage(defaultImage);
      default:
        return CreateImageWidget.getUserImage(defaultImage, 1);
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
              child: Text(
                'Set New Photo',
                style: TextStyle(
                    color:
                        CupertinoTheme.of(context).textTheme.textStyle.color),
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
                defaultImage = '';
              });
              Navigator.of(context).pop();
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text('Cancel',
              style: TextStyle(
                  color: CupertinoTheme.of(context).textTheme.textStyle.color)),
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
              child: Text(
                'Camera',
                style: TextStyle(
                    color:
                        CupertinoTheme.of(context).textTheme.textStyle.color),
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
              child: Text(
                'Gallery',
                style: TextStyle(
                    color:
                        CupertinoTheme.of(context).textTheme.textStyle.color),
              ),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text('Cancel',
              style: TextStyle(
                  color: CupertinoTheme.of(context).textTheme.textStyle.color)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
