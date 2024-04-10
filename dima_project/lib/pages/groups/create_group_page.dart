import 'dart:typed_data';

import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/auth/categoriesform_widget.dart';
import 'package:dima_project/widgets/auth/imageform_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class CreateGroupPage extends StatefulWidget {
  final UserData user;

  const CreateGroupPage({super.key, required this.user});

  @override
  CreateGroupPageState createState() => CreateGroupPageState();
}

class CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController =
      TextEditingController();
  Uint8List selectedImagePath = Uint8List(0);
  final imageInsertPageKey = GlobalKey<ImageInsertFormState>();
  List<String> selectedCategories = [];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          onPressed: () {
            context.go(
              '/groups',
              extra: widget.user,
            );
          },
          child: const Icon(CupertinoIcons.back, color: CupertinoColors.white),
        ),
        middle: Text(
          'Create Group',
          style: TextStyle(color: CupertinoTheme.of(context).primaryColor),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ImageInsertForm(
                  imageForGroup: true,
                  imagePath: selectedImagePath,
                  imageInsertPageKey: (Uint8List selectedImagePath) {
                    this.selectedImagePath = selectedImagePath;
                  },
                ),
                const SizedBox(height: 20),
                CupertinoTextFormFieldRow(
                  controller: _groupNameController,
                  placeholder: 'Group Name',
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: CupertinoColors.systemGrey4,
                      width: 2.0,
                    ),
                  ),
                  padding: const EdgeInsets.all(12.0),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a group name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CupertinoTextFormFieldRow(
                  controller: _groupDescriptionController,
                  placeholder: 'Group Description',
                  maxLines: 5,
                  maxLength: 200,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: CupertinoColors.systemGrey4,
                      width: 2.0,
                    ),
                  ),
                  padding: const EdgeInsets.all(12.0),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a group description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CategorySelectionForm(
                  selectedCategories: selectedCategories,
                ),
                const SizedBox(height: 20),
                CupertinoButton.filled(
                  onPressed: () {
                    if (selectedCategories.isEmpty) {
                      showCupertinoDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoAlertDialog(
                            title: const Text('Error'),
                            content: const Text(
                                'Please select at least one category'),
                            actions: <CupertinoDialogAction>[
                              CupertinoDialogAction(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                      return;
                    } else {
                      createGroup(
                        Group(
                            name: _groupNameController.text,
                            id: '',
                            admin: widget.user.username,
                            description: _groupDescriptionController.text,
                            categories: selectedCategories),
                        selectedImagePath,
                      );
                    }
                  },
                  child: const Text('Create Group'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void createGroup(Group group, Uint8List imagePath) {
    DatabaseService.createGroup(
        group, FirebaseAuth.instance.currentUser!.uid, imagePath);
    context.go(
      '/home',
      extra: 1,
    );
  }
}
