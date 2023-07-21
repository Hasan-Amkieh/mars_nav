import 'package:flutter/material.dart';

import '../widgets/GalleryContainer.dart';

class ImageryPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        GalleryContainer(),
      ],
    );
  }

}

