import 'package:flutter/cupertino.dart';

class EditEventPage extends StatefulWidget {
  final String eventId;

  @override
  const EditEventPage({super.key, required this.eventId});
  @override
  EditEventPageState createState() => EditEventPageState();
}

class EditEventPageState extends State<EditEventPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Edit Event'),
      ),
      child: Container(
          // Aggiungi qui i tuoi componenti UI
          ),
    );
  }
}
