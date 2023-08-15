import 'dart:convert';
import 'dart:io';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_meedu_videoplayer/init_meedu_player.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:mars_nav/pages/CommandsPage.dart';
import 'package:mars_nav/pages/HistoryPage.dart';
import 'package:mars_nav/pages/ImageryPage.dart';
import 'package:mars_nav/pages/SamplesPage.dart';
import 'package:mars_nav/pages/SensoryPage.dart';
import 'package:mars_nav/pages/SettingsPage.dart';
import 'package:mars_nav/pages/ShellPage.dart';
import 'package:mars_nav/services/InfluxDBHandle.dart';
import 'package:mars_nav/widgets/BatteryIcon.dart';
import 'package:mars_nav/widgets/VideoPlayer.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ffi/ffi.dart';

import 'dart:math' as math;

enum RoverState {
  standard("STANDARD MODE", Colors.green), autonomous("AUTONOMOUS MODE", Colors.yellow), halt("HALTED", Colors.red), offline("OFFLINE", Colors.blueGrey);
  const RoverState(this.name, this.color);
  final String name;
  final Color color;
}


class Main { // This class holds all the general variables to the interface as a whole

  // Theme Colors:
  static const primaryColor = Color(0xFF685BFF);
  static const canvasColor = Color(0xFF2E2E48);
  static const scaffoldBackgroundColor = Color(0xFF464667);
  static const accentCanvasColor = Color(0xFF3E3E61);
  static const white = Colors.white;
  static final actionColor = const Color(0xFF5F5FA7).withOpacity(0.6);

  // Interface related:
  static bool appInitialized = false;
  static bool isMainWindow = true;
  static Widget? widgetToDisplay;
  static late List<String> options;
  static late String appDir;
  static late Process dbProcess;
  static bool windowCloseInit = false;

  static const List<String> imageExtensions = ['jpg', '.peg', 'png', 'gif', 'bmp', 'avif', 'webp', 'jpeg'];
  static const List<String> videoExtensions = ['mp4', 'avi', 'mkv', 'mov', 'wmv'];

  // Rover related:
  static RoverState roverStatus = RoverState.standard; // holds the state of the rover
  static const double iconSize = 20.0;
  static const pageIndexToName = ["Sensory", "Imagery", "Samples", "History", "Commands", "Command Shell", "Settings"];

  static SensorReadingSpeed sensorSpeed = SensorReadingSpeed.s0_5;

  // Battery in Rover:
  static double batteryLevel = 95;
  static bool isRoverCharging = false;
  static double batteryVoltRover = 0.0; // out of 26V (6 cells)
  static double electronicsCurrent = 2.0; // out of 5A
  static double motorsCurrent = 70.0; // out of 150A
  static double powerConsumption = 550; // out of 600W, Can't be calculated from the interface, has to be sent from the rover
  static String roverBatteryRemainingTime = "1h 3m";

  // atmosphere in Drone (used for both drone and rover):
  static double humidity = 10;
  static double temperature = 90;
  static double airPressure = 50;

  // IMU sensor in Rover: 0 - 180 degrees
  static double xAngle = 155;
  static double yAngle = 20;
  static double compassAngle = 69; // equivalent to the z axis angle, 0 - 360 degree
  static double speed = 0.4; // in m/s

  // gas sensors: 100 ppm - 10000 ppm
  static double CO2_value = 1500;
  static double MQ_8_value = 1000;
  static double MQ_135_value = 700;
  static double MQ_2_value = 2000;
  static double MQ_7_value = 9600;

