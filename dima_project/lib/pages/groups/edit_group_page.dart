import 'dart:typed_data';

import 'package:dima_project/models/group.dart';
import 'package:dima_project/pages/invite_page.dart';
import 'package:dima_project/services/storage_service.dart';
import 'package:dima_project/widgets/auth/image_crop_page.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';

class EditGroupPage extends StatefulWidget {
  final Group group;
  final String uuid;
  @override
  const EditGroupPage({super.key, required this.group, required this.uuid});
  @override
  EditGroupPageState createState() => EditGroupPageState();
}

class EditGroupPageState extends State<EditGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController =
      TextEditingController();
  Uint8List? selectedImagePath;
  bool isPublic = true;
  bool notify = true;
  List<String> uuids = [];
  @override
  void dispose() {
    _groupNameController.dispose();
    _groupDescriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isPublic = widget.group.isPublic;
      notify = widget.group.notify;
    });
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
                    //TODO: update name and desription
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
                                  setState(() {
                                    this.selectedImagePath = selectedImagePath;
                                  });
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
                        controller: _groupNameController,
                        padding: const EdgeInsets.all(16),
                        maxLines: 3,
                        minLines: 1,
                        suffix: CupertinoButton(
                          onPressed: () => _groupNameController.clear(),
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
                        controller: _groupDescriptionController,
                        padding: const EdgeInsets.all(16),
                        maxLines: 3,
                        minLines: 1,
                        suffix: CupertinoButton(
                          onPressed: () => _groupDescriptionController.clear(),
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
                            CupertinoListTile(
                              title: const Text('Members'),
                              leading: const Icon(CupertinoIcons.person_3_fill),
                              trailing: const Icon(CupertinoIcons.forward),
                              onTap: () {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                      builder: (context) => InvitePage(
                                          uuid: widget.uuid,
                                          invitePageKey: (String uuid) {
                                            setState(() {
                                              if (uuids.contains(uuid)) {
                                                uuids.remove(uuid);
                                              } else {
                                                uuids.add(uuid);
                                              }
                                            });
                                          },
                                          invitedUsers: uuids,
                                          isGroup: true,
                                          id: widget.group.id)),
                                );
                              },
                            ),
                            Container(
                              height: 1,
                              color: CupertinoColors.opaqueSeparator,
                            ),
                            CupertinoListTile(
                              title: const Text('Notifications'),
                              leading: notify
                                  ? const Icon(CupertinoIcons.bell_fill)
                                  : const Icon(CupertinoIcons.bell_slash_fill),
                              trailing: CupertinoSwitch(
                                value: notify,
                                onChanged: (bool value) {
                                  setState(() {
                                    notify = value;
                                  });
                                },
                              ),
                            ),
                            Container(
                              height: 1,
                              color: CupertinoColors.opaqueSeparator,
                            ),
                            CupertinoListTile(
                              leading: isPublic
                                  ? const Icon(CupertinoIcons.lock_open_fill)
                                  : const Icon(CupertinoIcons.lock_fill),
                              title: const Text('Public Group'),
                              trailing: CupertinoSwitch(
                                value: isPublic,
                                onChanged: (bool value) {
                                  setState(() {
                                    isPublic = value;
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
