import 'dart:typed_data';

import 'package:dima_project/models/event.dart';
import 'package:dima_project/pages/events/create_event_page.dart';
import 'package:dima_project/pages/invite_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/services/storage_service.dart';
import 'package:dima_project/widgets/auth/image_crop_page.dart';
import 'package:dima_project/widgets/events/location_page.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class EditEventPage extends ConsumerStatefulWidget {
  final Event event;
  final String uuid;

  @override
  const EditEventPage({super.key, required this.uuid, required this.event});
  @override
  EditEventPageState createState() => EditEventPageState();
}

class EditEventPageState extends ConsumerState<EditEventPage> {
  Uint8List? selectedImagePath;
  Uint8List? _oldImage;
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionController =
      TextEditingController();
  bool isPublic = true;
  bool notify = true;
  List<String> uuids = [];
  Map<int, bool> map = {};
  Map<int, Details> details = {};
  bool isLoaded = false;
  int numInfos = 1;
  LatLng? _selectedLocation;

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
      for (int i = 0; i < widget.event.details!.length; i++) {
        details[i] = widget.event.details![i];
        map[i] = false;
      }
      details[widget.event.details!.length] = Details();
      map[widget.event.details!.length] = true;
      numInfos = widget.event.details!.length + 1;
    });
    _fetchProfileImage();
    _fetchLocations();
  }

  Future<void> _fetchProfileImage() async {
    final image =
        await StorageService.downloadImageFromStorage(widget.event.imagePath!);
    setState(() {
      selectedImagePath = image;
      _oldImage = image;
    });
  }

  Future<void> _fetchLocations() async {
    if (widget.event.details!.isEmpty) {
      setState(() {
        isLoaded = true;
      });
      return;
    }
    for (int i = 0; i < widget.event.details!.length; i++) {
      final loc = await EventService.getAddressFromLatLng(
          widget.event.details![i].latlng!);
      setState(() {
        details[i]!.location = loc!;
        if (i == widget.event.details!.length - 1) {
          isLoaded = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return selectedImagePath == null ||
            _eventNameController.text.isEmpty ||
            _eventDescriptionController.text.isEmpty ||
            !isLoaded
        ? const CupertinoActivityIndicator()
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
              leading: CupertinoButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 18,
                    color: CupertinoTheme.of(context).primaryColor,
                  ),
                ),
              ),
              trailing: CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () async {
                    if (EventService.validateForm(
                        context,
                        _eventNameController.text,
                        _eventDescriptionController.text,
                        details.values.toList(),
                        widget.event.details!)) {
                      await updateEvent();
                      if (context.mounted) Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    'Done',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: CupertinoTheme.of(context).primaryColor,
                    ),
                  )),
              middle: Text(
                'Edit Event',
                style: TextStyle(
                    color: CupertinoTheme.of(context).primaryColor,
                    fontSize: 18),
              ),
            ),
            child: ListView(physics: const BouncingScrollPhysics(), children: [
              SafeArea(
                  child: Container(
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.all(16),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => ImageCropPage(
                                imageType: 2,
                                imagePath: selectedImagePath,
                                imageInsertPageKey:
                                    (Uint8List selectedImagePath) {
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
                      ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: numInfos,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            map.putIfAbsent(index, () => true);
                            details.putIfAbsent(index, () => Details());

                            return Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: CreateEventPageState.getEventInfo(
                                fixedIndex: widget.event.details!.length,
                                location: () => _selectLocation(context, index),
                                startDate: (DateTime selectedDate, int index) {
                                  setState(() {
                                    details[index]!.startDate = selectedDate;
                                  });
                                },
                                endDate: (DateTime selectedDate, int index) {
                                  setState(() {
                                    details[index]!.endDate = selectedDate;
                                  });
                                },
                                startTime: (DateTime selectedTime, int index) {
                                  setState(() {
                                    details[index]!.startTime = selectedTime;
                                  });
                                },
                                endTime: (DateTime selectedTime, int index) {
                                  setState(() {
                                    details[index]!.endTime = selectedTime;
                                  });
                                },
                                add: () {
                                  setState(() {
                                    numInfos++;
                                  });
                                },
                                numInfos: numInfos,
                                context: context,
                                index: index,
                                detailsList: details,
                                boolMap: map,
                                onTap: () {
                                  setState(() {
                                    map[index] = !map[index]!;
                                  });
                                },
                                delete: (int index) {
                                  setState(() {
                                    delete(index);
                                  });
                                },
                              ),
                            );
                          }),
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
                                leading:
                                    const Icon(CupertinoIcons.person_3_fill),
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
                                    : const Icon(
                                        CupertinoIcons.bell_slash_fill),
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
                      const SizedBox(height: 20),
                      CupertinoButton.filled(
                          child: const Text(
                            'Delete Event',
                            style: TextStyle(color: CupertinoColors.white),
                          ),
                          onPressed: () {
                            showCupertinoDialog(
                              context: context,
                              builder: (newContext) => CupertinoAlertDialog(
                                title: const Text('Delete Event'),
                                content: const Text(
                                    'Are you sure you want to delete this date?'),
                                actions: <Widget>[
                                  CupertinoDialogAction(
                                    child: const Text('Cancel'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                  CupertinoDialogAction(
                                    child: const Text('Delete'),
                                    onPressed: () async {
                                      Navigator.of(newContext).pop();
                                      await DatabaseService.deleteEvent(
                                          widget.event.id!);
                                      ref.invalidate(
                                          createdEventsProvider(widget.uuid));
                                      ref.invalidate(
                                          joinedEventsProvider(widget.uuid));
                                      ref.invalidate(
                                          eventProvider(widget.event.id!));
                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                    ]),
              )),
            ]),
          );
  }

  Future<void> _selectLocation(BuildContext context, int idx) async {
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
        details[idx]!.latlng = result;
        details[idx]!.location = loc!;
      });
    }
  }

  Future<void> updateEvent() async {
    for (int i = 0; i < details.length; i++) {
      details[i]!.members = [widget.uuid];
    }

    final event = Event(
      id: widget.event.id,
      admin: widget.event.admin,
      name: _eventNameController.text,
      description: _eventDescriptionController.text,
      isPublic: isPublic,
      notify: notify,
      imagePath: widget.event.imagePath,
      details: details.values.toList(),
      createdAt: widget.event.createdAt,
    );

    await DatabaseService.updateEvent(
      event,
      selectedImagePath!,
      _oldImage == selectedImagePath,
      widget.event.isPublic != isPublic,
      uuids,
    );
    ref.invalidate(eventProvider(widget.event.id!));
    ref.invalidate(joinedEventsProvider(widget.uuid));
    ref.invalidate(createdEventsProvider(widget.uuid));
  }

  void delete(int index) {
    setState(() {
      if (index == numInfos - 1) {
        map.remove(index);
        details.remove(index);
      } else {
        for (int i = numInfos - 1; i > index; i--) {
          map[i - 1] = map[i]!;
          details[i - 1] = details[i]!;
        }
        details.remove(numInfos - 1);
        map.remove(numInfos - 1);
      }
      numInfos--;
    });
  }
}