  // particles sensor:
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

void main(List<String> args) async {

  Main.appDir = (await getApplicationDocumentsDirectory()).path;

  // print("The args I received are: $args");
  Main.options = [];
  if (args.isNotEmpty) {
    Main.options = args; // The first two are ['multi_window', 1, json]
    Main.isMainWindow = false;
    switch(Main.options[0]) {
      case "video_player":
        Main.widgetToDisplay = VideoPlayer(filePath: Main.options[1]);
        break;
    }
  } else { // otherwise it is a main window:
    // TODO: check for release mode in msix
    Main.dbProcess = await Process.start("lib/assets/influxdb/influxd.exe", ["--bolt-path=./lib/assets/influxdb/all_data/all_data.bolt"]);
    Main.dbProcess.stderr.transform(utf8.decoder).listen((data) {
      print('stderr: $data');
    });
    Main.dbProcess.stdout.transform(utf8.decoder).listen((data) {
      print('stdout: $data');
    });
    Future.delayed(const Duration(seconds: 4), () {
      InfluxDBHandle().init();
    });
  }


    Main.nativeApiLib = DynamicLibrary.open('api.dll');
    Main.initSerialPort = Main.nativeApiLib.lookup<NativeFunction<Int Function(Pointer<Int8>)>>('initSerial').asFunction<int Function(Pointer<Int8>)>();
    Main.readSerialPort = Main.nativeApiLib.lookup<NativeFunction<Pointer<CArray> Function(Int, Int, Int)>>('readSerialPort').asFunction<Pointer<CArray> Function(int, int, int)>();
    Main.delArray = Main.nativeApiLib.lookup<NativeFunction<Void Function(Pointer<CArray>)>>('delArray').asFunction<void Function(Pointer<CArray>)>();
    Main.closeSerialPort = Main.nativeApiLib.lookup<NativeFunction<Void Function(Int)>>('closeSerialPort').asFunction<void Function(int)>();
    Main.maximizeWindow = Main.nativeApiLib.lookup<NativeFunction<Void Function()>>('maximizeWindow').asFunction<void Function()>();

    Directory directory = Directory(Main.appDir + r"\mars_nav");

    if (!directory.existsSync()) {
      directory.createSync();
      Directory(Main.appDir + r"\mars_nav\imagery").createSync();
    } else {
      directory = Directory(Main.appDir + r"\mars_nav\imagery");
      if (!directory.existsSync()) {
        directory.createSync();
      }
    }

  // const portName = "COM6";
  // final Pointer<Int8> nativeString = calloc<Int8>(portName.length + 1);
  // final nativeStringArray = nativeString.asTypedList(portName.length + 1);
  // for (var i = 0; i < portName.length; i++) {
  //   nativeStringArray[i] = portName.codeUnitAt(i);
  // }
  // nativeStringArray[portName.length] = 0;
  //
  // int result = Main.initSerialPort(nativeString);
  // if (result == 0) {
  //   Pointer<CArray> x;
  //   while (true) {
  //     x = Main.readSerialPort(0, 2, 0);
  //     print(x.ref.arr.toDartString());
  //     print(x.ref.len);
  //     Main.delArray(x); // Deallocate the C object, in C++ we need to clean our own memory
  //   }
  // } else {
  //   print("ERROR opening COM3!");
  // }

    initMeeduPlayer();

    runApp(Home());
}

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  final controller_ = SidebarXController(selectedIndex: 0, extended: false);
  final key_ = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    if (!Main.windowCloseInit) {
      Main.windowCloseInit = true;
      FlutterWindowClose.setWindowShouldCloseHandler(() async { // A function to be called before closing:
        print("Window close is triggered!");
        Main.dbProcess.kill(ProcessSignal.sigint); // equivalent to CTRL+C
        int exitCode = await Main.dbProcess.exitCode;
        print("InfluxDB exit code: $exitCode");
        InfluxDBHandle().close();
        return true;
      });
    }


    if (Main.isMainWindow && !Main.appInitialized) {
      Future.delayed(const Duration(seconds: 2), () {
        Main.appInitialized = true;
        print('App initialized after first frame!');
        Main.maximizeWindow();
      });
    }

