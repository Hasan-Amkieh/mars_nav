import 'package:flutter/material.dart';

class CommandContainer extends StatelessWidget {

  final List<Widget> contents;
  final Widget iconWidget;
  final Widget titleWidget;
  final Widget? detailsWidget;
  final double width;
  final double height;
  final CrossAxisAlignment crossAxisAlignment;

  CommandContainer({required this.iconWidget, required this.titleWidget, required this.contents, required this.detailsWidget, required this.width, required this.height, this.crossAxisAlignment = CrossAxisAlignment.start});


  @override
  Widget build(BuildContext context) {

    return Container(
      width: width,
      height: height,
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
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: crossAxisAlignment,
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
              detailsWidget ?? const SizedBox(width: 0, height: 0),
            ],
          ),
          ...contents,
        ],
      ),
    );

  }



}
