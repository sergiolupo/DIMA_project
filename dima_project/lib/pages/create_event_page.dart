import 'dart:typed_data';

import 'package:dima_project/models/event.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/widgets/auth/image_crop_page.dart';
import 'package:dima_project/widgets/events/date_picker.dart';
import 'package:dima_project/widgets/events/location_page.dart';
import 'package:dima_project/widgets/events/time_picker.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class CreateEventPage extends StatefulWidget {
  final String uuid;

  const CreateEventPage({super.key, required this.uuid});

  @override
  CreateEventPageState createState() => CreateEventPageState();
}

class CreateEventPageState extends State<CreateEventPage> {
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionController =
      TextEditingController();
  Uint8List selectedImagePath = Uint8List(0);
  final imageInsertPageKey = GlobalKey<ImageCropPageState>();
  DateTime date = DateTime.now();
  late DateTime time = DateTime.now();
  late var dateString = '';
  late var timeString = '';
  String location = '';
  LatLng? _selectedLocation;
  bool isPublic = true;
  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDescriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    time = getTime();
  }

  bool _validateForm() {
    if (_eventNameController.text.isEmpty) {
      _showErrorDialog('Event name is required');
      return false;
    }
    if (_eventDescriptionController.text.isEmpty) {
      _showErrorDialog('Event description is required');
      return false;
    }
    if (dateString.isEmpty) {
      _showErrorDialog('Event date is required');
      return false;
    }
    if (timeString.isEmpty) {
      _showErrorDialog('Event time is required');
      return false;
    }
    if (location.isEmpty) {
      _showErrorDialog('Event location is required');
      return false;
    }
    if (_isEventInThePast()) {
      _showErrorDialog('Event cannot be scheduled in the past');
      return false;
    }
    return true;
  }

  bool _isEventInThePast() {
    final now = DateTime.now();
    final eventDateTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    return eventDateTime.isBefore(now);
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Validation Error'),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _createEvent() async {
    if (_validateForm()) {
      final event = Event(
        name: _eventNameController.text,
        admin: widget.uuid,
        description: _eventDescriptionController.text,
        date: DateTime(date.year, date.month, date.day, time.hour, time.minute),
        members: [widget.uuid],
        isPublic: isPublic,
        imagePath: selectedImagePath.isNotEmpty ? '' : null,
        location: _selectedLocation!,
      );

      await DatabaseService.createEvent(event, widget.uuid, selectedImagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoTheme.of(context).primaryColor,
        leading: CupertinoButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Icon(CupertinoIcons.back,
              color: CupertinoColors.systemPink),
        ),
        middle: const Text(
          'Create Event',
          style: TextStyle(color: CupertinoColors.white),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                const SizedBox(height: 20),
                CupertinoTextField(
                  controller: _eventNameController,
                  textInputAction: TextInputAction.next,
                  padding: const EdgeInsets.all(16),
                  placeholder: 'Event Name',
                  minLines: 1,
                  maxLines: 3,
                  prefix: GestureDetector(
                    onTap: () => {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => ImageCropPage(
                            imageType: 2,
                            imagePath: selectedImagePath,
                            imageInsertPageKey: (Uint8List selectedImagePath) {
                              this.selectedImagePath = selectedImagePath;
                            },
                          ),
                        ),
                      )
                    },
                    child: CreateImageWidget.getEventImageMemory(
                      selectedImagePath,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.extraLightBackgroundGray,
                    border: Border.all(color: CupertinoColors.systemGrey4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 10),
                CupertinoTextField(
                  controller: _eventDescriptionController,
                  padding: const EdgeInsets.all(16),
                  placeholder: 'Event Description',
                  maxLines: 3,
                  minLines: 1,
                  suffix: CupertinoButton(
                    onPressed: () => _eventDescriptionController.clear(),
                    child: const Icon(CupertinoIcons.clear_circled_solid),
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.extraLightBackgroundGray,
                    border: Border.all(color: CupertinoColors.systemGrey4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                CupertinoFormSection.insetGrouped(
                  margin: const EdgeInsets.all(12),
                  header: const Text('Date and Time'),
                  children: [
                    CupertinoTextFormFieldRow(
                      readOnly: true,
                      prefix: DatePicker(
                        initialDateTime: date,
                        onDateTimeChanged: (selectedDate) => setState(() {
                          date = selectedDate;
                          dateString = DateFormat('dd/MM/yyyy').format(date);
                          debugPrint('Selected date: $dateString');
                        }),
                      ),
                      placeholder: dateString == '' ? 'Date' : dateString,
                      placeholderStyle: const TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    CupertinoTextFormFieldRow(
                      readOnly: true,
                      prefix: TimePicker(
                        initialTime: time,
                        onTimeChanged: (selectedTime) => setState(() {
                          time = selectedTime;
                          timeString = DateFormat('HH:mm').format(time);
                          debugPrint('Selected time: $timeString');
                        }),
                      ),
                      placeholder: timeString == '' ? 'Time' : timeString,
                      placeholderStyle: const TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    CupertinoTextFormFieldRow(
                      readOnly: true,
                      prefix: CupertinoButton(
                        padding: const EdgeInsets.all(12),
                        color: CupertinoColors.extraLightBackgroundGray,
                        borderRadius: BorderRadius.circular(30),
                        child: Icon(
                          CupertinoIcons.map_pin_ellipse,
                          color: CupertinoTheme.of(context).primaryColor,
                        ),
                        onPressed: () => _selectLocation(context),
                      ),
                      placeholder: location == '' ? 'Location' : location,
                      placeholderStyle: const TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Public Event',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.systemGrey),
                    ),
                    const SizedBox(width: 10),
                    Transform.scale(
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
                  ],
                ),
                const SizedBox(height: 100),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoButton(
                      onPressed: _createEvent,
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      color: CupertinoColors.systemPink,
                      borderRadius: BorderRadius.circular(20),
                      child: const Text(
                        'Create Event',
                        style: TextStyle(
                          fontSize: 15,
                          letterSpacing: 2,
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DateTime getTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour, 15);
  }

  Future<void> _selectLocation(BuildContext context) async {
    final result = await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => LocationPage(
          initialLocation: _selectedLocation,
        ),
      ),
    );

    if (result != null && result is LatLng) {
      var loc = await EventService.getAddressFromLatLng(result);

      setState(() {
        _selectedLocation = result;
        location = loc!;
        debugPrint('Selected location: $location');
        debugPrint('Selected location: $_selectedLocation');
      });
    }
  }
}
