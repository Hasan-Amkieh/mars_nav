import 'package:flutter/material.dart';

class NoConnectionWidget extends StatelessWidget {

  String msg;
  NoConnectionWidget({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(IconData(0xf89d), color: Colors.red),
        Text(msg, style: const TextStyle(color: Colors.red))
      ],
    );
  }



}
