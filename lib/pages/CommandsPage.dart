import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:mars_nav/services/SampleData.dart";
import "package:mars_nav/widgets/CommandContainer.dart";
import "package:mars_nav/widgets/ProcessTimeline.dart";
import 'package:timelines/timelines.dart';

import "../main.dart";
import "../services/Commands.dart";


class CommandsPage extends StatefulWidget {

  const CommandsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return CommandsPageState();
  }

}

class CommandsPageState extends State<CommandsPage> {

  late int hours = 0;
  late int minutes = 10;
  late int seconds = 0;

  @override
  void initState() {
    super.initState();
  }

  int processIndex = 2;

  List<Command> commands = [];
  int photographyIndex = 0;
  int roverCameraResIndex = 0;
  int roverCameraIndex = 0;

  static TextStyle commandContainerStyle = const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16);
  static const verticalSeparator = SizedBox(height: 8);

  int videoSeconds = 0;
  int videoMinutes = 0;

  String beginLongitudeFieldStr = '';
  String beginLatitudeFieldStr = '';
  String endLongitudeFieldStr = '';
  String endLatitudeFieldStr = '';
  String distanceFieldStr = '';
  String directionalAngleFieldStr = '';
  bool isNavigationGPS = false;
  List<DirectionalVector> navCommandWaypoints = [];

  int sampleTypeIndex = 0;
  int locationTypeIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget navigationCommandButtons = Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          height: 130,
          child: Timeline.tileBuilder(
            theme: TimelineThemeData(
              direction: Axis.horizontal,
              connectorTheme: const ConnectorThemeData(
                space: 20.0,
                thickness: 5.0,
              ),
            ),
            builder: TimelineTileBuilder.fromStyle(
                itemCount: navCommandWaypoints.length,
                contentsBuilder: (context, index) {
                  return Text(
                      "${navCommandWaypoints[index].distance.toStringAsFixed(1)}m ${navCommandWaypoints[index].compassAngle.toStringAsFixed(1)} ${NavigationCommand.getDirectionExpressionFromAngle(navCommandWaypoints[index].compassAngle)}   ",
                      style: const TextStyle(color: Colors.white),
                  );
                }
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              style: ButtonStyle(
                side: MaterialStateProperty.all(BorderSide(
                    color: hours == 0 && minutes == 0 && seconds == 0 ? Colors.grey : Main.primaryColor).copyWith(width: 2)),
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.isNotEmpty) {
                    if (MaterialState.hovered == states.first) {
                      return Colors.transparent;
                    }
                  }
                  return hours == 0 && minutes == 0 && seconds == 0 ? Colors.grey : Main.primaryColor.withOpacity(1.0);
                }),
              ),
              onPressed: hours == 0 && minutes == 0 && seconds == 0 ? null : () {
                setState(() {
                  if (isNavigationGPS) {
                    navCommandWaypoints.add(GPSLocation.toDirectionalVector(
                        GPSLocation(latitude: double.parse(beginLatitudeFieldStr), longitude: double.parse(beginLongitudeFieldStr)),
                        GPSLocation(latitude: double.parse(endLatitudeFieldStr), longitude: double.parse(endLongitudeFieldStr))));
                  } else {
                    navCommandWaypoints.add(DirectionalVector(distance: double.parse(distanceFieldStr), compassAngle: double.parse(directionalAngleFieldStr)));
                  }
                });
              },
              label: const Text("Add Waypoint", style: TextStyle(color: Colors.white)),
              icon: const Icon(CupertinoIcons.map_pin_ellipse, color: Colors.white),
            ),
            const SizedBox(width: 12),
            TextButton.icon(
              style: ButtonStyle(
                side: MaterialStateProperty.all(BorderSide(
                    color: navCommandWaypoints.isEmpty ? Colors.grey : Main.primaryColor).copyWith(width: 2)),
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.isNotEmpty) {
                    if (MaterialState.hovered == states.first) {
                      return Colors.transparent;
                    }
                  }
                  return navCommandWaypoints.isEmpty ? Colors.grey : Main.primaryColor.withOpacity(1.0);
                }),
              ),
              onPressed: navCommandWaypoints.isEmpty ? null : () {
                setState(() {
                  List<DirectionalVector> dirs = [];
                  navCommandWaypoints.forEach((element) => dirs.add(element));
                  Command command = NavigationCommand(directionalVectors: dirs, createdAt: DateTime.now());
                  command.onDeleted = () {
                    setState(() {
                      commands.remove(command);
                    });
                  };
                  addCommand(command);
                  navCommandWaypoints.clear();
                });
              },
              label: const Text("Add Command", style: TextStyle(color: Colors.white)),
              icon: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommandContainer(
                        width: MediaQuery.of(context).size.width * 0.42,
                        height: 200,
                        iconWidget: const Icon(Icons.more_time_outlined, color: Colors.white, size: Main.iconSize * 1.8),
                        titleWidget: Text("Delay", style: commandContainerStyle),
                        detailsWidget: null,
                        contents: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  const Text('Hours', style: TextStyle(color: Colors.white)),
                                  Slider(
                                    value: hours.toDouble(),
                                    min: 0,
                                    max: 2,
                                    onChanged: (value) {
                                      setState(() {
                                        hours = value.toInt();
                                      });
                                    },
                                  ),
                                  Text('$hours h', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('Minutes', style: TextStyle(color: Colors.white)),
                                  Slider(
                                    value: minutes.toDouble(),
                                    min: 0,
                                    max: 59,
                                    onChanged: (value) {
                                      setState(() {
                                        minutes = value.toInt();
                                      });
                                    },
                                  ),
                                  Text('$minutes min', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('Seconds', style: TextStyle(color: Colors.white)),
                                  Slider(
                                    value: seconds.toDouble(),
                                    min: 0,
                                    max: 59,
                                    onChanged: (value) {
                                      setState(() {
                                        seconds = value.toInt();
                                      });
                                    },
                                  ),
                                  Text('$seconds sec', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            style: ButtonStyle(
                              side: MaterialStateProperty.all(BorderSide(
                                  color: hours == 0 && minutes == 0 && seconds == 0 ? Colors.grey : Main.primaryColor).copyWith(width: 2)),
                              backgroundColor: MaterialStateProperty.resolveWith((states) {
                                if (states.isNotEmpty) {
                                  if (MaterialState.hovered == states.first) {
                                    return Colors.transparent;
                                  }
                                }
                                return hours == 0 && minutes == 0 && seconds == 0 ? Colors.grey : Main.primaryColor.withOpacity(1.0);
                              }),
                            ),
                            onPressed: hours == 0 && minutes == 0 && seconds == 0 ? null : () {
                              setState(() {
                                Command command = DelayCommand(toWait: Duration(hours: hours, minutes: minutes, seconds: seconds), createdAt: DateTime.now());
                                command.onDeleted = () {
                                  setState(() {
                                    commands.remove(command);
                                  });
                                };
                                addCommand(command);
                              });
                            },
                            label: const Text("Add", style: TextStyle(color: Colors.white)),
                            icon: const Icon(Icons.add, color: Colors.white),
                          ),
                        ],
                      ),
                      CommandContainer(
                        width: MediaQuery.of(context).size.width * 0.42,
                        height: 300,
                        iconWidget: const Icon(Icons.add_photo_alternate_outlined, color: Colors.white, size: Main.iconSize * 1.8),
                        titleWidget: Text("Photography", style: commandContainerStyle),
                        detailsWidget: TextButton.icon(
                          label: Text(PhotographyType.values[photographyIndex].name, style: TextStyle(color: Main.primaryColor)),
                          icon: Icon(photographyIndex == 0 ? Icons.panorama_photosphere :
                          (photographyIndex == 1 ? Icons.photo_camera_back : Icons.video_call_outlined), color: Main.primaryColor),
                          onPressed: () {
                            setState(() {
                              if (++photographyIndex == 3) {
                                photographyIndex = 0;
                              }
                              videoSeconds = 0;
                              videoMinutes = 0;
                            });
                          },
                        ),
                        contents: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(22, 42, 22, 22),
                            child: Column(
                              children: [
                                Visibility(
                                  visible: photographyIndex != 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Resolution", style: TextStyle(color: Colors.white)),
                                      TextButton(
                                        child: Text("${RoverCameraResolution.values[roverCameraResIndex].width}x${RoverCameraResolution.values[roverCameraResIndex].height}"),
                                        onPressed: () {
                                          setState(() {
                                            if (++roverCameraResIndex == 3) {
                                              roverCameraResIndex = 0;
                                            }
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                verticalSeparator,
                                Visibility(
                                  visible: photographyIndex == 2,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Duration", style: TextStyle(color: Colors.white)),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 42,
                                            height: 36,
                                            child: TextField(
                                              maxLength: 2,
                                              keyboardType: TextInputType.number,
                                              onChanged: (String text) {
                                                setState(() {
                                                  if (text.isEmpty) {
                                                    videoMinutes = 0;
                                                  } else {
                                                    videoMinutes = int.parse(text);
                                                  }
                                                });
                                              },
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(color: Colors.white),
                                              decoration: InputDecoration(
                                                hintText: '0-100',
                                                counterText: '',
                                                hintStyle: TextStyle(color: Colors.grey.withOpacity(0.8)),
                                                contentPadding: const EdgeInsets.all(0),
                                              ),
                                            ),
                                          ),
                                          const Text("  :  ", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                          SizedBox(
                                            width: 42,
                                            height: 36,
                                            child: TextField(
                                              maxLength: 2,
                                              keyboardType: TextInputType.number,
                                              onChanged: (String text) {
                                                setState(() {
                                                  if (text.isEmpty) {
                                                    videoSeconds = 0;
                                                  } else {
                                                    videoSeconds = int.parse(text);
                                                  }
                                                  print(videoSeconds);
                                                });
                                              },
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(color: Colors.white),
                                              decoration: InputDecoration(
                                                hintText: '0-100',
                                                counterText: '',
                                                hintStyle: TextStyle(color: Colors.grey.withOpacity(0.8)),
                                                contentPadding: const EdgeInsets.all(0),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                verticalSeparator,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Camera", style: TextStyle(color: Colors.white)),
                                    TextButton(
                                      child: Text(RoverCameras.values[roverCameraIndex].name, style: TextStyle(color: Main.primaryColor)),
                                      onPressed: () {
                                        setState(() {
                                          if (++roverCameraIndex == 2) {
                                            roverCameraIndex = 0;
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            style: ButtonStyle(
                              side: MaterialStateProperty.all(BorderSide(
                                  color: !validatePhotographyCommand() ? Colors.grey : Main.primaryColor).copyWith(width: 2)),
                              backgroundColor: MaterialStateProperty.resolveWith((states) {
                                if (states.isNotEmpty) {
                                  if (MaterialState.hovered == states.first) {
                                    return Colors.transparent;
                                  }
                                }
                                return !validatePhotographyCommand() ? Colors.grey : Main.primaryColor.withOpacity(1.0);
                              }),
                            ),
                            onPressed: !validatePhotographyCommand() ? null : () {
                              setState(() {
                                Command command = PhotographyCommand(source: RoverCameras.values[roverCameraIndex], videoDuration: videoMinutes * 60 + videoSeconds,
                                    type: PhotographyType.values[photographyIndex], resolution: RoverCameraResolution.values[roverCameraResIndex], createdAt: DateTime.now());
                                command.onDeleted = () {
                                  setState(() {
                                    commands.remove(command);
                                  });
                                };
                                addCommand(command);
                              });
                            },
                            label: const Text("Add", style: TextStyle(color: Colors.white)),
                            icon: const Icon(Icons.add, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                  verticalSeparator,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommandContainer(
                        width: MediaQuery.of(context).size.width * 0.42,
                        height: isNavigationGPS && navCommandWaypoints.isEmpty ? 500 : 330,
                        iconWidget: Image.asset("lib/assets/icons/navigate-white.png", width: Main.iconSize * 2, height: Main.iconSize * 2),
                        titleWidget: Text("Navigation", style: commandContainerStyle),
                        detailsWidget: TextButton.icon(
                          label: Text(isNavigationGPS ? "GPS" : "Vector", style: const TextStyle(color: Main.primaryColor)),
                          icon: Icon(isNavigationGPS ? Icons.gps_fixed : CupertinoIcons.arrow_up_right_diamond, color: Main.primaryColor),
                          onPressed: () {
                            setState(() {
                              isNavigationGPS = !isNavigationGPS;
                            });
                          },
                        ),
                        contents: isNavigationGPS ? [
                          Visibility(
                            visible: navCommandWaypoints.isEmpty,
                            child: Column(
                              children: [
                                const Text("CURRENT LOCATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Longitude", style: TextStyle(color: Colors.white)),
                                    SizedBox(
                                      width: 90,
                                      height: 36,
                                      child: TextField(
                                        maxLength: 9,
                                        keyboardType: TextInputType.number,
                                        onChanged: (String text) {
                                          setState(() {
                                            beginLongitudeFieldStr = text;
                                          });
                                        },
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          hintText: '-180 - 180',
                                          counterText: '',
                                          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.8)),
                                          contentPadding: const EdgeInsets.all(0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                verticalSeparator,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Latitude", style: TextStyle(color: Colors.white)),
                                    SizedBox(
                                      width: 90,
                                      height: 36,
                                      child: TextField(
                                        maxLength: 8,
                                        keyboardType: TextInputType.number,
                                        onChanged: (String text) {
                                          setState(() {
                                            beginLatitudeFieldStr = text;
                                          });
                                        },
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          hintText: '-90 - 90',
                                          counterText: '',
                                          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.8)),
                                          contentPadding: const EdgeInsets.all(0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              const Text("DESTINATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Longitude", style: TextStyle(color: Colors.white)),
                                  SizedBox(
                                    width: 90,
                                    height: 36,
                                    child: TextField(
                                      maxLength: 9,
                                      keyboardType: TextInputType.number,
                                      onChanged: (String text) {
                                        setState(() {
                                          endLongitudeFieldStr = text;
                                        });
                                      },
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        hintText: '-180 - 180',
                                        counterText: '',
                                        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.8)),
                                        contentPadding: const EdgeInsets.all(0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              verticalSeparator,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Latitude", style: TextStyle(color: Colors.white)),
                                  SizedBox(
                                    width: 90,
                                    height: 36,
                                    child: TextField(
                                      maxLength: 8,
                                      keyboardType: TextInputType.number,
                                      onChanged: (String text) {
                                        setState(() {
                                          endLatitudeFieldStr = text;
                                        });
                                      },
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        hintText: '-90 - 90',
                                        counterText: '',
                                        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.8)),
                                        contentPadding: const EdgeInsets.all(0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          navigationCommandButtons,
                        ] : [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Distance (meters)", style: TextStyle(color: Colors.white)),
                              SizedBox(
                                width: 70,
                                height: 36,
                                child: TextField(
                                  maxLength: 6,
                                  keyboardType: TextInputType.number,
                                  onChanged: (String text) {
                                    setState(() {
                                      distanceFieldStr = text;
                                    });
                                  },
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: '0 - 2000',
                                    counterText: '',
                                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.8)),
                                    contentPadding: const EdgeInsets.all(0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Directional Angle (rel. north)", style: TextStyle(color: Colors.white)),
                              SizedBox(
                                width: 80,
                                height: 36,
                                child: TextField(
                                  maxLength: 7,
                                  keyboardType: TextInputType.number,
                                  onChanged: (String text) {
                                    setState(() {
                                      directionalAngleFieldStr = text;
                                    });
                                  },
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: '0 - 360',
                                    counterText: '',
                                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.8)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          navigationCommandButtons,
                        ],
                      ),
                      CommandContainer(
                        width: MediaQuery.of(context).size.width * 0.42,
                        height: 300,
                        titleWidget: Text("Sample Collection", style: commandContainerStyle),
                        iconWidget: Image.asset("lib/assets/icons/shovel-white.png", width: Main.iconSize * 1.8, height: Main.iconSize * 1.8),
                        detailsWidget: TextButton.icon(
                          label: Text(SampleType.values[sampleTypeIndex].name, style: const TextStyle(color: Main.primaryColor)),
                          icon: Image.asset("lib/assets/icons/${sampleTypeIndex == 0 ? "sand" : "drill"}-blue.png", width: Main.iconSize * 1.5, height: Main.iconSize * 1.5),
                          onPressed: () {
                            setState(() {
                              if (++sampleTypeIndex == 2) {
                                sampleTypeIndex = 0;
                              }
                            });
                          }
                        ),
                        contents: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Extraction Location", style: TextStyle(color: Colors.white)),
                              TextButton.icon(
                                label: Text(LocationType.values[locationTypeIndex].name, style: const TextStyle(color: Main.primaryColor)),
                                icon: Image.asset("lib/assets/icons/${locationTypeIndex == 0 ? "current-location" : "radius"}-blue.png", width: Main.iconSize * 1.5, height: Main.iconSize * 1.5),
                                onPressed: () {
                                  setState(() {
                                    if (++locationTypeIndex == 2) {
                                      locationTypeIndex = 0;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              const Divider(height: 10, thickness: 3),
              SizedBox(height: 220, child: ProcessTimelinePage(commands: commands, processIndex: processIndex)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(Colors.green.withOpacity(0.2)),
                    ),
                    label: Text("Resume", style: TextStyle(color: commands.isEmpty ? Colors.grey : Colors.green)),
                    icon: Icon(Icons.play_arrow, color: commands.isEmpty ? Colors.grey : Colors.green),
                    onPressed: commands.isEmpty ? null : () {
                      ;
                    },
                  ),
                  const SizedBox(width: 18),
                  TextButton.icon(
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(Colors.red.withOpacity(0.2)),
                    ),
                    label: Text("Pause", style: TextStyle(color: commands.isEmpty ? Colors.grey : Colors.red)),
                    icon: Icon(Icons.pause, color: commands.isEmpty ? Colors.grey : Colors.red),
                    onPressed: commands.isEmpty ? null : () {
                      ;
                    },
                  ),
                  const SizedBox(width: 18),
                  TextButton.icon(
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(Colors.orange.withOpacity(0.2)),
                    ),
                    label: Text("Clear Finished", style: TextStyle(color: commands.isEmpty ? Colors.grey : Colors.orange)),
                    icon: Icon(Icons.delete_rounded, color: commands.isEmpty ? Colors.grey : Colors.orange),
                    onPressed: commands.isEmpty ? null : () {
                      setState(() {
                        commands.removeRange(0, processIndex);
                        processIndex = 0;
                      });
                    },
                  ),
                  const SizedBox(width: 18),
                  TextButton.icon(
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(Colors.red.withOpacity(0.2)),
                    ),
                    label: Text("Clear All", style: TextStyle(color: commands.isEmpty ? Colors.grey : Colors.red)),
                    icon: Icon(Icons.clear, color: commands.isEmpty ? Colors.grey : Colors.red),
                    onPressed: commands.isEmpty ? null : () {
                      setState(() {
                        commands.clear();
                      });
                    },
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool validatePhotographyCommand() {

    switch(photographyIndex) {
      case 0: // panoramic
      case 1: // normal
        return true;
      case 2: // video
        return (videoSeconds > 0 || videoMinutes > 0) && (videoSeconds >= 0 || videoMinutes >= 0);
    }

    return false;

  }

  void addCommand(Command command) {

    commands.add(command);

  }

}

