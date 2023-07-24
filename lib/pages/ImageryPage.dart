import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mars_nav/main.dart';
import 'package:mars_nav/widgets/VideoPlayer.dart';
import 'package:thumblr/thumblr.dart';

import '../widgets/GalleryContainer.dart';
import '../widgets/SearchBarWidget.dart';

enum GalleryType {
  image, video, other
}

enum GallerySource {
  drone, rover, other
}

class GalleryEntity { // The file name should have the format DATETIME_{D/R}_NAME.FILETYPE

  String fileName; // date & time and source type are all not included
  GalleryType type;
  GallerySource source;
  DateTime time;
  Widget viewImage;

  GalleryEntity({required this.fileName, required this.type, required this.source, required this.time, required this.viewImage});

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
    print("Type extension is $extension");

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

  static List<GalleryEntity> galleryElements = [];
  static List<Widget> galleryWidgets = [];

  Future<void> fetchGalleryWidgets() async {

    galleryElements = [];
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

        Widget? viewImage;
        Thumbnail? _thumb;
        if (galleryType == GalleryType.image) {
          print("Loading: ${file.path}");
          viewImage = Image.file(file, width: 200, height: 200);
        } else if (galleryType == GalleryType.video) {
          try {
            _thumb = await generateThumbnail(filePath: file.path, position: 0.0);
          } on PlatformException catch (e) {
            debugPrint('Failed to generate thumbnail: ${e.message}');
          } catch (e) {
            debugPrint('Failed to generate thumbnail: ${e.toString()}');
          }
        } else {
          viewImage = const Row(children: [Icon(Icons.cancel_outlined, color: Colors.red,), SizedBox(width: 8,) ,Text("Can't be displayed")],);
        }
        GalleryEntity entity = GalleryEntity(fileName: fileName, source: gallerySource, time: time, type: galleryType, viewImage: viewImage ?? Text("Error"));

        galleryElements.add(entity);
        galleryWidgets.add(GalleryContainer(entity: entity, thumb: _thumb));
      }
    }

  }

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
                        Image.asset("lib/icons/gallery-white.png", width: Main.iconSize, height: Main.iconSize),
                        const SizedBox(width: 10),
                        const Text("Gallery", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("lib/icons/camera-white.png", width: Main.iconSize, height: Main.iconSize),
                        const SizedBox(width: 10),
                        const Text("Visual Recording", style: TextStyle(color: Colors.white)),
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
                          SearchBarWidget(),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 24,
                            runSpacing: 24,
                            children: [
                              ...galleryWidgets
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

