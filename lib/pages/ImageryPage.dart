import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mars_nav/main.dart';
import 'package:thumblr/thumblr.dart';

import '../widgets/GalleryContainer.dart';
import '../widgets/SearchBarWidget.dart';

enum GalleryType {
  image, video, other
}

enum GallerySource {
  drone("DRONE"), rover("ROVER"), other("OTHERS");
  const GallerySource(this.name);

  final String name;
}

class GalleryEntity { // The file name should have the format DATETIME_{D/R}_NAME.FILETYPE

  String fileName; // date & time and source type are all not included
  GalleryType type;
  GallerySource source;
  DateTime time;
  String fullFileName;

  GalleryEntity({required this.fileName, required this.type, required this.source, required this.time, required this.fullFileName});

}

class ImageryPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return ImageryPageState();
  }

}

class ImageryPageState extends State {

  static GalleryType classifyFile(String fileName) {

    String extension = fileName.toLowerCase().split('.').last;

    if (Main.imageExtensions.contains(extension)) {
      return GalleryType.image;
    } else if (Main.videoExtensions.contains(extension)) {
      return GalleryType.video;
    } else {
      return GalleryType.other;
    }

  }

  static GallerySource classifySource(String type) {

    switch (type) {
      case "D":
        return GallerySource.drone;
      case "R":
        return GallerySource.rover;
      default:
        return GallerySource.other;
    }

  }

  static List<GalleryContainer> galleryWidgets = [];

  Future<void> fetchGalleryWidgets() async {

    galleryWidgets = [];

    Directory dir = Directory(Main.appDir + r'\mars_nav\imagery');
    for (FileSystemEntity file in dir.listSync()) {
      if (file is File) {
        String fileNameFull = file.path.split('\\').last;
        List<String> fileNameSegments = fileNameFull.split("_");
        String fileName = fileNameSegments.last.split(".").first;
        GalleryType galleryType = classifyFile(fileNameFull);
        GallerySource gallerySource = classifySource(fileNameSegments[1]);
        DateTime time = DateTime.parse(fileNameSegments[0].replaceAll(".", ":"));

        Thumbnail? thumb;
        if (galleryType == GalleryType.video) {
          try {
            thumb = await generateThumbnail(filePath: file.path, position: 0.0);
          } on PlatformException catch (e) {
            debugPrint('Failed to generate thumbnail: ${e.message}');
          } catch (e) {
            debugPrint('Failed to generate thumbnail: ${e.toString()}');
          }
        }
        GalleryEntity entity = GalleryEntity(fileName: fileName, source: gallerySource, time: time, type: galleryType, fullFileName: file.path, );

        galleryWidgets.add(GalleryContainer(entity: entity, thumb: thumb));
      }
    }

  }

  bool isRoverOn = false;
  bool isDroneOn = false;
  bool isImageOn = false;
  bool isCameraOn = false;

  String searchText = "";

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchGalleryWidgets(),
      builder: (context, snapshot) {
        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("lib/assets/icons/gallery-white.png", width: Main.iconSize, height: Main.iconSize),
                        const SizedBox(width: 10),
                        const Text("Gallery", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("lib/assets/icons/camera-white.png", width: Main.iconSize, height: Main.iconSize),
                        const SizedBox(width: 10),
                        const Text("Streaming & Recording", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              SizedBox(width: MediaQuery.of(context).size.width * 0.7, child: SearchBarWidget(onChanged: (String newText) {
                                setState(() {
                                  searchText = newText;
                                });
                              })),
                              const SizedBox(width: 16),
                              Column(
                                children: [
                                  TextButton(
                                    child: Image.asset("lib/assets/icons/drone-${isDroneOn ? "white" : "black"}.png", width: Main.iconSize * 1.5, height: Main.iconSize * 1.5),
                                    onPressed: () {
                                      setState(() {
                                        isDroneOn = !isDroneOn;
                                        if (isRoverOn) {
                                          isRoverOn = false;
                                        }
                                      });
                                    },
                                  ),
                                  TextButton(
                                    child: Image.asset("lib/assets/icons/rover-${isRoverOn ? "white" : "black"}.png", width: Main.iconSize * 1.5, height: Main.iconSize * 1.5),
                                    onPressed: () {
                                      setState(() {
                                        isRoverOn = !isRoverOn;
                                        if (isDroneOn) {
                                          isDroneOn = false;
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Column(
                                children: [
                                  TextButton(
                                    child: Image.asset("lib/assets/icons/imagery-${isImageOn ? "white" : "black"}.png", width: Main.iconSize * 1.2, height: Main.iconSize * 1.2),
                                    onPressed: () {
                                      setState(() {
                                        isImageOn = !isImageOn;
                                        if (isCameraOn) {
                                          isCameraOn = false;
                                        }
                                      });
                                    },
                                  ),
                                  TextButton(
                                    child: Image.asset("lib/assets/icons/camera-${isCameraOn ? "white" : "black"}.png", width: Main.iconSize * 1.5, height: Main.iconSize * 1.5),
                                    onPressed: () {
                                      setState(() {
                                        isCameraOn = !isCameraOn;
                                        if (isImageOn) {
                                          isImageOn = false;
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 24,
                            runSpacing: 24,
                            children: [
                              ...galleryWidgets.where((element) {
                                if (!isImageOn && !isCameraOn) {
                                  if (isDroneOn) {
                                    return element.entity.source == GallerySource.drone;
                                  }
                                  if (isRoverOn) {
                                    return element.entity.source == GallerySource.rover;
                                  }
                                }

                                if (isImageOn) {
                                  if (element.entity.type == GalleryType.image) {
                                    if (isDroneOn) {
                                      return element.entity.source == GallerySource.drone;
                                    }
                                    if (isRoverOn) {
                                      return element.entity.source == GallerySource.rover;
                                    }
                                  } else {
                                    return false;
                                  }
                                }

                                if (isCameraOn) {
                                  if (element.entity.type == GalleryType.video) {
                                    if (isDroneOn) {
                                      return element.entity.source == GallerySource.drone;
                                    }
                                    if (isRoverOn) {
                                      return element.entity.source == GallerySource.rover;
                                    }
                                  }
                                  else {
                                    return false;
                                  }
                                }

                                return true;
                              }).toList(),
                            ],
                          )
                        ],
                      ),
                    ),

                    const Center(child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning, color: Colors.red),
                        Text("UNDER DEVELOPMENT", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ],
                    )),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}

