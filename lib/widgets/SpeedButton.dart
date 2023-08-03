import 'package:flutter/material.dart';

class SpeedButton extends StatefulWidget {

  void Function(double) onPress;

  SpeedButton({required this.onPress});

  @override
  State<StatefulWidget> createState() {
    return SpeedButtonState();
  }

}

class SpeedButtonState extends State<SpeedButton> {

  static List<double> speeds = [0.5, 1, 2, 3];
  int speedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text('x ${speeds[speedIndex]}'),
      onPressed: () {
        setState(() {
          if (++speedIndex == speeds.length) {
            speedIndex = 0;
          }
          widget.onPress(speeds[speedIndex]);
        });
      },
    );
  }

}
