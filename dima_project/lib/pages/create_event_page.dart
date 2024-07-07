import 'dart:typed_data';

import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/widgets/auth/imageform_widget.dart';
import 'package:dima_project/widgets/events/date_picker.dart';
import 'package:dima_project/widgets/events/location_page.dart';
import 'package:dima_project/widgets/events/time_picker.dart';
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
  String _eventName = '';
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionController =
      TextEditingController();
  Uint8List selectedImagePath = Uint8List(0);
  final imageInsertPageKey = GlobalKey<ImageInsertFormState>();
  DateTime date = DateTime.now();
  late DateTime time = DateTime.now();
  late var dateString = '';
  late var timeString = '';
  String location = '';
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

    time = getTime();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoTheme.of(context).primaryColor,
        leading: CupertinoButton(
          onPressed: () {
            //Navigator.of(context).pop();
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
                const SizedBox(
                  height: 20,
                ),
                CupertinoTextField(
                  textInputAction: TextInputAction.next,
                  padding: const EdgeInsets.all(16),
                  placeholder: 'Event Name',
                  minLines: 1,
                  prefix: CupertinoButton(
                    onPressed: () {},
                    child: ImageInsertForm(
                      imageForGroup: true,
                      imagePath: selectedImagePath,
                      imageInsertPageKey: (Uint8List selectedImagePath) {
                        this.selectedImagePath = selectedImagePath;
                      },
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.extraLightBackgroundGray,
                    border: Border.all(
                      color: CupertinoColors.systemGrey4,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onChanged: (value) => setState(() => _eventName = value),
                ),
                const SizedBox(
                  height: 10,
                ),
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
                    border: Border.all(
                      color: CupertinoColors.systemGrey4,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
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
                                  dateString =
                                      DateFormat('dd/MM/yyyy').format(date);
                                  debugPrint('Selected date: $dateString');
                                })),
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
                                  debugPrint('Selected time: $time');
                                })),
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
                    ]),
                const SizedBox(height: 100),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoButton(
                      onPressed: () {
                        // Create event
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      color: CupertinoColors.systemPink,
                      borderRadius: BorderRadius.circular(20),
                      child: const Text(
                        'Create Event',
                        style: TextStyle(
                            fontSize: 15,
                            letterSpacing: 2,
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.bold),
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
