import 'package:flutter/material.dart';

class ToggleButton extends StatefulWidget {
  final String text;
  bool isSelected;
  late ToggleButtonState state;

  ToggleButton({required this.text, required this.isSelected});

  @override
  ToggleButtonState createState() {
    return state = ToggleButtonState();
  }
}

class ToggleButtonState extends State<ToggleButton> {
  bool isSelected = false;

  @override
  void initState() {
    isSelected = widget.isSelected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isSelected = !isSelected;
          widget.isSelected = isSelected;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
      ),
      child: Text(widget.text),
    );
  }
}