    return OKToast(
      child: MaterialApp(
        title: 'Mars Nav',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Main.primaryColor,
          canvasColor: Main.canvasColor,
          scaffoldBackgroundColor: Main.scaffoldBackgroundColor,
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
            if (Main.widgetToDisplay != null) {
              return Scaffold(
                key: key_,
                body: Center(
                  child: Main.widgetToDisplay,
                ),
              );
            } else {
              return Scaffold(
                key: key_,
                appBar: isSmallScreen
                    ? AppBar(
                  backgroundColor: Main.canvasColor,
                  title: Text(Main.pageIndexToName[controller_.selectedIndex]),
                )
                    : null,
                drawer: CustomSidebarX(controller: controller_),
                body: Row(
                  children: [
                    if (!isSmallScreen) CustomSidebarX(controller: controller_),
                    Expanded(
                      child: MainNavigator(
                        controller: controller_,
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
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
          iconWidget: Image.asset("lib/assets/icons/sensorial-white.png", height: Main.iconSize, width: Main.iconSize),
          label: Main.pageIndexToName[0],
        ),
        SidebarXItem(
          iconWidget: Image.asset("lib/assets/icons/samples-white.png", height: Main.iconSize * 1.5, width: Main.iconSize * 1.5),
          label: Main.pageIndexToName[2],
        ),
        SidebarXItem(
          iconWidget: Image.asset("lib/assets/icons/history-white.png", height: Main.iconSize, width: Main.iconSize),
          label: Main.pageIndexToName[3],
        ),
        SidebarXItem(
          iconWidget: Image.asset("lib/assets/icons/commands-white.png", height: Main.iconSize * 1.5, width: Main.iconSize * 1.5),
          label: Main.pageIndexToName[4],
        ),
        SidebarXItem(
          iconWidget: Image.asset("lib/assets/icons/command-shell-white.png", height: Main.iconSize, width: Main.iconSize),
          label: Main.pageIndexToName[5],
        ),
        SidebarXItem(
          iconWidget: Image.asset("lib/assets/icons/settings-white.png", height: Main.iconSize, width: Main.iconSize),
          label: Main.pageIndexToName[6],
        ),
      ]);
    } else {
      bars.addAll([
        SidebarXItem(
          iconWidget: Image.asset("lib/assets/icons/sensorial-white.png", height: Main.iconSize, width: Main.iconSize),
          label: Main.pageIndexToName[0],
        ),
        SidebarXItem(
          iconWidget: Image.asset("lib/assets/icons/imagery-white.png", height: Main.iconSize, width: Main.iconSize),
          label: Main.pageIndexToName[1],
        ),
        SidebarXItem(
          iconWidget: Image.asset("lib/assets/icons/samples-white.png", height: Main.iconSize * 1.5, width: Main.iconSize * 1.5),
          label: Main.pageIndexToName[2],
        ),
        SidebarXItem(
          iconWidget: Image.asset("lib/assets/icons/history-white.png", height: Main.iconSize, width: Main.iconSize),
          label: Main.pageIndexToName[3],
        ),
        SidebarXItem(
          iconWidget: Image.asset("lib/assets/icons/commands-white.png", height: Main.iconSize * 1.5, width: Main.iconSize * 1.5),
          label: Main.pageIndexToName[4],
        ),
        SidebarXItem(
          iconWidget: Image.asset("lib/assets/icons/command-shell-white.png", height: Main.iconSize, width: Main.iconSize),
          label: Main.pageIndexToName[5],
        ),
        SidebarXItem(
          iconWidget: Image.asset("lib/assets/icons/settings-white.png", height: Main.iconSize, width: Main.iconSize),
          label: Main.pageIndexToName[6],
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
              child: Image.asset("lib/assets/icons/team_logo.png"),
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
            color: Main.canvasColor,
            borderRadius: BorderRadius.circular(20),
          ),
          hoverColor: Main.scaffoldBackgroundColor,
          textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          selectedTextStyle: const TextStyle(color: Colors.white),
          itemTextPadding: const EdgeInsets.only(left: 30),
          selectedItemTextPadding: const EdgeInsets.only(left: 30),
          itemDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Main.canvasColor),
          ),
          selectedItemDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Main.actionColor.withOpacity(0.37),
            ),
            gradient: const LinearGradient(
              colors: [Main.accentCanvasColor, Main.canvasColor],
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
            color: Main.canvasColor,
          ),
        ),
        footerDivider: Divider(color: Colors.white.withOpacity(0.3), height: 1),
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
                Visibility(visible: _controller.extended, child: Text(Main.roverBatteryRemainingTime, style: const TextStyle(color: Colors.white))),
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
                            Main.roverStatus.name,
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
              return SensoryPage();
            case 1:
              return SamplesPage();
            case 2:
              return HistoryPage();
            case 3:
              return CommandsPage();
            case 4:
              return ShellPage(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height);
            case 5:
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
              return SensoryPage();
            case 1:
              return ImageryPage();
            case 2:
              return SamplesPage();
            case 3:
              return HistoryPage();
            case 4:
              return CommandsPage();
            case 5:
              return ShellPage(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height);
            case 6:
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
