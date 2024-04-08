import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/helper_functions.dart';
import 'package:dima_project/widgets/home/group_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  GroupPageState createState() => GroupPageState();
}

class GroupPageState extends State<GroupPage> {
  List<dynamic>? groups;
  bool _isLoading = false;
  String groupName = "";
  UserData? user;

  @override
  void initState() {
    super.initState();
    getUserData();
    getGroups();
  }

  void getGroups() async {
    final fetchedGroups =
        await DatabaseService.getGroups(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      groups = fetchedGroups;
    });
  }

  void getUserData() async {
    await HelperFunctions.getUserData().then((value) {
      setState(() {
        user = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return (groups == null || user == null)
        ? const CupertinoPageScaffold(
            child: Center(
              child: Text("Loading..."),
            ),
          )
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: const Text(
                "Chat",
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 27,
                ),
              ),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  context.go('/search');
                },
                child: const Icon(CupertinoIcons.search),
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  groupList(),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: CupertinoButton(
                      onPressed: () {
                        popUpDialog(context);
                      },
                      child: const Icon(CupertinoIcons.add, size: 30),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  void popUpDialog(BuildContext context) {
    showCupertinoDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Create Group"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _isLoading
                  ? const CupertinoActivityIndicator()
                  : CupertinoTextField(
                      placeholder: "Enter group name",
                      onChanged: (value) {
                        setState(() {
                          groupName = value;
                        });
                      },
                    ),
            ],
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                if (groupName != "") {
                  setState(() {
                    _isLoading = true;
                  });
                  String? uid = await HelperFunctions.getUid();

                  await DatabaseService.createGroup(
                    groupName,
                    uid!,
                  ).then((value) {
                    setState(() {
                      _isLoading = false;
                      Navigator.of(context).pop();
                      getGroups();
                    });
                  });
                }
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  Widget groupList() {
    return StreamBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
      stream:
          Stream.value(groups!.cast<DocumentSnapshot<Map<String, dynamic>>>()),
      builder: (context,
          AsyncSnapshot<List<DocumentSnapshot<Map<String, dynamic>>>>
              snapshot) {
        // Make some checks
        if (snapshot.hasData) {
          var data = snapshot.data!;
          if (data.isNotEmpty) {
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                int reverseIndex = data.length - 1 - index;
                return GroupTile(
                  user: user!,
                  groupId: data[reverseIndex].id,
                  groupName: data[reverseIndex][
                      'groupName'], // Assuming 'groupName' is also part of the data
                );
              },
            );
          } else {
            return noGroupWidget();
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        } else {
          return Container(); // Return an empty container or handle other cases as needed
        }
      },
    );
  }

  Widget noGroupWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(CupertinoIcons.group,
              size: 100, color: CupertinoColors.systemGrey),
          SizedBox(height: 20),
          Text(
            "No groups yet",
            style: TextStyle(
              color: CupertinoColors.systemGrey,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Create a group to start chatting",
            style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
