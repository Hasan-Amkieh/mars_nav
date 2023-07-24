import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:mars_nav/widgets/AngleGauge.dart';
import 'package:mars_nav/widgets/GraphContainer.dart';
import 'package:win32/win32.dart';

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

class SensoryPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {

    return SensoryPageState();
  }

}

class SensoryPageState extends State<SensoryPage> {
  SensoryPageState();

  static TextStyle graphContainerStyle = const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20);

  static Widget separator = const SizedBox(width: 26);

  @override
  void initState() {
    super.initState();
  }

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
                  sizeModifier: 4.0,
                  detailsWidget: IconButton(
                    icon: Image.asset("lib/icons/data-blue.png",  width: Main.iconSize * 1.5, height: Main.iconSize * 1.5),
                    onPressed: () {},
                  ),
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
                      isVisible: false,
                      minimum: 100,
                      maximum: 10000,
                    ),
                    borderWidth: 0,
                    series: <SplineAreaSeries>[
                      SplineAreaSeries<TimeData, DateTime>(
                        markerSettings: const MarkerSettings(isVisible: true),
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
                        name: 'H₂  ${Main.MQ_8_value} ppm',
                      ),
                      SplineAreaSeries<TimeData, DateTime>(
                        markerSettings: const MarkerSettings(isVisible: true),
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
                        name: 'NH₃, NO₂, C₆H₆  ${Main.MQ_135_value} ppm',
                      ),
                      SplineAreaSeries<TimeData, DateTime>(
                        markerSettings: const MarkerSettings(isVisible: true),
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
                        name: 'CH₄, C₄H₁₀, C₃H₈  ${Main.MQ_2_value} ppm',
                      ),
                      SplineAreaSeries<TimeData, DateTime>(
                        markerSettings: const MarkerSettings(isVisible: true),
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
                      SplineAreaSeries<TimeData, DateTime>(
                        markerSettings: const MarkerSettings(isVisible: true),
                        dataSource: <TimeData>[
                          TimeData(DateTime(2023, 1, 1), 1050),
                          TimeData(DateTime(2023, 2, 1), 2050),
                          TimeData(DateTime(2023, 3, 1), 9000),
                          TimeData(DateTime(2023, 4, 1), 5850),
                          TimeData(DateTime(2023, 5, 1), 1000),
                          TimeData(DateTime(2023, 6, 1), 1590),
                        ],
                        xValueMapper: (TimeData data, _) => data.x,
                        yValueMapper: (TimeData data, _) => data.y,
                        color: const Color(0xFFB19CD9).withOpacity(0.1),
                        borderColor: const Color(0xFFB19CD9),
                        borderWidth: 3,
                        name: 'CO₂  ${Main.CO2_value} ppm',
                      ),
                    ],
                  ),
                )),
                separator,
                Flexible(flex: 4, child: GraphContainer(
                  sizeModifier: 2.2,
                  detailsWidget: IconButton(
                    icon: Image.asset("lib/icons/data-blue.png",  width: Main.iconSize * 1.5, height: Main.iconSize * 1.5),
                    onPressed: () {},
                  ),
                  iconWidget: Image.asset("lib/icons/wind-white.png", height: Main.iconSize * 2, width: Main.iconSize * 2),
                  titleWidget: Text("Atmosphere", style: graphContainerStyle),
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
                              Text("Humiditiy ${Main.humidity}%", style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Image.asset("lib/icons/temperature-red.png", height: Main.iconSize * 1, width: Main.iconSize * 1),
                              const SizedBox(width: 10,),
                              Text("Temperature ${Main.temperature} C", style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Image.asset("lib/icons/air-pressure-green.png", height: Main.iconSize * 1, width: Main.iconSize * 1),
                              const SizedBox(width: 10,),
                              Text("Air Pressure ${Main.airPressure} millibar", style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                      FittedBox(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SfCircularChart(
                                margin: EdgeInsets.zero,
                                series: <CircularSeries>[
                                  RadialBarSeries<StringData, String>(
                                    radius: (MediaQuery.of(context).size.height * 0.055).toInt().toString(),
                                    innerRadius: (MediaQuery.of(context).size.height * 0.042).toInt().toString(),
                                    maximumValue: 100,
                                    animationDuration: 800,
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
                                margin: EdgeInsets.zero,
                                series: <CircularSeries>[
                                  RadialBarSeries<StringData, String>(
                                    radius: (MediaQuery.of(context).size.height * 0.075).toInt().toString(),
                                    innerRadius: (MediaQuery.of(context).size.height * 0.062).toInt().toString(),
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
                                margin: EdgeInsets.zero,
                                series: <CircularSeries>[
                                  RadialBarSeries<StringData, String>(
                                    radius: (MediaQuery.of(context).size.height * 0.095).toInt().toString(),
                                    innerRadius: (MediaQuery.of(context).size.height * 0.082).toInt().toString(),
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
                      ),
                    ],
                  ),
                )),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(flex:3, child: GraphContainer(
                  detailsWidget: IconButton(
                    icon: Image.asset("lib/icons/data-blue.png",  width: Main.iconSize * 1.5, height: Main.iconSize * 1.5),
                    onPressed: () {},
                  ),
                  sizeModifier: 1.5,
                  titleWidget: Text("Speed", style: graphContainerStyle),
                  iconWidget: Image.asset("lib/icons/speed-white.png", width: Main.iconSize * 2, height: Main.iconSize * 2),
                  graph: Column(
                    children: [
                      const SizedBox(height: 12,),
                      Expanded(
                        child: AnimatedRadialGauge(
                          duration: const Duration(seconds: 2),
                          curve: Curves.elasticOut,
                          value: Main.speed,
                          axis: GaugeAxis(
                            min: 0,
                            max: 1,
                            degrees: 160,
                            pointer: const GaugePointer.needle(
                              width: 16,
                              height: 120,
                              borderRadius: 16,
                              color: Colors.black45,
                            ),
                            progressBar: GaugeProgressBar.rounded(
                              color: (Main.signalStrengthRover + 90) < 20 ? Colors.redAccent : ((Main.signalStrengthRover + 90) < 40 ? Colors.yellowAccent : Colors.green),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      Text(
                          "${Main.speed} m/s",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))
                    ],
                  ),
                )
                ),
                separator,
                Flexible(flex:3, child: GraphContainer(
                  detailsWidget: IconButton(
                    icon: Image.asset("lib/icons/data-blue.png",  width: Main.iconSize * 1.5, height: Main.iconSize * 1.5),
                    onPressed: () {},
                  ),
                  sizeModifier: 1.0,
                  titleWidget: Text("Rover Angles", style: graphContainerStyle),
                  iconWidget: Image.asset("lib/icons/angles-white.png", width: Main.iconSize * 2, height: Main.iconSize * 2),
                  graph: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AngleGauge(angle: Main.xAngle, color: const Color(0xFF00E676), thickness: 10, height: 250),
                          Text("X-Axis\n${Main.xAngle}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(width: 60),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AngleGauge(angle: Main.yAngle, color: const Color(0xFFFFD54F), thickness: 10, height: 250),
                          Text("Y-Axis\n${Main.yAngle}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(width: 60),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AngleGauge(angle: Main.zAngle, color: const Color(0xFF42A5F5), thickness: 10, height: 250),
                          Text("Z-Axis\n${Main.zAngle}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                )),
                separator,
                Flexible(flex:4, child: GraphContainer(
                  detailsWidget: IconButton(
                    icon: Image.asset("lib/icons/data-blue.png",  width: Main.iconSize * 1.5, height: Main.iconSize * 1.5),
                    onPressed: () {},
                  ),
                  sizeModifier: 1.9,
                  titleWidget: Text("Air Particles", style: graphContainerStyle),
                  iconWidget: Image.asset("lib/icons/particles-white.png", width: Main.iconSize * 2, height: Main.iconSize * 2),
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
                      isVisible: false,
                      minimum: 0,
                      maximum: 1000,
                    ),
                    borderWidth: 0,
                    series: <SplineAreaSeries>[
                      SplineAreaSeries<TimeData, DateTime>(
                        markerSettings: const MarkerSettings(isVisible: true),
                        dataSource: <TimeData>[
                          TimeData(DateTime(2023, 1, 1), 405),
                          TimeData(DateTime(2023, 2, 1), 600),
                          TimeData(DateTime(2023, 3, 1), 500),
                          TimeData(DateTime(2023, 4, 1), 750),
                          TimeData(DateTime(2023, 5, 1), 700),
                          TimeData(DateTime(2023, 6, 1), 960),
                        ],
                        xValueMapper: (TimeData data, _) => data.x,
                        yValueMapper: (TimeData data, _) => data.y,
                        color: const Color(0xFFFF6B00).withOpacity(0.1),
                        borderColor: const Color(0xFFFF6B00),
                        borderWidth: 3,
                        name: 'PM1.0  ${Main.PM1_0_concentration} µg/m³',
                      ),
                      SplineAreaSeries<TimeData, DateTime>(
                        markerSettings: const MarkerSettings(isVisible: true),
                        dataSource: <TimeData>[
                          TimeData(DateTime(2023, 1, 1), 550),
                          TimeData(DateTime(2023, 2, 1), 700),
                          TimeData(DateTime(2023, 3, 1), 650),
                          TimeData(DateTime(2023, 4, 1), 800),
                          TimeData(DateTime(2023, 5, 1), 700),
                          TimeData(DateTime(2023, 6, 1), 905),
                        ],
                        xValueMapper: (TimeData data, _) => data.x,
                        yValueMapper: (TimeData data, _) => data.y,
                        color: const Color(0xFF00FFD4).withOpacity(0.1),
                        borderColor: const Color(0xFF00FFD4),
                        borderWidth: 3,
                        name: 'PM2.5 ${Main.PM2_5_concentration} µg/m³',
                      ),
                      SplineAreaSeries<TimeData, DateTime>(
                        markerSettings: const MarkerSettings(isVisible: true),
                        dataSource: <TimeData>[
                          TimeData(DateTime(2023, 1, 1), 350),
                          TimeData(DateTime(2023, 2, 1), 550),
                          TimeData(DateTime(2023, 3, 1), 500),
                          TimeData(DateTime(2023, 4, 1), 650),
                          TimeData(DateTime(2023, 5, 1), 600),
                          TimeData(DateTime(2023, 6, 1), 150),
                        ],
                        xValueMapper: (TimeData data, _) => data.x,
                        yValueMapper: (TimeData data, _) => data.y,
                        color: const Color(0xFFFFD500).withOpacity(0.1),
                        borderColor: const Color(0xFFFFD500),
                        borderWidth: 3,
                        name: 'PM10.0  ${Main.PM10_0_concentration} µg/m³',
                      ),
                    ],
                  ),
                )),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 3,
                  child: GraphContainer(
                    detailsWidget: IconButton(
                      icon: Image.asset("lib/icons/data-blue.png",  width: Main.iconSize * 1.5, height: Main.iconSize * 1.5),
                      onPressed: () async {
                        int x = ShellExecute(0, 'open'.toNativeUtf16(),
                            'mars_nav.exe'.toNativeUtf16(), r'video_player C:\Users\HasanAmk\Downloads\x\1.mp4'.toNativeUtf16(),
                            'C:\\Users\\HasanAmk\\Documents\\Projects\\Flutter_Projects\\mars_nav\\build\\windows\\runner\\Debug\\'.toNativeUtf16(), SW_SHOW);
                        print("exit code: $x");
                      },
                    ),
                    iconWidget: Image.asset("lib/icons/circuitry-white.png", width: Main.iconSize * 2, height: Main.iconSize * 2),
                    titleWidget: Text("Computing Resources", style: graphContainerStyle),
                    sizeModifier: 1.2,
                    graph: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: SfCartesianChart(
                        trackballBehavior: TrackballBehavior(
                          enable: true,
                          lineType: TrackballLineType.vertical,
                          activationMode: ActivationMode.singleTap,
                          builder: (context, trackballDetails) {
                            double number = trackballDetails.series?.dataSource[trackballDetails.pointIndex ?? 0].y;
                            String number_str = "";
                            String name = trackballDetails.series?.name ?? "ERROR";
                            if (name.startsWith("CPU")) {
                              name = "CPU";
                              number = number * 100;
                              number_str = "${number.toStringAsPrecision(3)}%";
                            } else if (name.startsWith("GPU")) {
                              name = "GPU";
                              number = number * 100;
                              number_str = "${number.toStringAsPrecision(3)}%";
                            } else if (name.contains("RAM")) {
                              name = "RAM";
                              number = number * 4;
                              number_str = "${number.toStringAsPrecision(3)} GB";
                            }

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: const EdgeInsets.all(6),
                              child: Text(
                                '$name $number_str',
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
                        primaryXAxis: DateTimeAxis(
                          isVisible: false,
                        ),
                        plotAreaBorderWidth: 0,
                        legend: const Legend(
                          isVisible: true,
                          position: LegendPosition.bottom,
                          textStyle: TextStyle(color: Colors.white, fontSize: 16),
                          overflowMode: LegendItemOverflowMode.wrap
                        ),
                        primaryYAxis: NumericAxis(
                        isVisible: false,
                        minimum: 0,
                        maximum: 1,
                        ),
                        series: <ChartSeries>[
                          StepLineSeries<TimeData, DateTime>(
                            dataSource: [
                              TimeData(DateTime(2001, 1, 1), 0.19),
                              TimeData(DateTime(2001, 1, 2), 0.1),
                              TimeData(DateTime(2001, 1, 3), 0.659),
                              TimeData(DateTime(2001, 1, 4), 0.57),
                              TimeData(DateTime(2001, 1, 5), 0.96),
                            ],
                            xValueMapper: (TimeData data, _) => data.x,
                            yValueMapper: (TimeData data, _) => data.y,
                            name: 'CPU Utilization ${Main.cpuUtil * 100}%',
                            color: const Color(0xFF4b87b9),
                          ),
                          StepLineSeries<TimeData, DateTime>(
                            dataSource: [
                              TimeData(DateTime(2001, 1, 1), 0.1),
                              TimeData(DateTime(2001, 1, 2), 0.4),
                              TimeData(DateTime(2001, 1, 3), 0.3),
                              TimeData(DateTime(2001, 1, 4), 0.23),
                              TimeData(DateTime(2001, 1, 5), 0.13),
                            ],
                            xValueMapper: (TimeData data, _) => data.x,
                            yValueMapper: (TimeData data, _) => data.y,
                            name: 'GPU Utilization ${Main.gpuUtil * 100}%',
                            color: const Color(0xFF8a596d),
                          ),
                          StepLineSeries<TimeData, DateTime>(
                            dataSource: [
                              TimeData(DateTime(2001, 1, 1), 0.5),
                              TimeData(DateTime(2001, 1, 2), 0.6),
                              TimeData(DateTime(2001, 1, 3), 0.4),
                              TimeData(DateTime(2001, 1, 4), 0.3),
                              TimeData(DateTime(2001, 1, 5), 0.1),
                            ],
                            xValueMapper: (TimeData data, _) => data.x,
                            yValueMapper: (TimeData data, _) => data.y,
                            name: 'Used RAM ${Main.usedRam} GB',
                            color: const Color(0xFFf67280),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                separator,
                Flexible(
                  flex: 4,
                  child: GraphContainer(
                    iconWidget: Image.asset("lib/icons/bolts-white.png", width: Main.iconSize * 1.5, height: Main.iconSize * 1.5),
                    titleWidget: Text("Power Consumption", style: graphContainerStyle),
                    detailsWidget: IconButton(
                      icon: Image.asset("lib/icons/data-blue.png",  width: Main.iconSize * 1.5, height: Main.iconSize * 1.5),
                      onPressed: () {},
                    ),
                    sizeModifier: 1.4,
                    graph: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: SfCartesianChart(
                        trackballBehavior: TrackballBehavior(
                          enable: true,
                          lineType: TrackballLineType.vertical,
                          activationMode: ActivationMode.singleTap,
                          builder: (context, trackballDetails) {
                            double number = trackballDetails.series?.dataSource[trackballDetails.pointIndex ?? 0].y;
                            String number_str = "";
                            String name = trackballDetails.series?.name ?? "ERROR";
                            switch (trackballDetails.seriesIndex) {
                              case 0:
                                name = "batt volt";
                                number = number * 26;
                                number_str = "${number.toStringAsPrecision(3)} V";
                                break;
                              case 1:
                                name = "motors";
                                number = number * 150;
                                number_str = "${number.toStringAsPrecision(3)} A";
                                break;
                              case 2:
                                name = "electronics";
                                number = number * 5;
                                number_str = "${number.toStringAsPrecision(3)} A";
                                break;
                              case 3:
                                name = "power";
                                number = number * 600;
                                number_str = "${number.toStringAsPrecision(3)} W";
                                break;
                            }

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: const EdgeInsets.all(6),
                              child: Text(
                                '$name $number_str',
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
                        primaryXAxis: DateTimeAxis(
                          isVisible: false,
                        ),
                        plotAreaBorderWidth: 0,
                        legend: const Legend(
                            isVisible: true,
                            position: LegendPosition.bottom,
                            textStyle: TextStyle(color: Colors.white, fontSize: 16),
                            overflowMode: LegendItemOverflowMode.wrap
                        ),
                        primaryYAxis: NumericAxis(
                          isVisible: false,
                          minimum: 0,
                          maximum: 1,
                        ),
                        series: <ChartSeries>[
                          StepLineSeries<TimeData, DateTime>(
                            dataSource: [
                              TimeData(DateTime(2001, 1, 1), 0.19),
                              TimeData(DateTime(2001, 1, 2), 0.1),
                              TimeData(DateTime(2001, 1, 3), 0.659),
                              TimeData(DateTime(2001, 1, 4), 0.57),
                              TimeData(DateTime(2001, 1, 5), 0.96),
                            ],
                            xValueMapper: (TimeData data, _) => data.x,
                            yValueMapper: (TimeData data, _) => data.y,
                            name: 'Battery Voltage ${Main.batteryVoltRover} V',
                            color: const Color(0xFF7EB8DA),
                          ),
                          StepLineSeries<TimeData, DateTime>(
                            dataSource: [
                              TimeData(DateTime(2001, 1, 1), 0.1),
                              TimeData(DateTime(2001, 1, 2), 0.4),
                              TimeData(DateTime(2001, 1, 3), 0.3),
                              TimeData(DateTime(2001, 1, 4), 0.23),
                              TimeData(DateTime(2001, 1, 5), 0.13),
                            ],
                            xValueMapper: (TimeData data, _) => data.x,
                            yValueMapper: (TimeData data, _) => data.y,
                            name: 'Motors Current ${Main.motorsCurrent} A',
                            color: const Color(0xFFAEC8E5),
                          ),
                          StepLineSeries<TimeData, DateTime>(
                            dataSource: [
                              TimeData(DateTime(2001, 1, 1), 0.5),
                              TimeData(DateTime(2001, 1, 2), 0.6),
                              TimeData(DateTime(2001, 1, 3), 0.4),
                              TimeData(DateTime(2001, 1, 4), 0.3),
                              TimeData(DateTime(2001, 1, 5), 0.1),
                            ],
                            xValueMapper: (TimeData data, _) => data.x,
                            yValueMapper: (TimeData data, _) => data.y,
                            name: 'Electronics Current ${Main.electronicsCurrent} A',
                            color: const Color(0xFF85CCB0),
                          ),
                          StepLineSeries<TimeData, DateTime>(
                            dataSource: [
                              TimeData(DateTime(2001, 1, 1), 0.48),
                              TimeData(DateTime(2001, 1, 2), 0.25),
                              TimeData(DateTime(2001, 1, 3), 0.49),
                              TimeData(DateTime(2001, 1, 4), 0.15),
                              TimeData(DateTime(2001, 1, 5), 0.756),
                            ],
                            xValueMapper: (TimeData data, _) => data.x,
                            yValueMapper: (TimeData data, _) => data.y,
                            name: 'Power Consumption ${Main.powerConsumption} W',
                            color: const Color(0xFFECA26D),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                separator,
                Flexible(
                  flex: 3,
                  child: GraphContainer(
                    iconWidget: Image.asset("lib/icons/signal-white.png", width: Main.iconSize * 1.5, height: Main.iconSize * 1.5),
                    titleWidget: Text("Signal Strength", style: graphContainerStyle),
                    detailsWidget: IconButton(
                      icon: Image.asset("lib/icons/data-blue.png",  width: Main.iconSize * 1.5, height: Main.iconSize * 1.5),
                      onPressed: () {},
                    ),
                    sizeModifier: 2.0,
                    graph: Column(
                      children: [
                        const SizedBox(height: 12,),
                        Expanded(
                          child: AnimatedRadialGauge(
                            duration: const Duration(seconds: 1),
                            curve: Curves.elasticOut,
                            value: Main.signalStrengthRover + 90,
                            axis: GaugeAxis(
                                min: 0,
                                max: 60,
                                degrees: 180,
                              pointer: const GaugePointer.needle(
                                width: 16,
                                height: 80,
                                borderRadius: 16,
                                color: Colors.black45,
                              ),
                                progressBar: GaugeProgressBar.rounded(
                                  color: (Main.signalStrengthRover + 90) < 20 ? Colors.redAccent : ((Main.signalStrengthRover + 90) < 40 ? Colors.yellowAccent : Colors.green),
                                ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: Main.iconSize,
                              height: Main.iconSize,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: (Main.signalStrengthRover + 90) < 20 ? Colors.redAccent : ((Main.signalStrengthRover + 90) < 40 ? Colors.yellowAccent : Colors.green).withOpacity(0.36),
                                    blurRadius: 30,
                                  )
                                ],
                                shape: BoxShape.circle,
                                color: (Main.signalStrengthRover + 90) < 20 ? Colors.redAccent : ((Main.signalStrengthRover + 90) < 40 ? Colors.yellowAccent : Colors.green),
                              ),
                            ),
                            const SizedBox(width: 6,),
                            Text(
                                "${(Main.signalStrengthRover + 90) < 20 ? "Weak" : ((Main.signalStrengthRover + 90) < 40 ? "Good" : "Strong")}  ${Main.signalStrengthRover} dB",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))
                          ],
                        ),
                      ],
                    ),
                ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 3,
                  child: GraphContainer(
                    detailsWidget: IconButton(
                      icon: Image.asset("lib/icons/data-blue.png",  width: Main.iconSize * 1.5, height: Main.iconSize * 1.5),
                      onPressed: () {},
                    ),
                    iconWidget: Image.asset("lib/icons/light-white.png", width: Main.iconSize * 2, height: Main.iconSize * 2),
                    titleWidget: Text("Light", style: graphContainerStyle),
                    sizeModifier: 1.0,
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
                                        color: (series as SplineSeries<TimeData, DateTime>).color,
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
                        position: LegendPosition.bottom,
                        textStyle: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      primaryXAxis: DateTimeAxis(
                        isVisible: false,
                      ),
                      primaryYAxis: NumericAxis(
                        isVisible: false,
                        minimum: 0,
                        maximum: 1000,
                      ),
                      borderWidth: 0,
                      series: <SplineSeries>[
                        SplineSeries<TimeData, DateTime>(
                          markerSettings: const MarkerSettings(isVisible: true),
                          dataSource: <TimeData>[
                            TimeData(DateTime(2023, 1, 1), 405),
                            TimeData(DateTime(2023, 2, 1), 600),
                            TimeData(DateTime(2023, 3, 1), 500),
                            TimeData(DateTime(2023, 4, 1), 750),
                            TimeData(DateTime(2023, 5, 1), 700),
                            TimeData(DateTime(2023, 6, 1), 960),
                          ],
                          xValueMapper: (TimeData data, _) => data.x,
                          yValueMapper: (TimeData data, _) => data.y,
                          color: const Color(0xFF7EB8DA),
                          // borderColor: const Color(0xFF7EB8DA),
                          // borderWidth: 3,
                          name: 'Visible Light Intensity  ${Main.visibleLightIntensity} lux',
                        ),
                        SplineSeries<TimeData, DateTime>(
                          markerSettings: const MarkerSettings(isVisible: true),
                          dataSource: <TimeData>[
                            TimeData(DateTime(2023, 1, 1), 550),
                            TimeData(DateTime(2023, 2, 1), 700),
                            TimeData(DateTime(2023, 3, 1), 650),
                            TimeData(DateTime(2023, 4, 1), 800),
                            TimeData(DateTime(2023, 5, 1), 700),
                            TimeData(DateTime(2023, 6, 1), 905),
                          ],
                          xValueMapper: (TimeData data, _) => data.x,
                          yValueMapper: (TimeData data, _) => data.y,
                          color: const Color(0xFF85CCB0),
                          // borderColor: const Color(0xFF85CCB0),
                          // borderWidth: 3,
                          name: 'UV Light Intensity ${Main.UVLightIntensity}',
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  flex: 7,
                  child: Visibility(
                    visible: false,
                    child: GraphContainer(
                      detailsWidget: IconButton(
                        icon: Image.asset("lib/icons/data-blue.png",  width: Main.iconSize * 1.5, height: Main.iconSize * 1.5),
                        onPressed: () {},
                      ),
                      iconWidget: Image.asset("lib/icons/light-white.png", width: Main.iconSize * 2, height: Main.iconSize * 2),
                      titleWidget: Text("Light", style: graphContainerStyle),
                      sizeModifier: 1.0,
                      graph: Container(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

