import 'package:dima_project/models/event.dart';
import 'package:dima_project/widgets/events/date_picker.dart';
import 'package:dima_project/widgets/events/time_picker_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class EventInfoWidget extends StatelessWidget {
  final int index;
  final Map<int, EventDetails> detailsList;
  final Map<int, bool> boolMap;
  final Function onTap;
  final Function delete;
  final int numInfos;
  final Function startDate;
  final Function endDate;
  final Function startTime;
  final Function endTime;
  final Function add;
  final Function location;
  final int fixedIndex;

  const EventInfoWidget({
    super.key,
    required this.index,
    required this.detailsList,
    required this.boolMap,
    required this.onTap,
    required this.delete,
    required this.numInfos,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.add,
    required this.location,
    required this.fixedIndex,
  });
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: boolMap[index]! && index > fixedIndex - 1
          ? Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: CupertinoTheme.of(context).primaryContrastingColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CupertinoListTile(
                    title: Container(
                      decoration: BoxDecoration(
                        color:
                            CupertinoTheme.of(context).primaryContrastingColor,
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
                    color: CupertinoColors.separator,
                  ),
                  CupertinoListTile(
                    title: Container(
                      decoration: BoxDecoration(
                        color:
                            CupertinoTheme.of(context).primaryContrastingColor,
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
                    color: CupertinoColors.separator,
                  ),
                  CupertinoListTile(
                      title: Container(
                    decoration: BoxDecoration(
                      color: CupertinoTheme.of(context).primaryContrastingColor,
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
                    color: CupertinoColors.separator,
                  ),
                  CupertinoListTile(
                    title: Container(
                      decoration: BoxDecoration(
                        color:
                            CupertinoTheme.of(context).primaryContrastingColor,
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
                    color: CupertinoColors.separator,
                  ),
                  CupertinoListTile(
                    title: Container(
                      decoration: BoxDecoration(
                        color:
                            CupertinoTheme.of(context).primaryContrastingColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CupertinoButton(
                            padding: const EdgeInsets.all(12),
                            borderRadius: BorderRadius.circular(30),
                            child: Icon(
                              CupertinoIcons.map_pin_ellipse,
                              color: CupertinoTheme.of(context).primaryColor,
                            ),
                            onPressed: () => location(),
                          ),
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.5,
                            ),
                            child: Text(
                              detailsList[index]!.location == null
                                  ? 'Location'
                                  : detailsList[index]!.location!,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: CupertinoColors.systemGrey,
                                fontSize: 14,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  if (index == numInfos - 1) const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.only(left: 10),
                        alignment: Alignment.topLeft,
                        onPressed: () {
                          onTap();
                        },
                        child: Row(
                          children: [
                            Text(
                              'Reduce',
                              style: TextStyle(
                                color: CupertinoTheme.of(context).primaryColor,
                                fontSize: 14,
                              ),
                            ),
                            const Icon(
                              CupertinoIcons.minus,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
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
                    ],
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: CupertinoTheme.of(context).primaryContrastingColor,
              ),
              child: Column(
                children: [
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
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.5,
                        ),
                        child: Text(
                          detailsList[index]!.location == null
                              ? 'Location'
                              : detailsList[index]!.location!,
                        ),
                      ),
                    ],
                  ),
                  if (index > fixedIndex - 1)
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CupertinoButton(
                            padding: const EdgeInsets.only(left: 10),
                            alignment: Alignment.centerLeft,
                            onPressed: () {
                              onTap();
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Expand',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                Icon(
                                  CupertinoIcons.add,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                          if (numInfos > 1)
                            Align(
                              alignment: Alignment.bottomRight,
                              child: CupertinoButton(
                                onPressed: () {
                                  delete(index);
                                },
                                child: const Row(
                                  children: [
                                    Text(
                                      'Delete',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    Icon(
                                      CupertinoIcons.trash,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            )
                        ]),
                ],
              ),
            ),
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
}
