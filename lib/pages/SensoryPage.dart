import 'package:flutter/material.dart';
import 'package:mars_nav/widgets/GraphContainer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../main.dart';

class ChartData {
  final DateTime x;
  final double y;

  ChartData(this.x, this.y);
}

class SensoryPage extends StatelessWidget {
  SensoryPage({value});

  static Widget separator = const SizedBox(width: 26);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(6, 10, 10, 10),
        child: Column(
          children: [
            Row(
              children: [
                Flexible(flex: 6, child: GraphContainer(
                  height: 390,
                  iconWidget: Image.asset("lib/icons/chemistry-white.png", height: Main.iconSize * 3, width: Main.iconSize * 3),
                  titleWidget: const Text("Gases", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  graph: SfCartesianChart(
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      builder: (data, point, series, pointIndex, seriesIndex) {
                        var data_ = (data as ChartData);
                        return Container(
                            padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: (series as SplineAreaSeries<ChartData, DateTime>).borderColor,
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
                      SplineAreaSeries<ChartData, DateTime>(
                        dataSource: <ChartData>[
                          ChartData(DateTime(2023, 1, 1), 3000),
                          ChartData(DateTime(2023, 2, 1), 5000),
                          ChartData(DateTime(2023, 3, 1), 4000),
                          ChartData(DateTime(2023, 4, 1), 7000),
                          ChartData(DateTime(2023, 5, 1), 6000),
                          ChartData(DateTime(2023, 6, 1), 8000),
                        ],
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        color: Color(0xFF00D2FF).withOpacity(0.1),
                        borderColor: Color(0xFF00D2FF),
                        borderWidth: 3,
                        name: 'H2  ${Main.MQ_8_value} ppm',
                      ),
                      SplineAreaSeries<ChartData, DateTime>(
                        dataSource: <ChartData>[
                          ChartData(DateTime(2023, 1, 1), 4050),
                          ChartData(DateTime(2023, 2, 1), 6000),
                          ChartData(DateTime(2023, 3, 1), 5000),
                          ChartData(DateTime(2023, 4, 1), 7050),
                          ChartData(DateTime(2023, 5, 1), 7000),
                          ChartData(DateTime(2023, 6, 1), 9000),
                        ],
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        color: Color(0xFFFF6B00).withOpacity(0.1),
                        borderColor: Color(0xFFFF6B00),
                        borderWidth: 3,
                        name: 'NH3, NO2, C6H6  ${Main.MQ_135_value} ppm',
                      ),
                      SplineAreaSeries<ChartData, DateTime>(
                        dataSource: <ChartData>[
                          ChartData(DateTime(2023, 1, 1), 5050),
                          ChartData(DateTime(2023, 2, 1), 7000),
                          ChartData(DateTime(2023, 3, 1), 6050),
                          ChartData(DateTime(2023, 4, 1), 8000),
                          ChartData(DateTime(2023, 5, 1), 7500),
                          ChartData(DateTime(2023, 6, 1), 9050),
                        ],
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        color: Color(0xFF00FFD4).withOpacity(0.1),
                        borderColor: Color(0xFF00FFD4),
                        borderWidth: 3,
                        name: 'CH4, C4H10, C3H8  ${Main.MQ_2_value} ppm',
                      ),
                      SplineAreaSeries<ChartData, DateTime>(
                        dataSource: <ChartData>[
                          ChartData(DateTime(2023, 1, 1), 3050),
                          ChartData(DateTime(2023, 2, 1), 5050),
                          ChartData(DateTime(2023, 3, 1), 5000),
                          ChartData(DateTime(2023, 4, 1), 6050),
                          ChartData(DateTime(2023, 5, 1), 6000),
                          ChartData(DateTime(2023, 6, 1), 150),
                        ],
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        color: Color(0xFFFFD500).withOpacity(0.1),
                        borderColor: Color(0xFFFFD500),
                        borderWidth: 3,
                        name: 'CO  ${Main.MQ_7_value} ppm',
                      ),
                    ],
                  ),
                )),
                separator,
                Flexible(flex: 4, child: GraphContainer(
                  height: 400,
                  iconWidget: Image.asset("lib/icons/chemistry-white.png", height: Main.iconSize * 3, width: Main.iconSize * 3),
                  titleWidget: const Text("Gases", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  graph: SfCartesianChart(
                    plotAreaBorderColor: Colors.transparent,
                    legend: Legend(
                      isVisible: true,
                      position: LegendPosition.left,
                      textStyle: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    primaryXAxis: DateTimeAxis(
                        isVisible: false
                    ),
                    primaryYAxis: CategoryAxis(
                      isVisible: false,
                      minimum: 100,
                      maximum: 10000,
                    ),
                    borderWidth: 0,
                    series: <SplineAreaSeries>[
                      SplineAreaSeries<ChartData, DateTime>(
                        dataSource: <ChartData>[
                          ChartData(DateTime(2023, 1, 1), 3000),
                          ChartData(DateTime(2023, 2, 1), 5000),
                          ChartData(DateTime(2023, 3, 1), 4000),
                          ChartData(DateTime(2023, 4, 1), 7000),
                          ChartData(DateTime(2023, 5, 1), 6000),
                          ChartData(DateTime(2023, 6, 1), 8000),
                        ],
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        color: Color(0xFF00D2FF).withOpacity(0.1),
                        borderColor: Color(0xFF00D2FF),
                        borderWidth: 3,
                        name: 'H2  ${Main.MQ_8_value} ppm',
                      ),
                      SplineAreaSeries<ChartData, DateTime>(
                        dataSource: <ChartData>[
                          ChartData(DateTime(2023, 1, 1), 4050),
                          ChartData(DateTime(2023, 2, 1), 6000),
                          ChartData(DateTime(2023, 3, 1), 5000),
                          ChartData(DateTime(2023, 4, 1), 7050),
                          ChartData(DateTime(2023, 5, 1), 7000),
                          ChartData(DateTime(2023, 6, 1), 9000),
                        ],
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        color: Color(0xFFFF6B00).withOpacity(0.1),
                        borderColor: Color(0xFFFF6B00),
                        borderWidth: 3,
                        name: 'NH3, NO2, C6H6  ${Main.MQ_135_value} ppm',
                      ),
                      SplineAreaSeries<ChartData, DateTime>(
                        dataSource: <ChartData>[
                          ChartData(DateTime(2023, 1, 1), 5050),
                          ChartData(DateTime(2023, 2, 1), 7000),
                          ChartData(DateTime(2023, 3, 1), 6050),
                          ChartData(DateTime(2023, 4, 1), 8000),
                          ChartData(DateTime(2023, 5, 1), 7500),
                          ChartData(DateTime(2023, 6, 1), 9050),
                        ],
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        color: Color(0xFF00FFD4).withOpacity(0.1),
                        borderColor: Color(0xFF00FFD4),
                        borderWidth: 3,
                        name: 'CH4, C4H10, C3H8  ${Main.MQ_2_value} ppm',
                      ),
                      SplineAreaSeries<ChartData, DateTime>(
                        dataSource: <ChartData>[
                          ChartData(DateTime(2023, 1, 1), 3050),
                          ChartData(DateTime(2023, 2, 1), 5050),
                          ChartData(DateTime(2023, 3, 1), 5000),
                          ChartData(DateTime(2023, 4, 1), 6050),
                          ChartData(DateTime(2023, 5, 1), 6000),
                          ChartData(DateTime(2023, 6, 1), 150),
                        ],
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        color: Color(0xFFFFD500).withOpacity(0.1),
                        borderColor: Color(0xFFFFD500),
                        borderWidth: 3,
                        name: 'CO  ${Main.MQ_7_value} ppm',
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
