import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/groups/list_chat_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/auth/categoriesform_widget.dart';
import 'package:dima_project/widgets/auth/imageform_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class CreateEventPage extends StatefulWidget {
  final UserData user;

  const CreateEventPage({super.key, required this.user});

  @override
  CreateEventPageState createState() => CreateEventPageState();
}

class CreateEventPageState extends State<CreateEventPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(child: Container());
  }
}
