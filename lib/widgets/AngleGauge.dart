import 'package:flutter/material.dart';
import 'package:geekyants_flutter_gauges/geekyants_flutter_gauges.dart';

class AngleGauge extends StatefulWidget {

  AngleGauge({required this.angle, required this.color, required this.thickness, required this.height});
  double angle;
  Color color;
  double thickness;
  double height;

  @override
  State<StatefulWidget> createState() {
    return  AngleGaugeState();
  }

}

class AngleGaugeState extends State<AngleGauge> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;


  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.angle,
    ).animate(_controller);

    _controller.forward();
  }

  @override
  void didUpdateWidget(AngleGauge oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.angle != oldWidget.angle) {
      _animation = Tween<double>(
        begin: oldWidget.angle,
        end: widget.angle,
      ).animate(_controller);

      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  //   setState(() { // This will change the value of the gauge with an animation
  //     widget.value -= 30;
  //         _animation = Tween<double>(
  //         begin: _animation.value,
  //         end: widget.value,
  //       ).animate(_controller);
  //
  //       _controller.forward(from: 0.0);
  //   });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return LinearGauge(
              gaugeOrientation: GaugeOrientation.vertical,
              start: 0,
              end: 180,
              steps: 60,
              valueBar: [
                ValueBar(
                  color: widget.color,
                  valueBarThickness: widget.thickness,
                  value: _animation.value,
                  position: ValueBarPosition.center,
                  borderRadius: 12,
                )
              ],
              enableGaugeAnimation: true,
              animationDuration: 1000,
              linearGaugeBoxDecoration: LinearGaugeBoxDecoration(thickness: widget.thickness),
              rulers: RulerStyle(
                textStyle: const TextStyle(color: Color(0xffcccccc), fontSize: 10),
                primaryRulerColor: const Color(0xff5ad1e6),
                secondaryRulerColor: const Color(0xff00e5ff),
                rulerPosition: RulerPosition.left,
              ),
            );
          },
        ),
      ),
    );
  }
}