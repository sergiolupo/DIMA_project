import 'dart:typed_data';

import 'package:dima_project/models/event.dart';
import 'package:dima_project/pages/invite_page.dart';
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
  DateTime startDate = DateTime.now();
  late DateTime endDate = DateTime(startDate.year, startDate.month,
      startDate.day, startDate.hour + 1, startDate.minute);
  late DateTime startTime = DateTime.now();
  late DateTime endTime = DateTime(startTime.day, startTime.month,
      startTime.year, startTime.hour + 1, startTime.minute);
  late var startDateString = '';
  late var endDateString = '';
  late var startTimeString = '';
  late var endTimeString = '';
  String location = '';
  LatLng? _selectedLocation;
  bool isPublic = true;
  bool notify = true;
  List<String> uuids = [];

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDescriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    startTime = getTime();
    endTime = getEndTime();
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
    if (startDateString.isEmpty) {
      _showErrorDialog('Event start date is required');
      return false;
    }
    if (endDateString.isEmpty) {
      _showErrorDialog('Event end date is required');
      return false;
    }
    if (startTimeString.isEmpty) {
      _showErrorDialog('Event start time is required');
      return false;
    }
    if (endTimeString.isEmpty) {
      _showErrorDialog('Event end time is required');
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
    if (!_isStartDateBeforeEndDate()) {
      _showErrorDialog('Event start date must be before end date');
      return false;
    }
    return true;
  }

  bool _isStartDateBeforeEndDate() {
    final startDateTime = DateTime(startDate.year, startDate.month,
        startDate.day, startTime.hour, startTime.minute);
    final endDateTime = DateTime(
        endDate.year, endDate.month, endDate.day, endTime.hour, endTime.minute);
    return startDateTime.isBefore(endDateTime);
  }

  bool _isEventInThePast() {
    final now = DateTime.now();
    final eventDateTime = DateTime(startDate.year, startDate.month,
        startDate.day, startTime.hour, startTime.minute);
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
      debugPrint('uuids $uuids');
      final event = Event(
        name: _eventNameController.text,
        admin: widget.uuid,
        description: _eventDescriptionController.text,
        startDate: DateTime(startDate.year, startDate.month, startDate.day,
            startTime.hour, startTime.minute),
        endDate: DateTime(endDate.year, endDate.month, endDate.day,
            endTime.hour, endTime.minute),
        members: [widget.uuid],
        isPublic: isPublic,
        notify: notify,
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
                              setState(() {
                                this.selectedImagePath = selectedImagePath;
                              });
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
                    border: Border.all(
                      color: CupertinoColors.systemGrey4,
                      width: 2.0,
                    ),
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
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: CupertinoColors.extraLightBackgroundGray,
                  ),
                  child: Column(
                    children: [
                      CupertinoListTile(
                        title: Container(
                          decoration: const BoxDecoration(
                            color: CupertinoColors.extraLightBackgroundGray,
                          ),
                          child: Row(
                            children: [
                              DatePicker(
                                initialDateTime: startDate,
                                onDateTimeChanged: (selectedDate) =>
                                    setState(() {
                                  startDate = selectedDate;
                                  startDateString = DateFormat('dd/MM/yyyy')
                                      .format(startDate);
                                }),
                              ),
                              Text(
                                startDateString == ''
                                    ? 'Start Date'
                                    : startDateString,
                                style: const TextStyle(
                                  color: CupertinoColors.systemGrey,
                                  fontSize: 14,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 1,
                        color: CupertinoColors.opaqueSeparator,
                      ),
                      CupertinoListTile(
                        title: Container(
                          decoration: const BoxDecoration(
                            color: CupertinoColors.extraLightBackgroundGray,
                          ),
                          child: Row(
                            children: [
                              DatePicker(
                                initialDateTime: endDate,
                                onDateTimeChanged: (selectedDate) =>
                                    setState(() {
                                  endDate = selectedDate;
                                  endDateString =
                                      DateFormat('dd/MM/yyyy').format(endDate);
                                }),
                              ),
                              Text(
                                endDateString == ''
                                    ? 'End Date'
                                    : endDateString,
                                style: const TextStyle(
                                  color: CupertinoColors.systemGrey,
                                  fontSize: 14,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 1,
                        color: CupertinoColors.opaqueSeparator,
                      ),
                      CupertinoListTile(
                          title: Container(
                        decoration: const BoxDecoration(
                          color: CupertinoColors.extraLightBackgroundGray,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            TimePicker(
                              initialTime: startTime,
                              onTimeChanged: (selectedTime) => setState(
                                () {
                                  startTime = selectedTime;
                                  startTimeString =
                                      DateFormat('HH:mm').format(startTime);
                                },
                              ),
                            ),
                            Text(
                              startTimeString == ''
                                  ? 'Start Time'
                                  : startTimeString,
                              style: const TextStyle(
                                color: CupertinoColors.systemGrey,
                                fontSize: 14,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )),
                      Container(
                        height: 1,
                        color: CupertinoColors.opaqueSeparator,
                      ),
                      CupertinoListTile(
                        title: Container(
                          decoration: const BoxDecoration(
                            //borderRadius: BorderRadius.circular(10),
                            color: CupertinoColors.extraLightBackgroundGray,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TimePicker(
                                initialTime: endTime,
                                onTimeChanged: (selectedTime) => setState(() {
                                  endTime = selectedTime;
                                  endTimeString =
                                      DateFormat('HH:mm').format(endTime);
                                }),
                              ),
                              Text(
                                endTimeString == ''
                                    ? 'End Time'
                                    : endTimeString,
                                style: const TextStyle(
                                  color: CupertinoColors.systemGrey,
                                  fontSize: 14,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 1,
                        color: CupertinoColors.opaqueSeparator,
                      ),
                      CupertinoListTile(
                        title: Container(
                          decoration: const BoxDecoration(
                            //borderRadius: BorderRadius.circular(10),
                            color: CupertinoColors.extraLightBackgroundGray,
                          ),
                          child: Row(
                            children: [
                              CupertinoButton(
                                padding: const EdgeInsets.all(12),
                                color: CupertinoColors.extraLightBackgroundGray,
                                borderRadius: BorderRadius.circular(30),
                                child: Icon(
                                  CupertinoIcons.map_pin_ellipse,
                                  color:
                                      CupertinoTheme.of(context).primaryColor,
                                ),
                                onPressed: () => _selectLocation(context),
                              ),
                              Text(
                                location == '' ? 'Location' : location,
                                style: const TextStyle(
                                  color: CupertinoColors.systemGrey,
                                  fontSize: 14,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: CupertinoColors.extraLightBackgroundGray,
                  ),
                  child: Column(
                    children: [
                      CupertinoListTile(
                        title: const Row(
                          children: [
                            Icon(CupertinoIcons.person_3_fill),
                            SizedBox(width: 10),
                            Text('Partecipants'),
                          ],
                        ),
                        trailing: const Icon(CupertinoIcons.forward),
                        onTap: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => InvitePage(
                                uuid: widget.uuid,
                                invitedUsers: uuids,
                                invitePageKey: (String uuid) {
                                  setState(() {
                                    if (uuids.contains(uuid)) {
                                      uuids.remove(uuid);
                                    } else {
                                      uuids.add(uuid);
                                    }
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      Container(
                        height: 1,
                        color: CupertinoColors.opaqueSeparator,
                      ),
                      CupertinoListTile(
                        title: Row(
                          children: [
                            notify
                                ? const Icon(
                                    CupertinoIcons.bell_fill,
                                  )
                                : const Icon(
                                    CupertinoIcons.bell_slash_fill,
                                  ),
                            const SizedBox(width: 10),
                            const Text('Notifications'),
                          ],
                        ),
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
                        color: CupertinoColors.opaqueSeparator,
                      ),
                      CupertinoListTile(
                        title: Row(
                          children: [
                            isPublic
                                ? const Icon(CupertinoIcons.lock_open_fill)
                                : const Icon(CupertinoIcons.lock_fill),
                            const SizedBox(width: 10),
                            const Text('Public Event'),
                          ],
                        ),
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
                const SizedBox(height: 10),
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
    return DateTime(now.year, now.month, now.day, now.hour, 0);
  }

  DateTime getEndTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour + 1, 0);
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
