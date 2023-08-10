import "package:flutter/material.dart";
import "package:mars_nav/widgets/CommandContainer.dart";

import "../main.dart";

class CommandsPage extends StatelessWidget {

  const CommandsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                CommandContainer(
                  width: MediaQuery.of(context).size.width * 0.45,
                  height: 300,
                  iconWidget: const Icon(Icons.more_time_outlined, color: Colors.white, size: Main.iconSize * 2),
                  titleWidget: const Text("Delay", style: TextStyle(color: Colors.white)),
                  detailsWidget: Text("Yolo!"),
                  content: Column(
                    children: [
                      Text("Uoo!")
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [

            ],
          ),
        ],
      ),
    );
  }

}

