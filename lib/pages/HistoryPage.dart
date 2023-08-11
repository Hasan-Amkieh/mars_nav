import "dart:async";

import "package:flutter/material.dart";
import "package:mars_nav/services/InfluxDBHandle.dart";
import "package:mars_nav/widgets/SpeedButton.dart";
import "package:syncfusion_flutter_charts/charts.dart";
import "package:table_calendar/table_calendar.dart";

import "../main.dart";
import "../widgets/ToggleButton.dart";
import 'dart:collection';

import "SensoryPage.dart";

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

  Map<String, List<TimeData>> data = {};

  static const List<Color> linesColors = [
    Color(0xFFFF9800),
    Color(0xFFF44336),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF673AB7),
    Color(0xFF3F51B5),
    Color(0xFF2196F3),
    Color(0xFF03A9F4),
    Color(0xFF00BCD4),
    Color(0xFF009688),
    Color(0xFF4CAF50),
    Color(0xFF8BC34A),
    Color(0xFFCDDC39),
    Color(0xFFFFEB3B),
    Color(0xFFFFC107),
    Color(0xFFFF9800),
    Color(0xFFFF5722),
    Color(0xFF795548),
    Color(0xFF9E9E9E),
    Color(0xFF607D8B),
    Color(0xFF00ACC1),
    Color(0xFF006064),
    Color(0xFF00838F),
    Color(0xFF1A237E),
    Color(0xff311B92),
    Color(0xff4A148C),
    Color(0xff1B5E20),
    Color(0xff33691E),
    Color(0xFF827717),
    Color(0xffF57F17),
    Color(0xffFF6F00),
    Color(0xFFE65100),
    Color(0xFFBF360C),
    Color(0xFF3E2723),
    Color(0xFF424242),
    Color(0xFF37474F),
    Color(0xFF01579B),
    Color(0xFF1B5E20),
    Color(0xFFFF6F00),
    Color(0xFFF57F17),
    Color(0xFFF44336),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF673AB7),
    Color(0xFF3F51B5),
    Color(0xFF2196F3),
    Color(0xFF00BCD4),
    Color(0xFF009688),
    Color(0xFF4CAF50),
    Color(0xFFFF5722),
  ];

  List<String> labels = []; // will hold the required the value names that are selected from the toggleButtons

  @override
  void initState() {

    InfluxDBHandle.valueNames.values.forEach((element) {
      bool isSel = false;
      if (element == "CPU Util" || element == "GPU Util" || element == "Used RAM") {
        isSel = true;
      }
      toggleButtonsList.add(ToggleButton(text: element, isSelected: isSel));
    });

    DateTime now = DateTime.now();
    updateData(DateTime(now.year, now.month, now.day).subtract(const Duration(days: 60)), now);

    super.initState();
  }

  void updateData(DateTime from, DateTime to) {
    print("$from to $to");
    data = {};
    updateLabels();
    List<String> transLabels = labels.map((e) {
      return InfluxDBHandle.valueNames.keys.firstWhere((k) => InfluxDBHandle.valueNames[k] == e, orElse: () => "");
    }).toList();
    print("translated table: $transLabels");
    InfluxDBHandle().read(from, to, transLabels).then((value) async {
      value.forEach((element) {
        List<String> parts = element.split(" | ");
        if (!data.containsKey(parts[1])) {
          data[parts[1]] = <TimeData>[];
        }
        data[parts[1]]?.add(TimeData(DateTime.parse(parts[0]), double.parse(parts[2])));
      });
      setState(() {
        updateGraph();
      });
    });
  }

  void updateLabels() {
    labels = [];
    toggleButtonsList.forEach((element) {
      if (element.isSelected) {
        labels.add(element.text);
      }
    });
  }

  void updateGraph() {
    series = [];
    int index = 0;
    data.forEach((key, value) {
      if (labels.contains(InfluxDBHandle.valueNames[key])) {
        series.add(LineSeries<TimeData, DateTime>(
          markerSettings: const MarkerSettings(isVisible: true),
          dataSource: value,
          xValueMapper: (TimeData data, _) => data.x,
          yValueMapper: (TimeData data, _) => data.y,
          color: linesColors[index],
          name: key,
        ));
      }
      if (++index == linesColors.length) {
        index = 0;
      }
      setState(() {});
    });
  }

  static bool isConfirmed = false;
  List<LineSeries> series = [];

  DateTime currentPlayerTime = DateTime.now();

  double currentPlayerTimePercent = 0;

  Timer? _timer;
  List<TimeData> _dataPoints = [];
  double timePassed = 0; // if reaches to animationLength, then stop
  int toWait = 2; // variable depending the playing speed
  int animationLength = 30; // after the 30 seconds, stop
  bool isAnimRunning = false;

  void _startTimer() {
    isAnimRunning = true;
    _timer = Timer.periodic(Duration(seconds: toWait), (timer) {
      timePassed = timePassed + toWait;
      if (timePassed > animationLength) {
        timer.cancel();
      } else {
        setState(() {
          _dataPoints = _getDataInBetween(timePassed / animationLength);
        });
      }
    });
  }

  List<TimeData> _getDataInBetween(double from) {

    return [];

  }

  @override
  void dispose() {
    if (isAnimRunning) {
      _timer!.cancel();
    }
    super.dispose();
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
                label: Text((fromPeriod == null || toPeriod == null) ? "Choose Period" : ("${fromPeriod?.day}/${fromPeriod?.month}/${fromPeriod?.year} - ${toPeriod?.day}/${toPeriod?.month}/${toPeriod?.year}")),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).primaryColor).copyWith(width: 1),
                ),
                onPressed: () {
                  InfluxDBHandle().countByDays(kFirstDay, kLastDay).then((value) {
                    value.forEach((key, value) {
                      TableRangeState.dayCounts[DateTime.parse(key)] = value;
                    });
                    showDialog(
                      context: context,
                      builder: (context) {
                        return TableRange();
                      },
                    ).then((value) {
                      setState(() {
                        if (isConfirmed) {
                          fromPeriod = TableRangeState.rangeStart;
                          toPeriod = TableRangeState.rangeEnd;
                          currentPlayerTime = TableRangeState.rangeStart!;
                          DateTime now = DateTime.now();
                          print("updating from ${fromPeriod ?? now} to ${toPeriod ?? now}");
                          updateData(fromPeriod ?? now, toPeriod ?? now);
                        }
                      });
                    });
                  });
                },
              ),
              Row(
                children: [
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
                        setState(() {
                          DateTime now = DateTime.now();
                          updateData(fromPeriod ?? now.subtract(const Duration(days: 60)), toPeriod ?? now);
                        });
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.picture_in_picture, color: Theme.of(context).primaryColor),
                    onPressed: () {
                      ;
                    },
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Visibility(
              visible: (fromPeriod != null && toPeriod != null),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Slider(
                        value: currentPlayerTimePercent,
                        min: 0,
                        max: 100,
                        onChanged: (newValue) {
                          setState(() {
                            currentPlayerTimePercent = newValue;
                            int x = ((toPeriod!.millisecondsSinceEpoch - fromPeriod!.millisecondsSinceEpoch) * (currentPlayerTimePercent / 100.0)).toInt();
                            currentPlayerTime = DateTime.fromMillisecondsSinceEpoch(fromPeriod!.millisecondsSinceEpoch + x);
                          });
                        },
                      ),
                      Text("${currentPlayerTime.year}-${currentPlayerTime.month}-${currentPlayerTime.day} ${currentPlayerTime.hour}:${currentPlayerTime.minute}", style: const TextStyle(color: Colors.white)),
                      const SizedBox(width: 10),
                      SpeedButton(onPress: (speed) {
                        ;
                      }),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: isAnimRunning ? null : () {
                          setState(() {
                            _startTimer();
                            isAnimRunning = true;
                          });
                        },
                        child: Icon(Icons.play_arrow, color: isAnimRunning ? Colors.grey : Colors.green),
                      ),
                      TextButton(
                        onPressed: !isAnimRunning ? null : () {
                          setState(() {
                            _timer!.cancel();
                            isAnimRunning = false;
                          });
                        },
                        child: Icon(Icons.pause, color: isAnimRunning ? Colors.red : Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AspectRatio(
            aspectRatio: 2.3,
            child: SfCartesianChart(
              trackballBehavior: TrackballBehavior(
                lineColor: Colors.white.withOpacity(0.5),
                enable: true,
                lineType: TrackballLineType.vertical,
                activationMode: ActivationMode.singleTap,
                builder: (context, trackballDetails) {
                  DateTime time = trackballDetails.series?.dataSource[trackballDetails.pointIndex ?? 0].x;
                  double number = trackballDetails.series?.dataSource[trackballDetails.pointIndex ?? 0].y;
                  String number_str = "";
                  String name = trackballDetails.series?.name ?? "ERROR";
                  if (name.startsWith("UV-light-intensity")) {
                    name = "UV Light Intensity";
                    number = number * 100;
                    number_str = "${number.toStringAsPrecision(2)}%";
                  } else if (name.startsWith("CPU-util")) {
                    name = "CPU Util";
                    number = number * 1;
                    number_str = "${number.toStringAsPrecision(2)}%";
                  } else if (name.startsWith("GPU-util")) {
                    name = "GPU Util";
                    number = number * 1;
                    number_str = "${number.toStringAsPrecision(2)}%";
                  } else if (name.startsWith("used-RAM")) {
                    name = "Used RAM";
                    number = number * 0.04;
                    number_str = "${number.toStringAsPrecision(2)} GB";
                  } else if (name.startsWith("air-pressure")) {
                    name = "Air Pressure";
                    number = number * 100;
                    number_str = "${number.toStringAsPrecision(3)} hPa";
                  } else if (name.startsWith("humidity")) {
                    name = "Humidity";
                    number = number * 1;
                    number_str = "${number.toStringAsPrecision(3)}%";
                  } else if (name.startsWith("temperature")) {
                    name = "Temperature";
                    number = number * 1;
                    number_str = "${number.toStringAsPrecision(2)} C°";
                  } else if (name.startsWith("drone-altitude")) {
                    name = "Drone Altitude";
                    number = number * 10;
                    number_str = "$number m";
                  } else if (name.startsWith("light-intensity")) {
                    name = "Light Intensity";
                    number = number * 100;
                    number_str = "$number lux";
                  } else if (name.startsWith("rover-signal-strength")) {
                    name = "Rover Signal Strength";
                    number = number * 0.1;
                    number_str = "${number.toStringAsPrecision(2)} dB";
                  } else if (name.startsWith("x-angle")) {
                    name = "X Angle";
                    number = number * 1.8;
                    number_str = "${number.toStringAsPrecision(3)}°";
                  } else if (name.startsWith("y-angle")) {
                    name = "Y Angle";
                    number = number * 1.8;
                    number_str = "${number.toStringAsPrecision(3)}°";
                  } else if (name.startsWith("compass-angle")) {
                    name = "Compass Angle";
                    number = number * 3.6;
                    number_str = "${number.toStringAsPrecision(3)}°";
                  } else if (name.startsWith("battery-voltage")) {
                    name = "Battery Voltage";
                    number = number * 0.24;
                    number_str = "${number.toStringAsPrecision(2)} V";
                  } else if (name.startsWith("power-consumption")) {
                    name = "Power Consumption";
                    number = number * 10;
                    number_str = "${number.toStringAsPrecision(2)} W";
                  } else if (name.startsWith("rover-speed")) {
                    name = "Rover Speed";
                    number = number / 100;
                    number_str = "${number.toStringAsPrecision(2)} m/s";
                  } else if (name.startsWith("CO")) {
                    name = "CO";
                    number = number * 100;
                    number_str = "${number.toStringAsFixed(1)} ppm";
                  } else if (name.startsWith("CO2")) {
                    name = "CO₂";
                    number = number * 100;
                    number_str = "${number.toStringAsFixed(1)} ppm";
                  } else if (name.startsWith("H2")) {
                    name = "H₂";
                    number = number * 100;
                    number_str = "${number.toStringAsFixed(1)} ppm";
                  } else if (name.startsWith("CH4 C4H10 C3H8")) {
                    name = "CH₄ C₄H₁₀ C₃H₈";
                    number = number * 100;
                    number_str = "${number.toStringAsFixed(1)} ppm";
                  } else if (name.startsWith("NH3 NO2 C6H6")) {
                    name = "NH₃ NO₂ C₆H₆";
                    number = number * 100;
                    number_str = "${number.toStringAsFixed(1)} ppm";
                  } else if (name.startsWith("PM1.0")) {
                    name = "PM1.0";
                    number = number * 1;
                    number_str = "${number.toStringAsFixed(1)} µg/m³";
                  } else if (name.startsWith("PM2.5")) {
                    name = "PM2.5";
                    number = number * 1;
                    number_str = "${number.toStringAsFixed(1)} µg/m³";
                  } else if (name.startsWith("PM10.0")) {
                    name = "PM10.0";
                    number = number * 1;
                    number_str = "${number.toStringAsFixed(1)} µg/m³";
                  } else if (name.startsWith("electrical-current")) {
                    name = "Electrical Current";
                    number = number * 1;
                    number_str = "${number.toStringAsFixed(1)} A";
                  } else if (name.startsWith("motors-current")) {
                    name = "Motors Current";
                    number = number * 1;
                    number_str = "${number.toStringAsFixed(1)} A";
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      '${time.hour < 10 ? "0" : ""}${time.hour}:${time.minute < 10 ? "0" : ""}${time.minute} $name $number_str',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
                tooltipSettings: InteractiveTooltip(
                    enable: true,
                    color: Colors.grey[900],
                    borderWidth: 4,
                    arrowWidth: 2,
                    arrowLength: 6
                ),
                markerSettings: const TrackballMarkerSettings(
                  markerVisibility: TrackballVisibilityMode.visible,
                  shape: DataMarkerType.diamond,
                  width: 6,
                  height: 6,
                  borderWidth: 2,
                ),
              ),
              plotAreaBorderColor: Colors.transparent,
              legend: const Legend(
                overflowMode: LegendItemOverflowMode.wrap,
                isVisible: true,
                position: LegendPosition.top,
                textStyle: TextStyle(fontSize: 16, color: Colors.white),
              ),
              primaryXAxis: DateTimeAxis(
                  isVisible: true,
                  labelStyle: const TextStyle(color: Colors.white),
                  minorGridLines: const MinorGridLines(width: 0),
                  majorGridLines: const MajorGridLines(width: 0)
              ),
              primaryYAxis: NumericAxis(
                isVisible: false,
                minimum: 0,
                maximum: 100, // note that all the data is converted to 100, but converted back when shown in the trackball
              ),
              borderWidth: 0,
              series: series,
            ),
          )
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
        item % 4 + 1, (index) => Event('Event $item | ${index + 1}')));

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
        (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year - 1, kToday.month, kToday.day);
final kLastDay = DateTime(kToday.year + 1, kToday.month, kToday.day);

class TableRange extends StatefulWidget {
  @override
  TableRangeState createState() => TableRangeState();
}

class TableRangeState extends State<TableRange> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOn; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  static DateTime? rangeStart;
  static DateTime? rangeEnd;
  static Map<DateTime, int> dayCounts = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TableCalendar(
              daysOfWeekStyle: const DaysOfWeekStyle(weekdayStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic), weekendStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
              calendarStyle: const CalendarStyle(defaultTextStyle: TextStyle(color: Colors.white), weekendTextStyle: TextStyle(color: Colors.white)),
              firstDay: kFirstDay,
              lastDay: kLastDay,
              focusedDay: _focusedDay,
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  return Column(
                    children: [
                      Text(
                        '${day.day}', // Show the day number
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      Text(
                        '${dayCounts[day] ?? 0} Records', // Show your text here
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  );
                },
              ),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              rangeStartDay: rangeStart,
              rangeEndDay: rangeEnd,
              calendarFormat: _calendarFormat,
              rangeSelectionMode: _rangeSelectionMode,
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    rangeStart = null; // Important to clean those
                    rangeEnd = null;
                    _rangeSelectionMode = RangeSelectionMode.toggledOff;
                  });
                }
              },
              onRangeSelected: (start, end, focusedDay) {
                setState(() {
                  _selectedDay = null;
                  _focusedDay = focusedDay;
                  rangeStart = start;
                  rangeEnd = end;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  style: ButtonStyle(
                    side: MaterialStateProperty.all(BorderSide(color: Theme.of(context).primaryColor).copyWith(width: 2)),
                    backgroundColor: MaterialStateProperty.resolveWith((states) {
                      if (states.isNotEmpty) {
                        if (MaterialState.hovered == states.first) {
                          return Colors.transparent;
                        }
                      }
                      return Theme.of(context).primaryColor;
                    }),
                  ),
                  child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    HistoryPageState.isConfirmed = false;
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 10),
                TextButton(
                  style: ButtonStyle(
                    side: MaterialStateProperty.all(BorderSide(color: rangeStart == null || rangeEnd == null ? Colors.grey : Theme.of(context).primaryColor).copyWith(width: 2)),
                    backgroundColor: MaterialStateProperty.resolveWith((states) {
                      if (states.isNotEmpty) {
                        if (MaterialState.hovered == states.first) {
                          return Colors.transparent;
                        }
                      }
                      return rangeStart == null || rangeEnd == null ? Colors.grey : Theme.of(context).primaryColor;
                    }),
                  ),
                  onPressed: rangeStart == null || rangeEnd == null ? null : () {
                    HistoryPageState.isConfirmed = true;
                    Navigator.pop(context);
                  },
                  child: const Text("Confirm", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
