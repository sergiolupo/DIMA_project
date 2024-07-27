import 'dart:typed_data';

import 'package:dima_project/models/group.dart';
import 'package:dima_project/pages/groups/group_helper.dart';
import 'package:dima_project/pages/invite_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/auth/categoriesform_widget.dart';
import 'package:dima_project/widgets/auth/image_crop_page.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CreateGroupPage extends ConsumerStatefulWidget {
  const CreateGroupPage({
    super.key,
  });

  @override
  CreateGroupPageState createState() => CreateGroupPageState();
}

class CreateGroupPageState extends ConsumerState<CreateGroupPage> {
  int _currentPage = 1;
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController =
      TextEditingController();
  Uint8List selectedImagePath = Uint8List(0);
  final imageInsertPageKey = GlobalKey<ImageCropPageState>();
  List<String> selectedCategories = [];
  bool isPublic = true;
  bool notify = true;

  List<String> uuids = [];

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (_currentPage) {
      case 1:
        page = pageOneCreateGroup();
        break;
      case 2:
        page = pageTwoCreateGroup();
        break;
      default:
        page = pageOneCreateGroup();
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        trailing: _currentPage == 1
            ? CupertinoButton(
                padding: const EdgeInsets.all(3),
                onPressed: () => {managePage()},
                child: Text(
                  'Create',
                  style: TextStyle(
                      color: CupertinoTheme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
              )
            : null,
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        leading: CupertinoButton(
          onPressed: () {
            if (_currentPage == 1) {
              Navigator.of(context).pop();
            } else {
              setState(() {
                _currentPage = 1;
              });
            }
          },
          child: Icon(CupertinoIcons.back,
              color: CupertinoTheme.of(context).primaryColor),
        ),
        middle: Text(
          'Create Group',
          style: TextStyle(color: CupertinoTheme.of(context).primaryColor),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              page,
            ],
          ),
        ),
      ),
    );
  }

  void createGroup(Group group, Uint8List imagePath) async {
    await DatabaseService.createGroup(group, imagePath, uuids);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Widget pageOneCreateGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              CupertinoTextField(
                controller: _groupNameController,
                minLines: 1,
                maxLines: 3,
                textInputAction: TextInputAction.next,
                padding: const EdgeInsets.all(16),
                placeholder: 'Group Name',
                decoration: BoxDecoration(
                  color: CupertinoTheme.of(context).primaryContrastingColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                prefix: GestureDetector(
                  onTap: () => {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => ImageCropPage(
                          defaultImage: '',
                          imageType: 1,
                          imagePath: selectedImagePath,
                          imageInsertPageKey: (Uint8List selectedImagePath) {
                            setState(() {
                              this.selectedImagePath = selectedImagePath;
                            });
                          },
                        ),
                      ),
                    )
                  },
                  child: CreateImageWidget.getGroupImageMemory(
                    selectedImagePath,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                minLines: 1,
                controller: _groupDescriptionController,
                placeholder: 'Group Description',
                maxLines: 5,
                maxLength: 200,
                decoration: BoxDecoration(
                  color: CupertinoTheme.of(context).primaryContrastingColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.all(16.0),
                suffix: CupertinoButton(
                  onPressed: () => _groupDescriptionController.clear(),
                  child: const Icon(CupertinoIcons.clear_circled_solid),
                ),
              ),
            ],
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
                            id: null,
                            isGroup: true,
                            invitedUsers: uuids)),
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
                    _currentPage = 2;
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
                trailing: Transform.scale(
                  scale: 0.75,
                  child: CupertinoSwitch(
                    value: notify,
                    onChanged: (bool value) {
                      setState(() {
                        notify = value;
                      });
                    },
                  ),
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
                trailing: Transform.scale(
                  scale: 0.75,
                  child: CupertinoSwitch(
                    value: isPublic,
                    onChanged: (bool value) {
                      setState(() {
                        isPublic = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget pageTwoCreateGroup() {
    return SafeArea(
        child: CategorySelectionForm(
      selectedCategories: selectedCategories,
    ));
  }

  void managePage() {
    if (!GroupHelper.validateNameAndDescription(
        context, _groupNameController.text, _groupDescriptionController.text)) {
      return;
    }
    createGroup(
      Group(
          name: _groupNameController.text,
          id: '',
          admin: FirebaseAuth.instance.currentUser!.uid,
          description: _groupDescriptionController.text,
          categories: selectedCategories,
          isPublic: isPublic,
          notify: notify),
      selectedImagePath,
    );
    ref.invalidate(groupsProvider(FirebaseAuth.instance.currentUser!.uid));
  }
}
