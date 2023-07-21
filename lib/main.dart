import 'package:flutter/material.dart';
import 'package:flutter_meedu_videoplayer/init_meedu_player.dart';
import 'package:mars_nav/pages/CommandsPage.dart';
import 'package:mars_nav/pages/HistoryPage.dart';
import 'package:mars_nav/pages/ImageryPage.dart';
import 'package:mars_nav/pages/SensoryPage.dart';
import 'package:mars_nav/pages/SettignsPage.dart';
import 'package:mars_nav/pages/ShellPage.dart';
import 'package:mars_nav/widgets/BatteryIcon.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:convert';

import 'dart:math' as math;

enum RoverState {
  offline("OFFLINE", Colors.blueGrey), standard("STANDARD MODE", Colors.green), autonomous("AUTONOMOUS MODE", Colors.yellow), halt("HALTED", Colors.red);
  const RoverState(this.description, this.color);
  final String description;
  final Color color;
}


class Main { // This class holds all the general variables to the interface as a whole

  static RoverState roverStatus = RoverState.standard; // holds the state of the rover
  static const double iconSize = 20.0;
  static const pageIndexToName = ["Sensory", "Imagery", "History", "Commands", "Command Shell", "Settings"];

  // Battery in Rover:
  static double batteryLevel = 95;
  static bool isRoverCharging = false;
  static double batteryVoltRover = 0.0; // out of 26V (6 cells)
  static double electronicsCurrent = 2.0; // out of 5A
  static double motorsCurrent = 70.0; // out of 150A
  static double powerConsumption = 550; // out of 600W, Can't be calculated from the interface, has to be sent from the rover
  static String roverBatteryRemainingTime = "1h 3m";

  // atmosphere in Drone (used for both drone and rover):
  static bool BME280Online = true;
  static double humidity = 10;
  static double temperature = 90;
  static double airPressure = 50;

  // IMU sensor in Rover: 0 - 180 degrees
  static bool IMUOnline = false; // TODO: Test it:
  static double xAngle = 155;
  static double yAngle = 20;
  static double zAngle = 69;
  static double speed = 0.4; // in m/s

  // gas sensors: 100 ppm - 10000 ppm
  static bool MQ_2_online = true;
  static bool MQ_7_online = true;
  static bool MQ_8_online = true;
  static bool MQ_135_online = true;
  static double MQ_8_value = 1000;
  static double MQ_135_value = 700;
  static double MQ_2_value = 2000;
  static double MQ_7_value = 9600;

  // particles sensor:
  static bool PMS5003Online = true;
  static double PM1_0_concentration = 100;
  static double PM2_5_concentration = 10;
  static double PM10_0_concentration = 50;

  // main Processor properties:
  static double cpuUtil = 0.9;
  static double gpuUtil = 0.85;
  static double usedRam = 3.6;

  // Battery Related Drone:
  static double batteryVoltDrone = 0.0;
  static bool isDroneCharging = true;

  // signal Strength of Communication
  static double signalStrengthRover = -45; // -30 (strongest) - -90 dB (weakest) (+90 for both values to make it positive for the graph)

  // Light sensors:
  static double UVLightIntensity = 120; // TODO: the range is to be determined with the unit
  static double visibleLightIntensity = 10020; // b/w 0 and 40,000 lux

  // C++ Code:
  static late DynamicLibrary nativeApiLib;

  static late Function initSerialPort;
  static late Function readSerialPort;
  static late Function delArray;
  static late Function closeSerialPort;
  static late Function maximizeWindow;

}

final class CArray extends Struct {
  external Pointer<Utf8> arr;
  @Int32()
  external int len;
}

