import 'package:dima_project/models/event.dart';
import 'package:dima_project/pages/events/create_event_page.dart';
import 'package:dima_project/pages/events/detail_event_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:dima_project/utils/table_calendar_utils.dart';

class TableCalendarPage extends ConsumerStatefulWidget {
  const TableCalendarPage({super.key});

  @override
  TableBasicsExampleState createState() => TableBasicsExampleState();
}

class TableBasicsExampleState extends ConsumerState<TableCalendarPage> {
  late ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  List<Event> events = [];
  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay.value;
    _selectedEvents = ValueNotifier(_getEventsForDay(
      _selectedDay!,
    ));
  }

  @override
  void dispose() {
    _focusedDay.dispose();
    _selectedEvents.dispose();
    ref.read(joinedEventsProvider(AuthService.uid));
    ref.read(createdEventsProvider(AuthService.uid));

    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    List<Event> result = [];
    for (final event in events) {
      for (final detail in event.details!) {
        DateTime start = DateTime(
          detail.startDate!.year,
          detail.startDate!.month,
          detail.startDate!.day,
        );
        DateTime end = DateTime(
            detail.endDate!.year, detail.endDate!.month, detail.endDate!.day);
        if ((day.isAfter(start) && day.isBefore(end)) ||
            isSameDay(start, day) ||
            isSameDay(end, day)) {
          result.add(event);
        }
      }
    }
    return result;
  }

  List<Event> _getEventsForRange(
    DateTime start,
    DateTime end,
  ) {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days)
        ..._getEventsForDay(
          d,
        ),
    ];
  }

  void _onDaySelected(
    DateTime selectedDay,
    DateTime focusedDay,
  ) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay.value = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(
        selectedDay,
      );
    }
  }

  void _onRangeSelected(
    DateTime? start,
    DateTime? end,
    DateTime focusedDay,
  ) {
    setState(() {
      _selectedDay = null;
      _focusedDay.value = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final joinedEvents = ref.watch(joinedEventsProvider(AuthService.uid));
    final createdEvents = ref.watch(createdEventsProvider(AuthService.uid));
    return joinedEvents.when(
      data: (joinedEvents) {
        return createdEvents.when(
          data: (createdEvents) {
            events = [];

            setState(() {
              for (final event in joinedEvents) {
                for (final detail in event.details!) {
                  if (detail.members!.contains(AuthService.uid)) {
                    events.add(event);
                    break;
                  }
                }
              }
              for (final event in createdEvents) {
                for (final detail in event.details!) {
                  if (detail.members!.contains(AuthService.uid)) {
                    events.add(event);
                    break;
                  }
                }
              }
              _selectedEvents = ValueNotifier(_getEventsForDay(
                _selectedDay!,
              ));
            });
            return _buildCalendar();
          },
          loading: () {
            return const Center(child: CupertinoActivityIndicator());
          },
          error: (error, stackTrace) {
            return const Center(child: Text('Error loading created events'));
          },
        );
      },
      loading: () {
        return const Center(child: CupertinoActivityIndicator());
      },
      error: (error, stackTrace) {
        return const Center(child: Text('Error loading joined events'));
      },
    );
  }

  Widget _buildCalendar() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        middle: Text(
          'Calendar',
          style: TextStyle(
            color: CupertinoTheme.of(context).primaryColor,
            fontSize: 25,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => const CreateEventPage(),
              ),
            );
          },
          child: Icon(
            CupertinoIcons.add_circled,
            color: CupertinoTheme.of(context).primaryColor,
          ),
        ),
      ),
      child: Column(
        children: [
          ValueListenableBuilder<DateTime>(
            valueListenable: _focusedDay,
            builder: (context, value, _) {
              return TableCalendar<Event>(
                pageJumpingEnabled: true,
                calendarBuilders: const CalendarBuilders(),
                firstDay: kFirstDay,
                lastDay: kLastDay,
                focusedDay: value,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                rangeStartDay: _rangeStart,
                rangeEndDay: _rangeEnd,
                calendarFormat: _calendarFormat,
                rangeSelectionMode: _rangeSelectionMode,
                eventLoader: _getEventsForDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: CalendarStyle(
                  rangeStartDecoration: BoxDecoration(
                    color: CupertinoTheme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  rangeEndDecoration: BoxDecoration(
                    color: CupertinoTheme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  rangeHighlightColor:
                      CupertinoTheme.of(context).primaryColor.withOpacity(0.5),
                  markerDecoration: BoxDecoration(
                    color: CupertinoTheme.of(context)
                        .textTheme
                        .textStyle
                        .color!
                        .withOpacity(1),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: CupertinoTheme.of(context)
                        .primaryColor
                        .withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: CupertinoTheme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: TextStyle(
                      color: CupertinoTheme.of(context)
                          .textTheme
                          .textStyle
                          .color!),
                  outsideDaysVisible: false,
                  outsideTextStyle: TextStyle(
                    color: CupertinoTheme.of(context)
                        .textTheme
                        .textStyle
                        .color!
                        .withOpacity(0.5),
                  ),
                ),
                onDaySelected: _onDaySelected,
                onRangeSelected: _onRangeSelected,
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay.value = focusedDay;
                },
              );
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    final event = value[index];
                    return SizedBox(
                      height: 75.0,
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: event.details!.length,
                        itemBuilder: (context, index) {
                          final detail = event.details![index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: CupertinoTheme.of(context)
                                      .primaryContrastingColor,
                                ),
                                child: CupertinoListTile(
                                  leading: Icon(
                                    CupertinoIcons.calendar,
                                    color:
                                        CupertinoTheme.of(context).primaryColor,
                                  ),
                                  title: MediaQuery.of(context).size.width >
                                          Constants.limitWidth
                                      ? Row(
                                          children: [
                                            Text(
                                              event.name,
                                              style: TextStyle(
                                                fontSize: 15,
                                                color:
                                                    CupertinoTheme.of(context)
                                                        .textTheme
                                                        .textStyle
                                                        .color,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              '${DateFormat('dd/MM/yyyy').format(detail.startDate!)} - ${DateFormat('dd/MM/yyyy').format(detail.endDate!)}',
                                            ),
                                            const SizedBox(width: 10),
                                            FutureBuilder(
                                                future: EventService
                                                    .getAddressFromLatLng(
                                                        detail.latlng!),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData &&
                                                      snapshot.data != null) {
                                                    final address =
                                                        snapshot.data as String;
                                                    return Text(
                                                      address,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    );
                                                  } else {
                                                    return const Center(
                                                      child:
                                                          CupertinoActivityIndicator(),
                                                    );
                                                  }
                                                }),
                                          ],
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              event.name,
                                              style: TextStyle(
                                                fontSize: 15,
                                                color:
                                                    CupertinoTheme.of(context)
                                                        .textTheme
                                                        .textStyle
                                                        .color,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '${DateFormat('dd/MM/yyyy').format(detail.startDate!)} - ${DateFormat('dd/MM/yyyy').format(detail.endDate!)}',
                                            ),
                                            FutureBuilder(
                                                future: EventService
                                                    .getAddressFromLatLng(
                                                        detail.latlng!),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData &&
                                                      snapshot.data != null) {
                                                    final address =
                                                        snapshot.data as String;
                                                    return Text(
                                                      address,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    );
                                                  } else {
                                                    return const Center(
                                                      child:
                                                          CupertinoActivityIndicator(),
                                                    );
                                                  }
                                                }),
                                          ],
                                        ),
                                  trailing: DateTime(
                                              detail.startDate!.year,
                                              detail.startDate!.month,
                                              detail.startDate!.day,
                                              detail.startTime!.hour,
                                              detail.startTime!.minute)
                                          .isBefore(DateTime.now())
                                      ? const Icon(CupertinoIcons.circle_fill,
                                          color: CupertinoColors.systemRed)
                                      : const Icon(CupertinoIcons.circle_fill,
                                          color: CupertinoColors.systemGreen),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (context) => DetailPage(
                                          eventId: event.id!,
                                          detailId: detail.id!,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
