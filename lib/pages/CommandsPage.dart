import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:mars_nav/widgets/CommandContainer.dart";

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

  List<Command> commands = [];
  int photographyIndex = 0;
  int roverCameraResIndex = 0;
  int roverCameraIndex = 0;

  static TextStyle commandContainerStyle = const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16);
  static const verticalSeparator = SizedBox(height: 8);

  int videoSeconds = 0;
  int videoMinutes = 0;

  double beginLongitudeField = 0;
  double beginLatitudeField = 0;
  double endLongitudeField = 0;
  double endLatitudeField = 0;
  double distanceField = 0;
  double directionalAngleField = 0;
  bool isNavigationGPS = false;
  List<DirectionalVector> navCommandWaypoints = [];

  @override
  Widget build(BuildContext context) {
    Widget navigationCommandButtons = Row(
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
                    GPSLocation(latitude: beginLatitudeField, longitude: beginLongitudeField),
                    GPSLocation(latitude: endLatitudeField, longitude: endLongitudeField)));
              } else {
                navCommandWaypoints.add(DirectionalVector(distance: distanceField, compassAngle: directionalAngleField));
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
              addCommand(DelayCommand(toWait: Duration(hours: hours, minutes: minutes, seconds: seconds), createdAt: DateTime.now()));
            });
          },
          label: const Text("Add Command", style: TextStyle(color: Colors.white)),
          icon: const Icon(Icons.add, color: Colors.white),
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
                                addCommand(DelayCommand(toWait: Duration(hours: hours, minutes: minutes, seconds: seconds), createdAt: DateTime.now()));
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
                                            width: 36,
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
                                                  print(videoMinutes);
                                                });
                                              },
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(color: Colors.white),
                                              decoration: InputDecoration(
                                                hintText: '0',
                                                fillColor: Main.accentCanvasColor,
                                                filled: true,
                                                counterText: '',
                                                hintStyle: const TextStyle(color: Colors.white),
                                                contentPadding: const EdgeInsets.all(0),
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12)
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Text("  :  ", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                          SizedBox(
                                            width: 36,
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
                                                hintText: '0',
                                                fillColor: Main.accentCanvasColor,
                                                filled: true,
                                                counterText: '',
                                                hintStyle: const TextStyle(color: Colors.white),
                                                contentPadding: const EdgeInsets.all(0),
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12)
                                                ),
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
                                addCommand(DelayCommand(toWait: Duration(hours: hours, minutes: minutes, seconds: seconds), createdAt: DateTime.now()));
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
                        height: isNavigationGPS ? 500 : 300,
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
                                            if (text.isEmpty) {
                                              beginLongitudeField = 0;
                                            } else {
                                              beginLongitudeField = double.parse(text);
                                            }
                                          });
                                        },
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          hintText: '0',
                                          fillColor: Main.accentCanvasColor,
                                          filled: true,
                                          counterText: '',
                                          hintStyle: const TextStyle(color: Colors.white),
                                          contentPadding: const EdgeInsets.all(0),
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12)
                                          ),
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
                                            if (text.isEmpty) {
                                              beginLatitudeField = 0;
                                            } else {
                                              beginLatitudeField = double.parse(text);
                                            }
                                          });
                                        },
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          hintText: '0',
                                          fillColor: Main.accentCanvasColor,
                                          filled: true,
                                          counterText: '',
                                          hintStyle: const TextStyle(color: Colors.white),
                                          contentPadding: const EdgeInsets.all(0),
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12)
                                          ),
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
                                          if (text.isEmpty) {
                                            endLongitudeField = 0;
                                          } else {
                                            endLongitudeField = double.parse(text);
                                          }
                                        });
                                      },
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        hintText: '0',
                                        fillColor: Main.accentCanvasColor,
                                        filled: true,
                                        counterText: '',
                                        hintStyle: const TextStyle(color: Colors.white),
                                        contentPadding: const EdgeInsets.all(0),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12)
                                        ),
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
                                          if (text.isEmpty) {
                                            endLatitudeField = 0;
                                          } else {
                                            endLatitudeField = double.parse(text);
                                          }
                                        });
                                      },
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        hintText: '0',
                                        fillColor: Main.accentCanvasColor,
                                        filled: true,
                                        counterText: '',
                                        hintStyle: const TextStyle(color: Colors.white),
                                        contentPadding: const EdgeInsets.all(0),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12)
                                        ),
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
                                      if (text.isEmpty) {
                                        distanceField = 0;
                                      } else {
                                        distanceField = double.parse(text);
                                      }
                                    });
                                  },
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    fillColor: Main.accentCanvasColor,
                                    filled: true,
                                    counterText: '',
                                    hintStyle: const TextStyle(color: Colors.white),
                                    contentPadding: const EdgeInsets.all(0),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12)
                                    ),
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
                                      if (text.isEmpty) {
                                        directionalAngleField = 0;
                                      } else {
                                        directionalAngleField = double.parse(text);
                                      }
                                    });
                                  },
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    fillColor: Main.accentCanvasColor,
                                    filled: true,
                                    counterText: '',
                                    hintStyle: const TextStyle(color: Colors.white),
                                    contentPadding: const EdgeInsets.all(0),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12)
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          navigationCommandButtons,
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
              Text("Test 1 2 3...", style: TextStyle(color: Colors.white)),
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

