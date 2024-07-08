import 'dart:typed_data';

import 'package:dima_project/models/group.dart';
import 'package:dima_project/services/storage_service.dart';
import 'package:dima_project/widgets/auth/image_crop_page.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditGroupPage extends StatefulWidget {
  final Group group;

  const EditGroupPage({super.key, required this.group});
  @override
  EditGroupPageState createState() => EditGroupPageState();
}

class EditGroupPageState extends State<EditGroupPage> {
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionController =
      TextEditingController();
  Uint8List? selectedImagePath;
  bool isPrivate = true;
  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDescriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    isPrivate = widget.group.isPublic;
    _fetchProfileImage();
  }

  Future<void> _fetchProfileImage() async {
    final image =
        await StorageService.downloadImageFromStorage(widget.group.imagePath!);
    setState(() {
      selectedImagePath = image;
      //_oldImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return selectedImagePath == null
        ? const Center(child: CupertinoActivityIndicator())
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              backgroundColor: CupertinoTheme.of(context).primaryColor,
              leading: CupertinoButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
              trailing: CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                    ),
                  )),
              middle: const Text('Edit Group',
                  style: TextStyle(color: CupertinoColors.white)),
            ),
            child: SafeArea(
              child: Container(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => ImageCropPage(
                                imageType: 1,
                                imagePath: selectedImagePath,
                                imageInsertPageKey:
                                    (Uint8List selectedImagePath) {
                                  this.selectedImagePath = selectedImagePath;
                                },
                              ),
                            ),
                          )
                        },
                        child: CreateImageWidget.getGroupImageMemory(
                          selectedImagePath!,
                        ),
                      ),
                      const SizedBox(height: 20),
                      CupertinoTextField(
                        placeholder: widget.group.name,
                        controller: _eventNameController,
                        padding: const EdgeInsets.all(16),
                        maxLines: 3,
                        minLines: 1,
                        suffix: CupertinoButton(
                          onPressed: () => _eventNameController.clear(),
                          child: const Icon(CupertinoIcons.clear_circled_solid),
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.extraLightBackgroundGray,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 10),
                      CupertinoTextField(
                        placeholder: widget.group.description,
                        controller: _eventDescriptionController,
                        padding: const EdgeInsets.all(16),
                        maxLines: 3,
                        minLines: 1,
                        suffix: CupertinoButton(
                          onPressed: () => _eventDescriptionController.clear(),
                          child: const Icon(CupertinoIcons.clear_circled_solid),
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.extraLightBackgroundGray,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: CupertinoColors.extraLightBackgroundGray,
                        ),
                        child: Column(
                          children: [
                            const CupertinoListTile(
                              title: Text('Notifications'),
                              leading: Icon(CupertinoIcons.bell),
                              trailing: Icon(CupertinoIcons.chevron_forward),
                            ),
                            const Divider(
                              height: 1,
                              thickness: 0.5,
                            ),
                            CupertinoListTile(
                              leading: const Icon(CupertinoIcons.lock),
                              title: const Text('Private Group'),
                              trailing: CupertinoSwitch(
                                value: isPrivate,
                                onChanged: (bool value) {
                                  setState(() {
                                    isPrivate = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
