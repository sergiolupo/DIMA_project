import 'dart:typed_data';

import 'package:dima_project/models/event.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/pages/events/share_event_page.dart';
import 'package:dima_project/pages/chats/groups/group_chat_page.dart';
import 'package:dima_project/pages/invite_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/auth/image_crop_page.dart';
import 'package:dima_project/widgets/events/event_info.dart';
import 'package:dima_project/widgets/events/location_page.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart';

class CreateEventPage extends ConsumerStatefulWidget {
  final Group? group;
  final bool canNavigate;
  final Function? navigateToPage;
  const CreateEventPage(
      {super.key, this.group, required this.canNavigate, this.navigateToPage});

  @override
  CreateEventPageState createState() => CreateEventPageState();
}

class CreateEventPageState extends ConsumerState<CreateEventPage>
    with TickerProviderStateMixin {
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionController =
      TextEditingController();
  Uint8List selectedImagePath = Uint8List(0);
  final imageInsertPageKey = GlobalKey<ImageCropPageState>();
  late AnimationController animationController;
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  DateTime now = DateTime.now();
  bool isPublic = true;
  List<String> uids = [];
  List<String> groupIds = [];
  int numInfos = 1;
  Map<int, bool> map = {};
  Map<int, EventDetails> details = {};

  final String uid = AuthService.uid;
  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDescriptionController.dispose();
    animationController.dispose();
    _nameFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    setState(() {
      if (widget.group != null) groupIds.add(widget.group!.id);
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
      null,
    )) {
      showDoneDialog();
      for (int i = 0; i < details.length; i++) {
        details[i]!.members = [uid];
      }
      final event = Event(
        name: _eventNameController.text,
        admin: uid,
        description: _eventDescriptionController.text,
        isPublic: isPublic,
        imagePath: selectedImagePath.isNotEmpty ? '' : null,
        details: details.values.toList(),
      );

      await DatabaseService.createEvent(
          event, selectedImagePath, uids, groupIds);

      ref.invalidate(createdEventsProvider(uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        leading: CupertinoNavigationBarBackButton(
          color: CupertinoTheme.of(context).primaryColor,
          onPressed: () {
            if (widget.canNavigate) {
              widget.navigateToPage!(GroupChatPage(
                canNavigate: widget.canNavigate,
                group: widget.group!,
                navigateToPage: widget.navigateToPage,
              ));
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        middle: Text(
          'Create Event',
          style: TextStyle(
              fontSize: 18, color: CupertinoTheme.of(context).primaryColor),
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
                      onTap: () => _nameFocus.requestFocus(),
                      focusNode: _nameFocus,
                      onTapOutside: (PointerDownEvent event) =>
                          _nameFocus.unfocus(),
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
                                defaultImage: '',
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
                        color:
                            CupertinoTheme.of(context).primaryContrastingColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CupertinoTextField(
                      onTap: () => _descriptionFocus.requestFocus(),
                      focusNode: _descriptionFocus,
                      onTapOutside: (PointerDownEvent event) =>
                          _descriptionFocus.unfocus(),
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
                        color:
                            CupertinoTheme.of(context).primaryContrastingColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    ListView.builder(
                        itemCount: numInfos,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          map.putIfAbsent(index, () => true);
                          details.putIfAbsent(index, () => EventDetails());

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: EventInfo(
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
                              fixedIndex: 0,
                            ),
                          );
                        }),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color:
                            CupertinoTheme.of(context).primaryContrastingColor,
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
                                    invitedUsers: uids,
                                    invitePageKey: (String uuid) {
                                      setState(() {
                                        if (uids.contains(uuid)) {
                                          uids.remove(uuid);
                                        } else {
                                          uids.add(uuid);
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
                            color: CupertinoColors.separator,
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
                                    groupIds: groupIds,
                                  ),
                                ),
                              );
                            },
                          ),
                          Container(
                            height: 1,
                            color: CupertinoColors.separator,
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
                          color: CupertinoTheme.of(context).primaryColor,
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
      builder: (BuildContext newContext) {
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

                  Navigator.of(newContext).pop();

                  if (mounted) {
                    setState(() {
                      _eventNameController.clear();
                      _eventDescriptionController.clear();
                      selectedImagePath = Uint8List(0);
                      isPublic = true;
                      uids = [];
                      groupIds = [];
                      numInfos = 1;
                      map = {};
                      details = {};
                    });
                  }
                  if (widget.canNavigate) {
                    widget.navigateToPage!(GroupChatPage(
                      canNavigate: widget.canNavigate,
                      group: widget.group!,
                      navigateToPage: widget.navigateToPage,
                    ));
                  } else {
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
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
