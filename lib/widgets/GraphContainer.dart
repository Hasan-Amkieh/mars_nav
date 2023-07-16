import 'package:flutter/material.dart';
import 'package:mars_nav/main.dart';

class GraphContainer extends StatelessWidget {

  final Widget graph;
  final Widget iconWidget;
  final Widget titleWidget;
  final Widget detailsWidget;
  final double sizeModifier;

  GraphContainer({required this.iconWidget, required this.titleWidget, required this.graph, required this.detailsWidget, required this.sizeModifier});


  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 6, 6),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  iconWidget,
                  const SizedBox(width: 20),
                  titleWidget,
                ],
              ),
              detailsWidget
            ],
          ),
          AspectRatio(aspectRatio: sizeModifier, child: graph),
        ],
      ),
    );

  }



}
