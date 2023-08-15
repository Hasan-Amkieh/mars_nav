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

  static const titleStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18);
  static const descriptionStyle = TextStyle(color: Colors.white);
  static const subtitleSeparator = SizedBox(height: 10);

  int roverStatusIndex = Main.roverStatus.index;
  int sensorSpeedIndex = Main.sensorSpeed.index;

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
                  padding: EdgeInsets.fromLTRB(0, 0, 0.4 * MediaQuery.of(context).size.width, 0.4 * MediaQuery.of(context).size.height),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("General", style: titleStyle),
                      // const Text("", style: descriptionStyle),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            } else if (text == RoverState.autonomous.name) {
                              roverStatusIndex = 1;
                              Main.roverStatus = RoverState.autonomous;
                            } else {
                              roverStatusIndex = 2;
                              Main.roverStatus = RoverState.halt;
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
          ],
        ),
      ),
    );
  }

  List<int> createIntegerList(int stop) {
    List<int> integerList = [];
    for (int i = 0; i < stop; i++) {
      integerList.add(i);
    }
    return integerList;
  }

}

