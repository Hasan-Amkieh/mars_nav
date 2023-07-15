import 'package:flutter/material.dart';
import 'package:mars_nav/widgets/GraphContainer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../main.dart';

class TimeData {
  final DateTime x;
  final double y;

  TimeData(this.x, this.y);
}


class StringData {
  final String x;
  final double y;

  StringData(this.x, this.y);
}

class SensoryPage extends StatelessWidget {
  SensoryPage({value});

  static Widget separator = const SizedBox(width: 26);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 10, 10, 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(flex: 6, child: GraphContainer(
                  sizeModifier: 4.9,
                  iconWidget: Image.asset("lib/icons/chemistry-white.png", height: Main.iconSize * 3, width: Main.iconSize * 3),
                  titleWidget: const Text("Gases", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  graph: SfCartesianChart(
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      builder: (data, point, series, pointIndex, seriesIndex) {
                        var data_ = (data as TimeData);
                        return Container(
                            padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: (series as SplineAreaSeries<TimeData, DateTime>).borderColor,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                      "${data_.x.hour}:${data_.x.minute}:${data_.x.second} , ${data_.y}", style: const TextStyle(color: Colors.white)
                                  )
                                ]
                            )
                        );
                      },
                    ),
                    plotAreaBorderColor: Colors.transparent,
                    legend: const Legend(
                      overflowMode: LegendItemOverflowMode.wrap,
                      isVisible: true,
                      position: LegendPosition.left,
                      textStyle: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    primaryXAxis: DateTimeAxis(
                        isVisible: false,
                    ),
                    primaryYAxis: NumericAxis(
                      // axisLabelFormatter: (axisLabelRenderArgs) {
                      //   print(axisLabelRenderArgs.text);
                      //   return ChartAxisLabel(axisLabelRenderArgs.text, TextStyle(color: Colors.white));
                      // },
                      isVisible: false,
                      minimum: 100,
                      maximum: 10000,
                    ),
                    borderWidth: 0,
                    series: <SplineAreaSeries>[
                      SplineAreaSeries<TimeData, DateTime>(
                        markerSettings: MarkerSettings(isVisible: true),
                        dataSource: <TimeData>[
                          TimeData(DateTime(2023, 1, 1), 3000),
                          TimeData(DateTime(2023, 2, 1), 5000),
                          TimeData(DateTime(2023, 3, 1), 4000),
                          TimeData(DateTime(2023, 4, 1), 7000),
                          TimeData(DateTime(2023, 5, 1), 6000),
                          TimeData(DateTime(2023, 6, 1), 8000),
                        ],
                        xValueMapper: (TimeData data, _) => data.x,
                        yValueMapper: (TimeData data, _) => data.y,
                        color: const Color(0xFF00D2FF).withOpacity(0.1),
                        borderColor: const Color(0xFF00D2FF),
                        borderWidth: 3,
                        name: 'H2  ${Main.MQ_8_value} ppm',
                      ),
                      SplineAreaSeries<TimeData, DateTime>(
                        markerSettings: MarkerSettings(isVisible: true),
                        dataSource: <TimeData>[
                          TimeData(DateTime(2023, 1, 1), 4050),
                          TimeData(DateTime(2023, 2, 1), 6000),
                          TimeData(DateTime(2023, 3, 1), 5000),
                          TimeData(DateTime(2023, 4, 1), 7050),
                          TimeData(DateTime(2023, 5, 1), 7000),
                          TimeData(DateTime(2023, 6, 1), 9000),
                        ],
                        xValueMapper: (TimeData data, _) => data.x,
                        yValueMapper: (TimeData data, _) => data.y,
                        color: const Color(0xFFFF6B00).withOpacity(0.1),
                        borderColor: const Color(0xFFFF6B00),
                        borderWidth: 3,
                        name: 'NH3, NO2, C6H6  ${Main.MQ_135_value} ppm',
                      ),
                      SplineAreaSeries<TimeData, DateTime>(
                        markerSettings: MarkerSettings(isVisible: true),
                        dataSource: <TimeData>[
                          TimeData(DateTime(2023, 1, 1), 5050),
                          TimeData(DateTime(2023, 2, 1), 7000),
                          TimeData(DateTime(2023, 3, 1), 6050),
                          TimeData(DateTime(2023, 4, 1), 8000),
                          TimeData(DateTime(2023, 5, 1), 7500),
                          TimeData(DateTime(2023, 6, 1), 9050),
                        ],
                        xValueMapper: (TimeData data, _) => data.x,
                        yValueMapper: (TimeData data, _) => data.y,
                        color: const Color(0xFF00FFD4).withOpacity(0.1),
                        borderColor: const Color(0xFF00FFD4),
                        borderWidth: 3,
                        name: 'CH4, C4H10, C3H8  ${Main.MQ_2_value} ppm',
                      ),
                      SplineAreaSeries<TimeData, DateTime>(
                        markerSettings: MarkerSettings(isVisible: true),
                        dataSource: <TimeData>[
                          TimeData(DateTime(2023, 1, 1), 3050),
                          TimeData(DateTime(2023, 2, 1), 5050),
                          TimeData(DateTime(2023, 3, 1), 5000),
                          TimeData(DateTime(2023, 4, 1), 6050),
                          TimeData(DateTime(2023, 5, 1), 6000),
                          TimeData(DateTime(2023, 6, 1), 150),
                        ],
                        xValueMapper: (TimeData data, _) => data.x,
                        yValueMapper: (TimeData data, _) => data.y,
                        color: const Color(0xFFFFD500).withOpacity(0.1),
                        borderColor: const Color(0xFFFFD500),
                        borderWidth: 3,
                        name: 'CO  ${Main.MQ_7_value} ppm',
                      ),
                    ],
                  ),
                )),
                separator,
                Flexible(flex: 4, child: GraphContainer(
                  sizeModifier: 2.2,
                  iconWidget: Image.asset("lib/icons/wind-white.png", height: Main.iconSize * 2, width: Main.iconSize * 2),
                  titleWidget: const Text("Air", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  graph: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset("lib/icons/water-blue.png", height: Main.iconSize * 1 , width: Main.iconSize * 1),
                              const SizedBox(width: 10,),
                              Text("Humiditiy ${Main.humidity}%", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Image.asset("lib/icons/temperature-red.png", height: Main.iconSize * 1, width: Main.iconSize * 1),
                              const SizedBox(width: 10,),
                              Text("Temperature ${Main.temperature} C", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Image.asset("lib/icons/air-pressure-green.png", height: Main.iconSize * 1, width: Main.iconSize * 1),
                              const SizedBox(width: 10,),
                              Text("Air Pressure ${Main.airPressure} millibar", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SfCircularChart(
                              series: <CircularSeries>[
                                RadialBarSeries<StringData, String>(
                                  radius: "95",
                                  innerRadius: "85",
                                  maximumValue: 100,
                                  animationDuration: 400,
                                  dataSource: <StringData>[
                                    StringData('Humidity', Main.humidity),
                                  ],
                                  cornerStyle: CornerStyle.endCurve,
                                  xValueMapper: (StringData data, _) => data.x,
                                  yValueMapper: (StringData data, _) => data.y,
                                  trackColor: Colors.blue,
                                  trackOpacity: 0.3,
                                  pointColorMapper: (StringData data, _) => Colors.blue,
                                ),
                              ]
                          ),
                          SfCircularChart(
                              series: <CircularSeries>[
                                RadialBarSeries<StringData, String>(
                                  radius: "105",
                                  innerRadius: "95",
                                  maximumValue: 100,
                                  animationDuration: 400,
                                  dataSource: <StringData>[
                                    StringData('Temperature', Main.temperature),
                                  ],
                                  cornerStyle: CornerStyle.endCurve,
                                  xValueMapper: (StringData data, _) => data.x,
                                  yValueMapper: (StringData data, _) => data.y,
                                  trackColor: Colors.red,
                                  trackOpacity: 0.3,
                                  pointColorMapper: (StringData data, _) => Colors.red,
                                ),
                              ]
                          ),
                          SfCircularChart(
                              series: <CircularSeries>[
                                RadialBarSeries<StringData, String>(
                                  radius: "115",
                                  innerRadius: "105",
                                  maximumValue: 100,
                                  animationDuration: 400,
                                  dataSource: <StringData>[
                                    StringData('Air Pressure', Main.airPressure),
                                  ],
                                  cornerStyle: CornerStyle.endCurve,
                                  xValueMapper: (StringData data, _) => data.x,
                                  yValueMapper: (StringData data, _) => data.y,
                                  trackColor: Colors.green,
                                  trackOpacity: 0.3,
                                  pointColorMapper: (StringData data, _) => Colors.green,
                                ),
                              ]
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
