import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/helper_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  bool _isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  UserData? user;
  bool isJoined = false;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  getUserData() async {
    await DatabaseService.getUserData((await HelperFunctions.getUid())!)
        .then((value) {
      setState(() {
        user = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          "Search",
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
        backgroundColor: CupertinoTheme.of(context).primaryColor,
      ),
      child: Column(
        children: [
          Container(
            color: CupertinoTheme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    controller: searchController,
                    placeholder: "Search groups...",
                    placeholderStyle:
                        const TextStyle(color: CupertinoColors.white),
                    style: const TextStyle(color: CupertinoColors.white),
                    decoration: BoxDecoration(border: Border.all(width: 0)),
                  ),
                ),
                GestureDetector(
                  onTap: initiateSearchMethod,
                  child: Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white.withOpacity(1.0),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      CupertinoIcons.search,
                      color: CupertinoColors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _isLoading
              ? const Center(
                  child: CupertinoActivityIndicator(
                    radius: 16,
                  ),
                )
              : Expanded(child: groupList()),
        ],
      ),
    );
  }

  initiateSearchMethod() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      await DatabaseService.searchByName(searchController.text).then((val) {
        setState(() {
          searchSnapshot = val;
          _isLoading = false;
          hasUserSearched = true;
        });
      });
    }
  }

  Widget groupList() {
    return hasUserSearched
        ? searchSnapshot!.docs.isEmpty
            ? const Center(
                child: Text("No groups found"),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: searchSnapshot!.docs.length,
                itemBuilder: (context, index) {
                  return groupTile(
                    user!,
                    searchSnapshot!.docs[index]['groupId'],
                    searchSnapshot!.docs[index]['groupName'],
                    searchSnapshot!.docs[index]['admin'],
                  );
                },
              )
        : const Center(
            child: Text("Search for groups"),
          );
  }

  joinedOrNot(String userName, String groupId, String groupName, String admin) {
    DatabaseService.isUserJoined(
      groupId,
      FirebaseAuth.instance.currentUser!.uid,
    ).then((value) {
      setState(() {
        isJoined = value;
      });
    });
  }

  Widget groupTile(
    UserData user,
    String groupId,
    String groupName,
    String admin,
  ) {
    joinedOrNot(user.username, groupId, groupName, admin);
    return CupertinoListTile(
      leading: ClipOval(
        child: Text(
          groupName.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: CupertinoColors.white),
        ),
      ),
      title: Text(
        groupName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text("Admin: $admin"),
      trailing: GestureDetector(
        onTap: () async {
          await DatabaseService.toggleGroupJoin(
            groupId,
            FirebaseAuth.instance.currentUser!.uid,
          );
          if (isJoined) {
            setState(() {
              isJoined = !isJoined;
              showCupertinoDialog(
                context: context,
                builder: (context) {
                  return CupertinoAlertDialog(
                    content: const Text("You have joined the group"),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
            });
          } else {
            setState(() {
              isJoined = !isJoined;
              showCupertinoDialog(
                context: context,
                builder: (context) {
                  return CupertinoAlertDialog(
                    content: const Text(
                        "You have left the group\nYou can join again by clicking the join button"),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.pop(context);
                          context.go('/chat', extra: {
                            "username": user.username,
                            "groupName": groupName,
                            "groupId": groupId,
                          });
                        },
                      ),
                    ],
                  );
                },
              );
            });
          }
        },
        child: isJoined
            ? Container(
                decoration: BoxDecoration(
                  color: CupertinoTheme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: CupertinoColors.white),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: const Text(
                  "Joined",
                  style: TextStyle(color: CupertinoColors.white),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  color: CupertinoTheme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: CupertinoColors.white),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: const Text("Join Now",
                    style: TextStyle(color: CupertinoColors.white)),
              ),
      ),
    );
  }
}
