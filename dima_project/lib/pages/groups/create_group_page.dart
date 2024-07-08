import 'dart:typed_data';

import 'package:dima_project/models/group.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/auth/categoriesform_widget.dart';
import 'package:dima_project/widgets/auth/imageform_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class CreateGroupPage extends StatefulWidget {
  final String uuid;

  const CreateGroupPage({super.key, required this.uuid});

  @override
  CreateGroupPageState createState() => CreateGroupPageState();
}

class CreateGroupPageState extends State<CreateGroupPage> {
  int _currentPage = 1;
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController =
      TextEditingController();
  Uint8List selectedImagePath = Uint8List(0);
  final imageInsertPageKey = GlobalKey<ImageInsertFormState>();
  List<String> selectedCategories = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isPublic = true;
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
        backgroundColor: CupertinoColors.systemPink,
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
          child: const Icon(CupertinoIcons.back, color: CupertinoColors.white),
        ),
        middle: const Text(
          'Create Group',
          style: TextStyle(color: CupertinoColors.white),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                page,
                const SizedBox(height: 10.0),
                SafeArea(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          color: CupertinoColors.systemPink,
                          borderRadius: BorderRadius.circular(20),
                          onPressed: () => {
                            if (_formKey.currentState!.validate()) managePage()
                          },
                          child:
                              Text(_currentPage == 1 ? 'Next' : 'Create Group'),
                        ),
                      ]),
                ),
              ],
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

  Widget pageOneCreateGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: ImageInsertForm(
                  imageType: 1,
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
        const SizedBox(height: 10),
        Row(
          children: [
            const Text('Public group', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            CupertinoSwitch(
              value: isPublic,
              onChanged: (bool value) {
                setState(() {
                  setState(() {
                    isPublic = value;
                  });
                });
              },
            ),
          ],
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
    if (_currentPage == 1) {
      setState(() {
        _currentPage = 2;
      });
    } else {
      if (selectedCategories.isEmpty) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text('Invalid choice'),
              content: const Text('Please select at least one category'),
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
              admin: widget.uuid,
              description: _groupDescriptionController.text,
              categories: selectedCategories,
              isPublic: isPublic),
          selectedImagePath,
        );
      }
    }
  }
}
