import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class ImageInsertPage extends StatefulWidget {
  final String? imagePath;
  final ValueChanged<String> imageInsertPageKey;
  const ImageInsertPage(
      {super.key, this.imagePath, required this.imageInsertPageKey});

  @override
  ImageInsertPageState createState() => ImageInsertPageState();
}

class ImageInsertPageState extends State<ImageInsertPage> {
  final ImagePicker _picker = ImagePicker();
  late String _selectedImagePath = '';
  @override
  void initState() {
    super.initState();
    _selectedImagePath = widget.imagePath ?? '';
  }

  void _pickImage() async {
    final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 500,
        maxWidth: 500,
        imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
        widget.imageInsertPageKey(_selectedImagePath);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _selectedImagePath != ''
            ? Image.network(_selectedImagePath)
            : const Icon(
                CupertinoIcons.photo,
                size: 100,
              ),
        const SizedBox(height: 20),
        CupertinoButton.filled(
          onPressed: _pickImage,
          child: const Text('Pick an Image'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
