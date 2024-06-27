import 'package:dima_project/models/user.dart';
import 'package:flutter/cupertino.dart';

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
