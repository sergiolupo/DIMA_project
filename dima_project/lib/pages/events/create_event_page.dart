import 'dart:developer';
import 'dart:typed_data';

import 'package:dima_project/models/event.dart';
import 'package:dima_project/pages/events/share_event_page.dart';
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
import 'package:lottie/lottie.dart';

class CreateEventPage extends StatefulWidget {
  final String uuid;
  final String? groupId;
  const CreateEventPage({super.key, required this.uuid, this.groupId});

  @override
  CreateEventPageState createState() => CreateEventPageState();
}

class CreateEventPageState extends State<CreateEventPage>
    with TickerProviderStateMixin {
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionController =
      TextEditingController();
  Uint8List selectedImagePath = Uint8List(0);
  final imageInsertPageKey = GlobalKey<ImageCropPageState>();
  late AnimationController animationController;

  DateTime now = DateTime.now();
  LatLng? _selectedLocation;
  bool isPublic = true;
  bool notify = true;
  List<String> uuids = [];
  List<String> groupIds = [];
  int numInfos = 1;
  Map<int, bool> map = {};
  Map<int, Details> details = {};
  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDescriptionController.dispose();
    super.dispose();
    animationController.dispose();
  }

  @override
  void initState() {
    setState(() {
      if (widget.groupId != null) groupIds.add(widget.groupId!);
    });
    super.initState();
    animationController = AnimationController(
      vsync: this,
    );
  }

  Future<void> _createEvent() async {
    if (EventService.validateForm(
      context,
      _eventNameController.text,
      _eventDescriptionController.text,
      details.values.toList(),
    )) {
      showDoneDialog();
      final event = Event(
        name: _eventNameController.text,
        admin: widget.uuid,
        description: _eventDescriptionController.text,
        members: [widget.uuid],
        isPublic: isPublic,
        notify: notify,
        imagePath: selectedImagePath.isNotEmpty ? '' : null,
        details: details.values.toList(),
      );

      await DatabaseService.createEvent(
          event, widget.uuid, selectedImagePath, uuids, groupIds);
      //When the event is created inside a group
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoTheme.of(context).primaryColor,
        leading: Navigator.canPop(context)
            ? CupertinoNavigationBarBackButton(
                color: CupertinoColors.white,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            : null,
        middle: const Text(
          'Create Event',
          style: TextStyle(color: CupertinoColors.white),
        ),
      ),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
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
                    ListView.builder(
                        itemCount: numInfos,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          map.putIfAbsent(index, () => true);
                          details.putIfAbsent(index, () => Details());

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: getEventInfo(
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
                                    isGroup: false,
                                    id: null,
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
                            title: const Row(
                              children: [
                                Icon(CupertinoIcons.person_2_square_stack),
                                SizedBox(width: 10),
                                Text('Groups'),
                              ],
                            ),
                            trailing: const Icon(CupertinoIcons.forward),
                            onTap: () {
                              Navigator.of(context, rootNavigator: true).push(
                                CupertinoPageRoute(
                                  builder: (context) => ShareEventPage(
                                    uuid: widget.uuid,
                                    groupIds: groupIds,
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
        ],
      ),
    );
  }

  void showDoneDialog() {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/done.json',
                repeat: true,
                controller: animationController,
                onLoaded: (composition) {
                  animationController.duration = composition.duration;
                  animationController.forward();
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Event created successfully!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              CupertinoButton(
                child: const Text('OK'),
                onPressed: () {
                  animationController.reset();
                  Navigator.of(context).pop();
                  setState(() {
                    _eventNameController.clear();
                    _eventDescriptionController.clear();
                    selectedImagePath = Uint8List(0);
                    _selectedLocation = null;
                    isPublic = true;
                    notify = true;
                    uuids = [];
                    groupIds = [];
                    numInfos = 1;
                    map = {};
                    details = {};
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static DateTime getStartTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour, 0);
  }

  static DateTime getEndTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour + 1, 0);
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

  static Widget getEventInfo({
    required int index,
    required Map<int, Details> detailsList,
    required Map<int, bool> boolMap,
    required Function onTap,
    required Function delete,
    required BuildContext context,
    required int numInfos,
    required Function startDate,
    required Function endDate,
    required Function startTime,
    required Function endTime,
    required Function add,
    required Function location,
  }) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: boolMap[index]!
          ? Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: CupertinoColors.extraLightBackgroundGray,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CupertinoListTile(
                    title: Container(
                      decoration: const BoxDecoration(
                        color: CupertinoColors.extraLightBackgroundGray,
                      ),
                      child: Row(
                        children: [
                          DatePicker(
                            initialDateTime:
                                detailsList[index]!.startDate ?? DateTime.now(),
                            onDateTimeChanged: (selectedDate) => startDate(
                              selectedDate,
                              index,
                            ),
                          ),
                          Text(
                            detailsList[index]!.startDate == null
                                ? 'Start Date'
                                : DateFormat('dd/MM/yyyy').format(
                                    detailsList[index]!.startDate!,
                                  ),
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
                            initialDateTime:
                                detailsList[index]!.endDate ?? DateTime.now(),
                            onDateTimeChanged: (selectedDate) => endDate(
                              selectedDate,
                              index,
                            ),
                          ),
                          Text(
                            detailsList[index]!.endDate == null
                                ? 'End Date'
                                : DateFormat('dd/MM/yyyy').format(
                                    detailsList[index]!.endDate!,
                                  ),
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
                          initialTime:
                              detailsList[index]!.startTime ?? getStartTime(),
                          onTimeChanged: (selectedTime) => startTime(
                            selectedTime,
                            index,
                          ),
                        ),
                        Text(
                          detailsList[index]!.startTime == null
                              ? 'Start Time'
                              : DateFormat('HH:mm').format(
                                  detailsList[index]!.startTime!,
                                ),
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
                            initialTime:
                                detailsList[index]!.endTime ?? getEndTime(),
                            onTimeChanged: (selectedTime) => endTime(
                              selectedTime,
                              index,
                            ),
                          ),
                          Text(
                            detailsList[index]!.endTime == null
                                ? 'End Time'
                                : DateFormat('HH:mm').format(
                                    detailsList[index]!.endTime!,
                                  ),
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
                              color: CupertinoTheme.of(context).primaryColor,
                            ),
                            onPressed: () => location(),
                          ),
                          Text(
                            detailsList[index]!.location == null
                                ? 'Location'
                                : detailsList[index]!.location!,
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
                  if (index == numInfos - 1)
                    CupertinoButton(
                      padding: const EdgeInsets.only(right: 10),
                      alignment: Alignment.topRight,
                      onPressed: () {
                        add();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Add',
                            style: TextStyle(
                              color: CupertinoTheme.of(context).primaryColor,
                              fontSize: 14,
                            ),
                          ),
                          const Icon(
                            CupertinoIcons.add,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  if (numInfos > 1)
                    CupertinoButton(
                      padding: const EdgeInsets.only(right: 10),
                      alignment: Alignment.centerLeft,
                      onPressed: () {
                        delete(index);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: CupertinoTheme.of(context).primaryColor,
                              fontSize: 14,
                            ),
                          ),
                          const Icon(
                            CupertinoIcons.trash,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            )
          : Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: CupertinoColors.extraLightBackgroundGray,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        detailsList[index]!.startDate == null
                            ? 'Start Date'
                            : DateFormat('dd/MM/yyyy').format(
                                detailsList[index]!.startDate!,
                              ),
                      ),
                      const Text('-'),
                      Text(
                        detailsList[index]!.startTime == null
                            ? 'Start Time'
                            : DateFormat('HH:mm').format(
                                detailsList[index]!.startTime!,
                              ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        detailsList[index]!.endDate == null
                            ? 'End Date'
                            : DateFormat('dd/MM/yyyy').format(
                                detailsList[index]!.endDate!,
                              ),
                      ),
                      const Text('-'),
                      Text(
                        detailsList[index]!.endTime == null
                            ? 'End Time'
                            : DateFormat('HH:mm').format(
                                detailsList[index]!.endTime!,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        detailsList[index]!.location == null
                            ? 'Location'
                            : detailsList[index]!.location!,
                      ),
                      if (numInfos > 1)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: CupertinoButton(
                            onPressed: () {
                              delete(index);
                            },
                            child: const Icon(CupertinoIcons.trash),
                          ),
                        )
                    ],
                  ),
                ],
              ),
            ),
    );
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
