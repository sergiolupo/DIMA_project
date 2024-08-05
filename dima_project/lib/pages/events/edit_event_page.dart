import 'dart:typed_data';

import 'package:dima_project/models/event.dart';
import 'package:dima_project/pages/invite_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/pages/image_crop_page.dart';
import 'package:dima_project/widgets/events/event_info_widget.dart';
import 'package:dima_project/pages/events/location_page.dart';
import 'package:dima_project/widgets/create_image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class EditEventPage extends ConsumerStatefulWidget {
  final Event event;

  @override
  const EditEventPage({super.key, required this.event});
  @override
  EditEventPageState createState() => EditEventPageState();
}

class EditEventPageState extends ConsumerState<EditEventPage> {
  Uint8List? selectedImagePath;
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionController =
      TextEditingController();
  bool isPublic = true;
  List<String> uids = [];
  Map<int, bool> map = {};
  Map<int, EventDetails> details = {};
  int numInfos = 1;
  String? defaultImage;
  final String uid = AuthService.uid;
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
      for (int i = 0; i < widget.event.details!.length; i++) {
        details[i] = widget.event.details![i];
        map[i] = false;
      }
      numInfos = widget.event.details!.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
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
                BuildContext buildContext = context;
                // Show the loading dialog
                showCupertinoDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext newContext) {
                    buildContext = newContext;
                    return const CupertinoAlertDialog(
                      content: CupertinoActivityIndicator(),
                    );
                  },
                );

                try {
                  await updateEvent();
                } catch (e) {
                  debugPrint('Error: $e');
                } finally {
                  // Pop the loading dialog
                  if (buildContext.mounted) {
                    Navigator.of(buildContext).pop();
                  }
                }
                // Navigate back if the context is still mounted
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
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
              color: CupertinoTheme.of(context).primaryColor, fontSize: 18),
        ),
      ),
      child: ListView(physics: const BouncingScrollPhysics(), children: [
        SafeArea(
            child: Container(
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            GestureDetector(
              onTap: () => {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => ImageCropPage(
                      defaultImage: defaultImage ?? widget.event.imagePath!,
                      imageType: 2,
                      imagePath: selectedImagePath,
                      imageInsertPageKey: (Uint8List selectedImagePath) {
                        setState(() {
                          this.selectedImagePath = selectedImagePath;
                          defaultImage = '';
                        });
                      },
                    ),
                  ),
                )
              },
              child: selectedImagePath == null
                  ? CreateImageWidget.getEventImage(widget.event.imagePath!)
                  : CreateImageWidget.getEventImageMemory(selectedImagePath!),
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
                color: CupertinoTheme.of(context).primaryContrastingColor,
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
                color: CupertinoTheme.of(context).primaryContrastingColor,
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
                  details.putIfAbsent(index, () => EventDetails());

                  return EventInfoWidget(
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
                  );
                }),
            if (widget.event.details!.length == numInfos)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CupertinoButton(
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.calendar_badge_plus,
                            color: CupertinoTheme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 5),
                          Text('Add more dates',
                              style: TextStyle(
                                  color:
                                      CupertinoTheme.of(context).primaryColor)),
                        ],
                      ),
                      onPressed: () {
                        setState(() {
                          numInfos++;
                        });
                      }),
                ],
              ),
            const SizedBox(height: 20),
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: CupertinoTheme.of(context).primaryContrastingColor,
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
                                  invitePageKey: (String uuid) {
                                    setState(() {
                                      if (uids.contains(uuid)) {
                                        uids.remove(uuid);
                                      } else {
                                        uids.add(uuid);
                                      }
                                    });
                                  },
                                  invitedUsers: uids,
                                  isGroup: false,
                                  id: widget.event.id)),
                        );
                      },
                    ),
                    Container(
                      height: 1,
                      color: CupertinoColors.separator,
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
          ]),
        )),
      ]),
    );
  }

  Future<void> _selectLocation(BuildContext context, int idx) async {
    final result = await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => LocationPage(
          initialLocation: details[idx]!.latlng,
        ),
      ),
    );

    if (result != null && result is LatLng) {
      setState(() {
        details[idx]!.latlng = result;
      });
      var loc = await EventService.getAddressFromLatLng(result);
      setState(() {
        details[idx]!.location = loc!;
      });
    }
  }

  Future<void> updateEvent() async {
    for (int i = 0; i < details.length; i++) {
      details[i]!.members = [uid];
    }

    final event = Event(
      id: widget.event.id,
      admin: widget.event.admin,
      name: _eventNameController.text,
      description: _eventDescriptionController.text,
      isPublic: isPublic,
      imagePath: widget.event.imagePath,
      details: details.values.toList(),
      createdAt: widget.event.createdAt,
    );
    await DatabaseService.updateEvent(
      event,
      selectedImagePath,
      selectedImagePath == null,
      widget.event.isPublic != isPublic,
      uids,
    );
    ref.invalidate(eventProvider(widget.event.id!));
    ref.invalidate(createdEventsProvider(uid));
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
