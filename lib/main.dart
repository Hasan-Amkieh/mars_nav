import 'package:flutter/material.dart';
import 'package:mars_nav/pages/CommandsPage.dart';
import 'package:mars_nav/pages/HistoryPage.dart';
import 'package:mars_nav/pages/ImageryPage.dart';
import 'package:mars_nav/pages/SensoryPage.dart';
import 'package:mars_nav/pages/SettignsPage.dart';
import 'package:mars_nav/pages/ShellPage.dart';
import 'package:mars_nav/widgets/BatteryIcon.dart';
import 'package:serial_port_win32/serial_port_win32.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:shimmer/shimmer.dart';

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

  // Battery Related Rover:
  static double batteryLevel = 95;
  static bool isRoverCharging = false;
  static String roverBatteryRemainingTime = "1h 3m";

  // atmosphere:
  static double humidity = 10;
  static double temperature = 90;
  static double airPressure = 50;

  // gas sensors:
  static double MQ_8_value = 1000;
  static double MQ_135_value = 700;
  static double MQ_2_value = 2000;
  static double MQ_7_value = 9600;

  // Battery Related Drone:
  static double batteryVolt = 0.0;
  static bool isDroneCharging = true;


}

void main() {

  // This will be used to connect the controller to control the rover/drone manually
  if (SerialPort.getAvailablePorts().contains("COM5")) { // Might different than COM5,
    final port = SerialPort("COM5", openNow: false);
    port.openWithSettings(BaudRate: 115200);

    port.readBytesSize = 3; // Means when 3 bytes are received in the buffer, then they are printed or the timeout has passed
    port.readOnListenFunction = (value) {
      print(value);
    };
  }

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
              leading: IconButton(
                onPressed: () {
                  // if (!Platform.isAndroid && !Platform.isIOS) {
                  //   _controller.setExtended(true);
                  // }
                  _key.currentState?.openDrawer();
                },
                icon: const Icon(Icons.menu),
              ),
            )
                : null,
            drawer: ExampleSidebarX(controller: _controller),
            body: Row(
              children: [
                if (!isSmallScreen) ExampleSidebarX(controller: _controller),
                Expanded(
                  child: Center(
                    child: _ScreensExample(
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

class ExampleSidebarX extends StatelessWidget {
  const ExampleSidebarX({
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

class _ScreensExample extends StatelessWidget {
  const _ScreensExample({
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