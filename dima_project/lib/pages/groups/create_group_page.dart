import 'dart:typed_data';

import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/auth/categoriesform_widget.dart';
import 'package:dima_project/widgets/auth/imageform_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemPink,
        leading: CupertinoButton(
          onPressed: () {
            Navigator.of(context).pop();
            //context.go('/groups',extra: widget.user,);
          },
          child: const Icon(CupertinoIcons.back, color: CupertinoColors.white),
        ),
        middle: const Text(
          'Create Group',
          style: TextStyle(color: CupertinoColors.white),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    //height: MediaQuery.of(context).size.height - 200,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 2,
                          child: ImageInsertForm(
                            imageForGroup: true,
                            imagePath: selectedImagePath,
                            imageInsertPageKey: (Uint8List selectedImagePath) {
                              this.selectedImagePath = selectedImagePath;
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 4,
                          child: CupertinoTextFormFieldRow(
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
                            padding: const EdgeInsets.all(3.0),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a group name';
                              }
                              return null;
                            },
                          ),
                        ),
                        const Expanded(flex: 5, child: SizedBox()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: CupertinoTextFormFieldRow(
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
                              title: const Text('Invalid choice'),
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
      ),
    );
  }

  void createGroup(Group group, Uint8List imagePath) async {
    if (_formKey.currentState!.validate()) {
      await DatabaseService.createGroup(
          group, FirebaseAuth.instance.currentUser!.uid, imagePath);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
