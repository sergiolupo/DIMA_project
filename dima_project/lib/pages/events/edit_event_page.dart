import 'dart:typed_data';

import 'package:dima_project/models/event.dart';
import 'package:dima_project/pages/invite_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/services/storage_service.dart';
import 'package:dima_project/widgets/auth/image_crop_page.dart';
import 'package:dima_project/widgets/events/date_picker.dart';
import 'package:dima_project/widgets/events/location_page.dart';
import 'package:dima_project/widgets/events/time_picker.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class EditEventPage extends StatefulWidget {
  final Event event;
  final String uuid;

  @override
  const EditEventPage({super.key, required this.uuid, required this.event});
  @override
  EditEventPageState createState() => EditEventPageState();
}

class EditEventPageState extends State<EditEventPage> {
  Uint8List? selectedImagePath;
  Uint8List? _oldImage;
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionController =
      TextEditingController();
  bool isPublic = true;
  bool notify = true;
  List<String> uuids = [];
  DateTime? startDate;
  DateTime? endDate;
  DateTime? startTime;
  DateTime? endTime;

  String location = '';
  LatLng? _selectedLocation;
  DateTime? start;
  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDescriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _eventNameController.text = widget.event.name;
      _eventDescriptionController.text = widget.event.description;
      isPublic = widget.event.isPublic;
      notify = widget.event.notify;
      startDate = widget.event.startDate;
      endDate = widget.event.endDate;
      startTime = widget.event.startDate;
      endTime = widget.event.endDate;
      _selectedLocation = widget.event.location;
    });
    _fetchProfileImage();
    _fetchLocation();
  }

  Future<void> _fetchProfileImage() async {
    final image =
        await StorageService.downloadImageFromStorage(widget.event.imagePath!);
    setState(() {
      selectedImagePath = image;
      _oldImage = image;
    });
  }

  Future<void> _fetchLocation() async {
    final loc = await EventService.getAddressFromLatLng(widget.event.location);
    setState(() {
      location = loc!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return selectedImagePath == null ||
            startDate == null ||
            endDate == null ||
            startTime == null ||
            endTime == null ||
            _selectedLocation == null ||
            location == ''
        ? const CupertinoActivityIndicator()
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              backgroundColor: CupertinoTheme.of(context).primaryColor,
              leading: CupertinoButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
              trailing: CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () async {
                    if (startDate != null &&
                        endDate != null &&
                        startTime != null &&
                        endTime != null &&
                        EventService.validateForm(
                          context,
                          _eventNameController.text,
                          _eventDescriptionController.text,
                          location,
                          startDate!,
                          endDate!,
                          startTime!,
                          endTime!,
                        )) {
                      await updateEvent();
                      if (context.mounted) Navigator.of(context).pop();
                    }
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                    ),
                  )),
              middle: const Text('Edit Event'),
            ),
            child: SafeArea(
                child: Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.all(16),
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                GestureDetector(
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
                    selectedImagePath!,
                  ),
                ),
                const SizedBox(height: 20),
                CupertinoTextField(
                  placeholder: widget.event.name,
                  controller: _eventNameController,
                  padding: const EdgeInsets.all(16),
                  maxLines: 3,
                  minLines: 1,
                  suffix: CupertinoButton(
                    onPressed: () => _eventNameController.clear(),
                    child: const Icon(CupertinoIcons.clear_circled_solid),
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.extraLightBackgroundGray,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 10),
                CupertinoTextField(
                  placeholder: widget.event.description,
                  controller: _eventDescriptionController,
                  padding: const EdgeInsets.all(16),
                  maxLines: 3,
                  minLines: 1,
                  suffix: CupertinoButton(
                    onPressed: () => _eventDescriptionController.clear(),
                    child: const Icon(CupertinoIcons.clear_circled_solid),
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.extraLightBackgroundGray,
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
                                initialDateTime: startDate!,
                                onDateTimeChanged: (selectedDate) =>
                                    setState(() {
                                  startDate = selectedDate;
                                }),
                              ),
                              Text(
                                DateFormat('dd/MM/yyyy').format(startTime!),
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
                                initialDateTime: widget.event.endDate,
                                onDateTimeChanged: (selectedDate) =>
                                    setState(() {
                                  endDate = selectedDate;
                                }),
                              ),
                              Text(
                                DateFormat('dd/MM/yyyy').format(endDate!),
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
                              initialTime: startTime!,
                              onTimeChanged: (selectedTime) => setState(
                                () {
                                  startTime = selectedTime;
                                },
                              ),
                            ),
                            Text(
                              DateFormat('HH:mm').format(startTime!),
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
                            color: CupertinoColors.extraLightBackgroundGray,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TimePicker(
                                initialTime: endTime!,
                                onTimeChanged: (selectedTime) => setState(() {
                                  endTime = selectedTime;
                                }),
                              ),
                              Text(
                                DateFormat('HH:mm').format(endTime!),
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
                            color: CupertinoColors.extraLightBackgroundGray,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
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
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: CupertinoColors.systemGrey,
                                  fontSize: 14,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: CupertinoColors.extraLightBackgroundGray,
                    ),
                    child: Column(
                      children: [
                        CupertinoListTile(
                          title: const Text('Partecipants'),
                          leading: const Icon(CupertinoIcons.person_3_fill),
                          trailing: const Icon(CupertinoIcons.forward),
                          onTap: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                  builder: (context) => InvitePage(
                                      uuid: widget.uuid,
                                      invitePageKey: (String uuid) {
                                        setState(() {
                                          if (uuids.contains(uuid)) {
                                            uuids.remove(uuid);
                                          } else {
                                            uuids.add(uuid);
                                          }
                                        });
                                      },
                                      invitedUsers: uuids,
                                      isGroup: false,
                                      id: widget.event.id)),
                            );
                          },
                        ),
                        Container(
                          height: 1,
                          color: CupertinoColors.opaqueSeparator,
                        ),
                        CupertinoListTile(
                          title: const Text('Notifications'),
                          leading: notify
                              ? const Icon(CupertinoIcons.bell_fill)
                              : const Icon(CupertinoIcons.bell_slash_fill),
                          trailing: CupertinoSwitch(
                            value: notify,
                            onChanged: (bool value) {
                              setState(() {
                                notify = value;
                              });
                            },
                          ),
                        ),
                        Container(
                          height: 1,
                          color: CupertinoColors.opaqueSeparator,
                        ),
                        CupertinoListTile(
                          leading: isPublic
                              ? const Icon(CupertinoIcons.lock_open_fill)
                              : const Icon(CupertinoIcons.lock_fill),
                          title: const Text('Public Group'),
                          trailing: CupertinoSwitch(
                            value: isPublic,
                            onChanged: (bool value) {
                              setState(() {
                                isPublic = value;
                              });
                            },
                          ),
                        ),
                      ],
                    )),
              ]),
            )));
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

  Future<void> updateEvent() async {
    final event = Event(
      id: widget.event.id,
      admin: widget.event.admin,
      name: _eventNameController.text,
      description: _eventDescriptionController.text,
      location: _selectedLocation!,
      startDate: DateTime(startDate!.year, startDate!.month, startDate!.day,
          startTime!.hour, startTime!.minute),
      endDate: DateTime(endDate!.year, endDate!.month, endDate!.day,
          endTime!.hour, endTime!.minute),
      isPublic: isPublic,
      notify: notify,
      imagePath: widget.event.imagePath,
      members: widget.event.members,
    );
    await DatabaseService.updateEvent(
      event,
      selectedImagePath!,
      _oldImage == selectedImagePath,
      widget.event.isPublic != isPublic,
      uuids,
    );
  }
}
