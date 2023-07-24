import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thumblr/thumblr.dart';

import '../pages/ImageryPage.dart';

class GalleryContainer extends StatelessWidget {

  GalleryEntity entity;
  Thumbnail? thumb;

  GalleryContainer({required this.entity, this.thumb});

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(entity.fileName, style: const TextStyle(color: Colors.white, fontSize: 16)),
              IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {
                ;
              }),
            ],
          ),
          TextButton(
            child: thumb == null ? entity.viewImage : Container(decoration: BoxDecoration(color: Colors.black), child: RawImage(image: thumb!.image, width: 200, height: 200)),
            onPressed: () {
              ;
            },
          ),
        ],
      ),
    );

  }

}