void main() {

  Main.nativeApiLib = DynamicLibrary.open('api.dll');
  Main.initSerialPort = Main.nativeApiLib.lookup<NativeFunction<Int Function(Pointer<Int8>)>>('initSerial').asFunction<int Function(Pointer<Int8>)>();
  Main.readSerialPort = Main.nativeApiLib.lookup<NativeFunction<Pointer<CArray> Function(Int, Int, Int)>>('readSerialPort').asFunction<Pointer<CArray> Function(int, int, int)>();
  Main.delArray = Main.nativeApiLib.lookup<NativeFunction<Void Function(Pointer<CArray>)>>('delArray').asFunction<void Function(Pointer<CArray>)>();
  Main.closeSerialPort = Main.nativeApiLib.lookup<NativeFunction<Void Function(Int)>>('closeSerialPort').asFunction<void Function(int)>();
  Main.maximizeWindow = Main.nativeApiLib.lookup<NativeFunction<Void Function(Pointer<Utf8>)>>('maximizeWindow').asFunction<void Function(Pointer<Utf8>)>();

  const portName = "COM6";
  final Pointer<Int8> nativeString = calloc<Int8>(portName.length + 1);
  final nativeStringArray = nativeString.asTypedList(portName.length + 1);
  for (var i = 0; i < portName.length; i++) {
    nativeStringArray[i] = portName.codeUnitAt(i);
  }
  nativeStringArray[portName.length] = 0;

  int result = Main.initSerialPort(nativeString);
  if (result == 0) {
    Pointer<CArray> x;
    while (true) {
      x = Main.readSerialPort(0, 2, 0);
      print(x.ref.arr.toDartString());
      print(x.ref.len);
    }
  } else {
    print("ERROR opening COM3!");
  }

  initMeeduPlayer();
  runApp(Home());
}

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  final _controller = SidebarXController(selectedIndex: 0, extended: false);
  final _key = GlobalKey<ScaffoldState>();

  @override
  StatelessElement createElement() {
    ;

    return StatelessElement(this);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mars Nav',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        canvasColor: canvasColor,
        scaffoldBackgroundColor: scaffoldBackgroundColor,
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: Colors.white,
            fontSize: 46,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      home: Builder(
        builder: (context) {
          final isSmallScreen = MediaQuery.of(context).size.width < 600;
          return Scaffold(
            key: _key,
            appBar: isSmallScreen
                ? AppBar(
              backgroundColor: canvasColor,
                  title: Text(Main.pageIndexToName[_controller.selectedIndex]),
            )
                : null,
            drawer: CustomSidebarX(controller: _controller),
            body: Row(
              children: [
                if (!isSmallScreen) CustomSidebarX(controller: _controller),
                Expanded(
                  child: Center(
                    child: MainNavigator(
                      controller: _controller,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CustomSidebarX extends StatelessWidget {
  const CustomSidebarX({
    Key? key,
    required SidebarXController controller,
  })  : _controller = controller,
        super(key: key);

  final SidebarXController _controller;

  @override
  Widget build(BuildContext context) {
    List<SidebarXItem> bars = [];
    if (Main.roverStatus == RoverState.autonomous) {
      bars.addAll([
        SidebarXItem(
          iconWidget: Image.asset("lib/icons/sensorial-white.png", height: Main.iconSize, width: Main.iconSize),
          label: Main.pageIndexToName[0],
        ),
        SidebarXItem(
          iconWidget: Image.asset("lib/icons/history-white.png", height: Main.iconSize, width: Main.iconSize),
          label: Main.pageIndexToName[2],
        ),
        SidebarXItem(
          iconWidget: Image.asset("lib/icons/commands-white.png", height: Main.iconSize * 1.5, width: Main.iconSize * 1.5),
          label: Main.pageIndexToName[3],
        ),
        SidebarXItem(
          iconWidget: Image.asset("lib/icons/command-shell-white.png", height: Main.iconSize, width: Main.iconSize),
          label: Main.pageIndexToName[4],
        ),
        SidebarXItem(
          iconWidget: Image.asset("lib/icons/settings-white.png", height: Main.iconSize, width: Main.iconSize),
          label: Main.pageIndexToName[5],
        ),
      ]);
    } else {
      bars.addAll([
        SidebarXItem(
          iconWidget: Image.asset("lib/icons/sensorial-white.png", height: Main.iconSize, width: Main.iconSize),
          label: Main.pageIndexToName[0],
        ),
        SidebarXItem(
          iconWidget: Image.asset("lib/icons/imagery-white.png", height: Main.iconSize, width: Main.iconSize),
          label: Main.pageIndexToName[1],
        ),
        SidebarXItem(
          iconWidget: Image.asset("lib/icons/history-white.png", height: Main.iconSize, width: Main.iconSize),
          label: Main.pageIndexToName[2],
        ),
        SidebarXItem(
          iconWidget: Image.asset("lib/icons/commands-white.png", height: Main.iconSize * 1.5, width: Main.iconSize * 1.5),
          label: Main.pageIndexToName[3],
        ),
        SidebarXItem(
          iconWidget: Image.asset("lib/icons/command-shell-white.png", height: Main.iconSize, width: Main.iconSize),
          label: Main.pageIndexToName[4],
        ),
        SidebarXItem(
          iconWidget: Image.asset("lib/icons/settings-white.png", height: Main.iconSize, width: Main.iconSize),
          label: Main.pageIndexToName[5],
        ),
      ]);
    }

    return MouseRegion(
      onEnter: (event) {
        _controller.toggleExtended();
      },
      onExit: (event) {
        _controller.toggleExtended();
      },
      child: SidebarX(
        headerDivider: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset("lib/icons/team_logo.png"),
            ),
            const SizedBox(height: 12),
          ],
        ),
        animationDuration: const Duration(milliseconds: 100),
        controller: _controller,
        showToggleButton: false,
        theme: SidebarXTheme(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: canvasColor,
            borderRadius: BorderRadius.circular(20),
          ),
          hoverColor: scaffoldBackgroundColor,
          textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          selectedTextStyle: const TextStyle(color: Colors.white),
          itemTextPadding: const EdgeInsets.only(left: 30),
          selectedItemTextPadding: const EdgeInsets.only(left: 30),
          itemDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: canvasColor),
          ),
          selectedItemDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: actionColor.withOpacity(0.37),
            ),
            gradient: const LinearGradient(
              colors: [accentCanvasColor, canvasColor],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.28),
                blurRadius: 30,
              )
            ],
          ),
          iconTheme: IconThemeData(
            color: Colors.white.withOpacity(0.7),
            size: 20,
          ),
          selectedIconTheme: const IconThemeData(
            color: Colors.white,
            size: 20,
          ),
        ),
        extendedTheme: const SidebarXTheme(
          width: 200,
          decoration: BoxDecoration(
            color: canvasColor,
          ),
        ),
        footerDivider: divider,
        footerBuilder: (context, extended) {
          return Container(
            margin: const EdgeInsets.fromLTRB(0, 12, 0, 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(visible: _controller.extended, child: Flexible(child: Text("${Main.batteryLevel}%", style: const TextStyle(fontSize: 16, color: Colors.white)))),
                    Visibility(visible: _controller.extended, child: const SizedBox(width: 10)),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        BatteryIcon(batteryPercentage: Main.batteryLevel / 100.0),
                        Visibility(
                            visible: Main.isRoverCharging,
                            child: Transform.rotate(angle: math.pi / 2, child: const Icon(Icons.bolt, color: Colors.white, size: 20))
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Visibility(visible: _controller.extended, child: Text(Main.roverBatteryRemainingTime, style: TextStyle(color: Colors.white))),
                Visibility(visible: _controller.extended, child: const SizedBox(height: 12)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Shimmer.fromColors(
                        baseColor: Main.roverStatus.color,
                        highlightColor: Colors.white.withOpacity(0.8),
                        period: const Duration(milliseconds: 3500),
                        child: Container(
                          width: Main.iconSize,
                          height: Main.iconSize,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                        )
                    ),
                    Visibility(
                        visible: _controller.extended,
                        child: const SizedBox(width: 12)
                    ),
                    Visibility(
                      visible: _controller.extended,
                      child: Flexible(
                        child: Text(
                            Main.roverStatus.description,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
        items: bars,
      ),
    );
  }
}

class MainNavigator extends StatelessWidget {
  const MainNavigator({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final SidebarXController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        if (Main.roverStatus == RoverState.autonomous) {
          switch (controller.selectedIndex) {
            case 0:
              return SensoryPage(value: 10);
            case 1:
              return HistoryPage();
            case 2:
              return CommandsPage();
            case 3:
              return ShellPage();
            case 4:
              return SettingsPage();
            default:
              return Text(
                "This page should not be accessible, this has to be fixed",
                style: theme.textTheme.headlineSmall,
              );
          }
        } else {
          switch (controller.selectedIndex) {
            case 0:
              return SensoryPage(value: 10,);
            case 1:
              return ImageryPage();
            case 2:
              return HistoryPage();
            case 3:
              return CommandsPage();
            case 4:
              return ShellPage();
            case 5:
              return SettingsPage();
            default:
              return Text(
                "This page should not be accessible, this has to be fixed",
                style: theme.textTheme.headlineSmall,
              );
          }
        }
      },
    );
  }
}

const primaryColor = Color(0xFF685BFF);
const canvasColor = Color(0xFF2E2E48);
const scaffoldBackgroundColor = Color(0xFF464667);
const accentCanvasColor = Color(0xFF3E3E61);
const white = Colors.white;
final actionColor = const Color(0xFF5F5FA7).withOpacity(0.6);
final divider = Divider(color: white.withOpacity(0.3), height: 1);