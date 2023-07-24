import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mars_nav/widgets/VideoPlayer.dart';
import 'package:thumblr/thumblr.dart';
import 'package:photo_view/photo_view.dart';

import '../main.dart';
import '../pages/ImageryPage.dart';

class GalleryContainer extends StatelessWidget {

  GalleryEntity entity;
  Thumbnail? thumb;

  GalleryContainer({required this.entity, this.thumb});

  String toRename = "";

  Widget build(context) {

    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3D4D5D).withOpacity(0.3),
            const Color(0xff33454f).withOpacity(0.6),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(12, 8, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(entity.fileName, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 16))),
                IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {
                  final RenderBox button = context.findRenderObject() as RenderBox;
                  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

                  // Calculate the position to show the menu below the button
                  final RelativeRect position = RelativeRect.fromRect(
                    Rect.fromPoints(
                      button.localToGlobal(Offset.zero, ancestor: overlay),
                      button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                    ),
                    Offset.zero & overlay.size,
                  );

                  // Show the popup menu
                  showMenu(
                    context: context,
                    position: position,
                    items: [
                      const PopupMenuItem<String>(
                        value: "Rename",
                        child: Text("Rename"),
                      ),
                      const PopupMenuItem<String>(
                        value: "Delete",
                        child: Text("Delete"),
                      ),
                    ],
                  ).then((value) {
                    switch(value) {
                      case "Rename":
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Main.scaffoldBackgroundColor,
                              title: Text("Rename", style: TextStyle(color: Colors.white)),
                              content: TextField(
                                style: TextStyle(color: Colors.white),
                                onChanged: (value) {
                                  toRename = value;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'New Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close the dialog
                                  },
                                  child: const Text('BACK'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    File(entity.fullFileName)
                                        .renameSync(entity.fullFileName.replaceFirst(entity.fileName, toRename, entity.fullFileName.lastIndexOf(entity.fileName) - 1));
                                    Navigator.of(context).pop(); // Close the dialog
                                  },
                                  child: const Text('RENAME'),
                                ),
                              ],
                            );
                          },
                        );
                        break;
                      case "Delete":
                        File(entity.fullFileName).deleteSync();
                        break;
                    }
                  });
                }),
              ],
            ),
          ),
          TextButton(
            child: thumb == null ? Image.file(File(entity.fullFileName), width: 200, height: 200,)
                : Container(decoration: const BoxDecoration(color: Colors.black), child: RawImage(image: thumb!.image, width: 200, height: 200)),
            onPressed: () {
              Widget content;
              if (entity.type == GalleryType.image) {
                content = SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: PhotoView(
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    imageProvider: Image.file(
                        File(entity.fullFileName),
                    ).image,
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.contained * 3,
                  ),
                );
              } else if (entity.type == GalleryType.video) {
                content = SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: VideoPlayer(filePath: entity.fullFileName));
              } else {
                content = const Text("This file can't be shown!");
              }

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Main.scaffoldBackgroundColor,
                    content: Column(
                      children: [
                        Text(
                            "${entity.fileName}\nTaken from ${entity.source.name}\n${entity.time.toString().split('.')[0]}\n",
                            style: const TextStyle(color: Colors.white, fontSize: 18)
                        ),
                        content,
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: const Text('BACK'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );

  }

}

