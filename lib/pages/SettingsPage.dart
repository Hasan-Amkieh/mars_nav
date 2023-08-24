import 'dart:async';
import 'dart:ffi';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter_fast_forms/flutter_fast_forms.dart';
import 'package:mars_nav/main.dart';

enum SensorReadingSpeed {
  s0_5(0.5, "0.5s"), s1_0(1.0, "1.0s"), s2_0(2.0, "2.0s");
  const SensorReadingSpeed(this.speed, this.name);

  final double speed;
  final String name;
}

class SettingsPage extends StatefulWidget {

  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return SettingsPageState();
  }

}

class SettingsPageState extends State<SettingsPage> {

  @override
  void initState() {
    super.initState();

    timer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
    _updateSerialPorts();
  }

  Timer? timer;

  static const titleStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18);
  static const descriptionStyle = TextStyle(color: Colors.white);
  static const subtitleSeparator = SizedBox(height: 10);
  static const titleIconSeparator = SizedBox(width: 10);

  int roverStatusIndex = Main.roverStatus.index;
  int sensorSpeedIndex = Main.sensorSpeed.index;

  bool isInAutonomous = false;

  String? selectedArm;
  String? selectedRover;
  List<String> ports = [];

  void _updateSerialPorts() {

    ports.clear();
    Pointer<CSerialPorts> availableSerialPorts = Main.getSerialPorts();
    for (int i = 0 ; i < availableSerialPorts.ref.len ; i++) {
      ports.add("${availableSerialPorts.ref.arr.elementAt(i).value.elementAt(0).value.toDartString()}"
          " - ${availableSerialPorts.ref.arr.elementAt(i).value.elementAt(1).value.toDartString()}");
    }

    if (!ports.contains(selectedArm)) {
      if (ports.isNotEmpty) {
        selectedArm = ports.first;
      } else {
        selectedArm = null;
      }
    }

    if (!ports.contains(selectedRover)) {
      if (ports.isNotEmpty) {
        selectedRover = ports.last;
        if (selectedRover == selectedArm) {
          selectedRover = null;
        }
      } else {
        selectedRover = null;
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0.4 * MediaQuery.of(context).size.width, 0.2 * MediaQuery.of(context).size.height),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset("lib/assets/icons/rover.png", color: Colors.white, width: Main.iconSize * 1.8, height: Main.iconSize * 1.8),
                          titleIconSeparator,
                          const Text("General", style: titleStyle),
                        ],
                      ),
                      // const Text("", style: descriptionStyle),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Operating Mode", style: TextStyle(color: Colors.white)),
                    subtitleSeparator,
                    SizedBox(
                      width: 300,
                      child: FastSegmentedControl<String>(
                        contentPadding: const EdgeInsets.all(0),
                        padding: const EdgeInsets.all(0),
                        name: 'segmented_control',
                        onChanged: (text) {
                          setState(() {
                            if (text == RoverState.standard.name) {
                              roverStatusIndex = 0;
                              Main.roverStatus = RoverState.standard;
                              if (CustomSidebarX.setState != null) {
                                CustomSidebarX.setState!(() {
                                  if (isInAutonomous) {
                                    isInAutonomous = false;
                                    Main.increasePageIndex = true;
                                  }
                                });
                              } else {
                                print("ERROR!");
                              }
                            } else if (text == RoverState.autonomous.name) {
                              roverStatusIndex = 1;
                              Main.roverStatus = RoverState.autonomous;
                              if (CustomSidebarX.setState != null) {
                                CustomSidebarX.setState!(() {
                                  Main.decreasePageIndex = true;
                                  isInAutonomous = true;
                                });
                              } else {
                                print("ERROR!");
                              }
                            } else {
                              roverStatusIndex = 2;
                              Main.roverStatus = RoverState.halt;
                              if (CustomSidebarX.setState != null) {
                                CustomSidebarX.setState!(() {
                                  if (isInAutonomous) {
                                    isInAutonomous = false;
                                    Main.increasePageIndex = true;
                                  }
                                });
                              } else {
                                print("ERROR!");
                              }
                            }
                          });
                        },
                        initialValue: RoverState.values[roverStatusIndex].name,
                        children: {
                          RoverState.standard.name : Text('Standard', style: TextStyle(color: roverStatusIndex != 0 ? Colors.white : Colors.black)),
                          RoverState.autonomous.name : Text('Autonomous', style: TextStyle(color: roverStatusIndex != 1 ? Colors.white : Colors.black)),
                          RoverState.halt.name : Text('Halt', style: TextStyle(color: roverStatusIndex != 2 ? Colors.white : Colors.black)),
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton.icon(
                      label: Text("Restart Rover", style: TextStyle(color: Main.roverStatus == RoverState.offline ? Colors.grey : Colors.orange)),
                      icon: Icon(Icons.restart_alt, color: Main.roverStatus == RoverState.offline ? Colors.grey : Colors.orange),
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all((Main.roverStatus == RoverState.offline ? Colors.grey : Colors.orange).withOpacity(0.2)),
                      ),
                      onPressed: () {},
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      label: Text("Shut down Rover", style: TextStyle(color: Main.roverStatus == RoverState.offline ? Colors.grey : Colors.red)),
                      icon: Icon(Icons.settings_power, color: Main.roverStatus == RoverState.offline ? Colors.grey : Colors.red),
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all((Main.roverStatus == RoverState.offline ? Colors.grey : Colors.red).withOpacity(0.2)),
                      ),
                      onPressed: () {},
                    ),
                    const SizedBox(height: 20),
                    const Text("Sensor Reading Speed", style: TextStyle(color: Colors.white)),
                    subtitleSeparator,
                    SizedBox(
                      width: 120,
                      height: 100,
                      child: FastSegmentedControl<String>(
                        contentPadding: const EdgeInsets.all(0),
                        padding: const EdgeInsets.all(0),
                        name: 'segmented_control',
                        onChanged: (text) {
                          setState(() {
                            if (text == SensorReadingSpeed.s0_5.name) {
                              sensorSpeedIndex = 0;
                              Main.sensorSpeed = SensorReadingSpeed.s0_5;
                            } else if (text == SensorReadingSpeed.s1_0.name) {
                              sensorSpeedIndex = 1;
                              Main.sensorSpeed = SensorReadingSpeed.s1_0;
                            } else {
                              sensorSpeedIndex = 2;
                              Main.sensorSpeed = SensorReadingSpeed.s2_0;
                            }
                          });
                        },
                        initialValue: SensorReadingSpeed.values[sensorSpeedIndex].name,
                        children: {
                          SensorReadingSpeed.s0_5.name : Text(SensorReadingSpeed.s0_5.name, style: TextStyle(color: sensorSpeedIndex != 0 ? Colors.white : Colors.black)),
                          SensorReadingSpeed.s1_0.name : Text(SensorReadingSpeed.s1_0.name, style: TextStyle(color: sensorSpeedIndex != 1 ? Colors.white : Colors.black)),
                          SensorReadingSpeed.s2_0.name : Text(SensorReadingSpeed.s2_0.name, style: TextStyle(color: sensorSpeedIndex != 2 ? Colors.white : Colors.black)),
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(thickness: 3),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0.4 * MediaQuery.of(context).size.width, 0.4 * MediaQuery.of(context).size.height),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(CupertinoIcons.game_controller, color: Colors.white),
                          titleIconSeparator,
                          Text("Controllers", style: titleStyle),
                        ],
                      ),
                      // const Text("", style: descriptionStyle),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Image.asset("lib/assets/icons/robotic-arm.png", color: Colors.white, width: Main.iconSize * 1.5, height: Main.iconSize * 1.5),
                        const SizedBox(width: 8),
                        const Text("Arm Controller", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(
                          width: 220,
                          child: DropdownButtonFormField2<String>(
                            key: widget.key,
                            value: selectedArm,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            hint: const Text(
                              'Select Serial Port',
                              style: TextStyle(fontSize: 14, color: Colors.white70),
                            ),
                            items: ports.map((item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            )).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Please Select a Serial Port';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              selectedArm = value.toString();
                            },
                            onSaved: (value) {
                              selectedArm = value.toString();
                            },
                            buttonStyleData: const ButtonStyleData(
                              padding: EdgeInsets.only(right: 8),
                            ),
                            iconStyleData: const IconStyleData(
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.black45,
                              ),
                              iconSize: 24,
                            ),
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          style: ButtonStyle(
                            overlayColor: MaterialStateProperty.all(Colors.deepOrange.withOpacity(0.2)),
                            padding: MaterialStateProperty.all(EdgeInsets.zero),
                          ),
                          child: const Icon(Icons.refresh, color: Colors.deepOrange),
                          onPressed: () {
                            setState(() {
                              _updateSerialPorts();
                            });
                          },
                        ),
                        const SizedBox(width: 12),
                        TextButton.icon(
                          style: ButtonStyle(
                            overlayColor: MaterialStateProperty.all(Colors.green.withOpacity(0.2)),
                            padding: MaterialStateProperty.all(EdgeInsets.zero),
                          ),
                          label: Text("CONNECT", style: TextStyle(color: Colors.green)),
                          icon: Image.asset("lib/assets/icons/connect-usb.png", color: Colors.green, width: Main.iconSize * 1.8, height: Main.iconSize * 1.8),
                          onPressed: () {
                            setState(() {
                              _updateSerialPorts();
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Image.asset("lib/assets/icons/rover.png", color: Colors.white, width: Main.iconSize * 1.5, height: Main.iconSize * 1.5),
                        const SizedBox(width: 8),
                        const Text("Rover Controller", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(
                          width: 220,
                          child: DropdownButtonFormField2<String>(
                            key: widget.key,
                            value: selectedRover,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            hint: const Text(
                              'Select Serial Port',
                              style: TextStyle(fontSize: 14, color: Colors.white70),
                            ),
                            items: ports.map((item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            )).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Please Select a Serial Port';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              selectedRover = value.toString();
                            },
                            onSaved: (value) {
                              selectedRover = value.toString();
                            },
                            buttonStyleData: const ButtonStyleData(
                              padding: EdgeInsets.only(right: 8),
                            ),
                            iconStyleData: const IconStyleData(
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.black45,
                              ),
                              iconSize: 24,
                            ),
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          style: ButtonStyle(
                            overlayColor: MaterialStateProperty.all(Colors.deepOrange.withOpacity(0.2)),
                            padding: MaterialStateProperty.all(EdgeInsets.zero),
                          ),
                          child: const Icon(Icons.refresh, color: Colors.deepOrange),
                          onPressed: () {
                            setState(() {
                              _updateSerialPorts();
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const Divider(thickness: 3),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0.4 * MediaQuery.of(context).size.width, 0.4 * MediaQuery.of(context).size.height),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.map, color: Colors.white),
                          titleIconSeparator,
                          Text("SLAM Maps", style: titleStyle),
                        ],
                      ),
                      // const Text("", style: descriptionStyle),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      label: const Text("Upload Map", style: TextStyle(color: Colors.green)),
                      icon: const Icon(Icons.upload, color: Colors.green),
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all(Colors.green.withOpacity(0.2)),
                      ),
                      onPressed: () {},
                    ),
                    const SizedBox(height: 20),
                    TextButton.icon(
                      label: Text("View Map", style: TextStyle(color: Main.roverStatus == RoverState.offline ? Colors.grey : Colors.yellowAccent)),
                      icon: Icon(Icons.view_in_ar_sharp, color: Main.roverStatus == RoverState.offline ? Colors.grey : Colors.yellowAccent),
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all((Main.roverStatus == RoverState.offline ? Colors.grey : Colors.yellowAccent).withOpacity(0.2)),
                      ),
                      onPressed: () {},
                    ),
                    const SizedBox(height: 20),
                    TextButton.icon(
                      label: Text("Download Map", style: TextStyle(color: Main.roverStatus == RoverState.offline ? Colors.grey : Colors.green)),
                      icon: Icon(Icons.download, color: Main.roverStatus == RoverState.offline ? Colors.grey : Colors.green),
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all((Main.roverStatus == RoverState.offline ? Colors.grey : Colors.green).withOpacity(0.2)),
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
            const Divider(thickness: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Version  0.0.0.1", style: TextStyle(color: Colors.white)),
                    Text("Rover Runtime  ${Main.convertMillisToDuration(DateTime.now().millisecondsSinceEpoch - Main.roverStartTime.millisecondsSinceEpoch)}",
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (timer != null) {
      timer!.cancel();
    }
  }

  List<int> createIntegerList(int stop) {
    List<int> integerList = [];
    for (int i = 0; i < stop; i++) {
      integerList.add(i);
    }
    return integerList;
  }

}

