import 'package:flutter/material.dart';

class GraphContainer extends StatelessWidget {

  Widget graph;
  Widget iconWidget;
  Widget titleWidget;
  double sizeModifier;

  GraphContainer({required this.iconWidget, required this.titleWidget, required this.graph, required this.sizeModifier});


  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.fromLTRB(12, 12, 6, 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
        colors: [
          Color(0xFF3D4D5D).withOpacity(0.3),
          Color(0xff33454f).withOpacity(0.6),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              iconWidget,
              const SizedBox(width: 20),
              titleWidget,
            ],
          ),
          AspectRatio(aspectRatio: sizeModifier, child: graph),
        ],
      ),
    );

  }



}
