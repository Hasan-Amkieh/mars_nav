import 'package:flutter/material.dart';


class CompassWidget extends StatefulWidget {

  double angle;

  CompassWidget({required this.angle});

  @override
  State<StatefulWidget> createState() {
    return CompassWidgetState();
  }

}

class CompassWidgetState extends State<CompassWidget> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;
  double _rotationAngle = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Set the animation duration as needed
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.bounceInOut);

    _animation.addListener(() {
      setState(() {
        _rotationAngle = _controller.value * widget.angle; // Rotate image from 0 to "angle value" degrees
      });
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAngle * 0.0174533, // Convert degrees to radians
          child: Image.asset(
            'lib/assets/icons/compass.png', // Replace with the asset path of your image
            width: 200,
            height: 200,
          ),
        );
      },
    );
  }

}

