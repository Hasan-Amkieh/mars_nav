import "package:flutter/material.dart";
import "package:mars_nav/services/InfluxDBHandle.dart";
import "package:table_calendar/table_calendar.dart";

import "../main.dart";
import "../widgets/ToggleButton.dart";
import 'dart:collection';

class HistoryPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return HistoryPageState();
  }

}

class HistoryPageState extends State<HistoryPage> {

  DateTime? fromPeriod;
  DateTime? toPeriod;

  List<ToggleButton> toggleButtonsList = [];

  @override
  void initState() {
    InfluxDBHandle.valueNamesSpaced.forEach((element) {
      toggleButtonsList.add(ToggleButton(text: element, isSelected: true));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.date_range),
                label: Text((fromPeriod == null || toPeriod == null) ? "Choose Period" : ("$fromPeriod-$toPeriod")),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).primaryColor).copyWith(width: 1),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return TableRangeExample();
                    },
                  );
                },
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text("Choose Fields"),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).primaryColor).copyWith(width: 1),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Main.actionColor,
                        title: const Text('Graph Fields', style: TextStyle(color: Colors.white)),
                        content: StatefulBuilder(
                          builder: (context, setState_) {
                            return SizedBox(
                              width: 400,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    children: toggleButtonsList,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(child: const Text("SELECT ALL"), onPressed: () {
                                          setState_(() {
                                            for (ToggleButton bt in toggleButtonsList) {
                                              bt.isSelected = true;
                                              bt.state.isSelected = true;
                                              bt.state.setState(() {});
                                            }
                                          });
                                        }),
                                        TextButton(child: const Text("UNSELECT ALL"), onPressed: () {
                                          setState_(() {
                                            for (ToggleButton bt in toggleButtonsList) {
                                              bt.isSelected = false;
                                              bt.state.isSelected = false;
                                              bt.state.setState(() {});
                                            }
                                          });
                                        }),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ).then((value) {
                    setState(() {});
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

}

/// Example event class.
class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kEventSource);

final _kEventSource = Map.fromIterable(List.generate(50, (index) => index),
    key: (item) => DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5),
    value: (item) => List.generate(
        item % 4 + 1, (index) => Event('Event $item | ${index + 1}')))
  ..addAll({
    kToday: [
      Event('Today\'s Event 1'),
      Event('Today\'s Event 2'),
    ],
  });

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
        (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

class TableRangeExample extends StatefulWidget {
  @override
  _TableRangeExampleState createState() => _TableRangeExampleState();
}

class _TableRangeExampleState extends State<TableRangeExample> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOn; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TableCalendar(
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            calendarFormat: _calendarFormat,
            rangeSelectionMode: _rangeSelectionMode,
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _rangeStart = null; // Important to clean those
                  _rangeEnd = null;
                  _rangeSelectionMode = RangeSelectionMode.toggledOff;
                });
              }
            },
            onRangeSelected: (start, end, focusedDay) {
              setState(() {
                _selectedDay = null;
                _focusedDay = focusedDay;
                _rangeStart = start;
                _rangeEnd = end;
                _rangeSelectionMode = RangeSelectionMode.toggledOn;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          TextButton(
            child: Text("Confirm"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
