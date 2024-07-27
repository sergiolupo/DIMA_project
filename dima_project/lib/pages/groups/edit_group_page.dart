import 'dart:typed_data';

import 'package:dima_project/models/group.dart';
import 'package:dima_project/pages/groups/group_helper.dart';
import 'package:dima_project/pages/groups/group_info_page.dart';
import 'package:dima_project/pages/invite_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/auth/categoriesform_widget.dart';
import 'package:dima_project/widgets/auth/image_crop_page.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EditGroupPage extends StatefulWidget {
  final Group group;
  final bool canNavigate;
  final Function? navigateToPage;
  @override
  const EditGroupPage({
    super.key,
    required this.group,
    required this.canNavigate,
    this.navigateToPage,
  });
  @override
  EditGroupPageState createState() => EditGroupPageState();
}

class EditGroupPageState extends State<EditGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController =
      TextEditingController();
  Uint8List? selectedImagePath;
  String? defaultImage;
  bool isPublic = true;
  bool notify = true;
  List<String> uuids = [];
  List<String> selectedCategories = [];
  int index = 0;
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
      selectedCategories = widget.group.categories!;
      _groupNameController.text = widget.group.name;
      _groupDescriptionController.text = widget.group.description!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        leading: index == 0
            ? CupertinoButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  if (widget.canNavigate) {
                    widget.navigateToPage!(GroupInfoPage(
                        group: widget.group,
                        canNavigate: widget.canNavigate,
                        navigateToPage: widget.navigateToPage));
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: CupertinoTheme.of(context).primaryColor,
                  ),
                ),
              )
            : CupertinoNavigationBarBackButton(
                color: CupertinoTheme.of(context).primaryColor,
                onPressed: () {
                  setState(() {
                    index = 0;
                  });
                },
              ),
        trailing: index == 0
            ? CupertinoButton(
                padding: const EdgeInsets.all(0),
                onPressed: () async {
                  if (index == 0) {
                    if (!GroupHelper.validateFirstPage(
                      context,
                      _groupNameController.text,
                      _groupDescriptionController.text,
                    )) {
                      return;
                    }
                    await updateGroup();
                    if (context.mounted) {
                      if (widget.canNavigate) {
                        widget.navigateToPage!(
                            await DatabaseService.getGroupFromId(
                                widget.group.id));
                      } else {
                        Navigator.of(context).pop(
                            await DatabaseService.getGroupFromId(
                                widget.group.id));
                      }
                    }
                  }
                },
                child: Text(
                  'Done',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: CupertinoTheme.of(context).primaryColor,
                  ),
                ))
            : null,
        middle: Text('Edit Group',
            style: TextStyle(color: CupertinoTheme.of(context).primaryColor)),
      ),
      child: index == 0
          ? buildPage1(context)
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: CategorySelectionForm(
                selectedCategories: selectedCategories,
              ),
            ),
    );
  }

  Widget buildPage1(BuildContext context) {
    return SafeArea(
      child: Container(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => ImageCropPage(
                        defaultImage: defaultImage ?? widget.group.imagePath!,
                        imageType: 1,
                        imagePath: selectedImagePath,
                        imageInsertPageKey: (Uint8List selectedImagePath) {
                          setState(() {
                            this.selectedImagePath = selectedImagePath;
                            defaultImage = '';
                          });
                        },
                      ),
                    ),
                  );
                },
                child: selectedImagePath == null
                    ? CreateImageWidget.getGroupImage(widget.group.imagePath!)
                    : CreateImageWidget.getGroupImageMemory(selectedImagePath!),
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
                  color: CupertinoTheme.of(context).primaryContrastingColor,
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
                  color: CupertinoTheme.of(context).primaryContrastingColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: CupertinoTheme.of(context).primaryContrastingColor,
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
                      color: CupertinoColors.separator,
                    ),
                    CupertinoListTile(
                      title: const Text('Categories'),
                      leading: const Icon(FontAwesomeIcons.tableList),
                      trailing: const Icon(CupertinoIcons.forward),
                      onTap: () {
                        setState(() {
                          index = 1;
                        });
                      },
                    ),
                    Container(
                      height: 1,
                      color: CupertinoColors.separator,
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
                      color: CupertinoColors.separator,
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
    );
  }

  Future<void> updateGroup() async {
    final group = Group(
      id: widget.group.id,
      name: _groupNameController.text,
      description: _groupDescriptionController.text,
      categories: selectedCategories,
      imagePath: widget.group.imagePath!,
      isPublic: isPublic,
      notify: notify,
      members: widget.group.members,
    );
    await DatabaseService.updateGroup(
      group,
      selectedImagePath,
      selectedImagePath == null,
      widget.group.isPublic != isPublic,
      uuids,
    );
  }
}
