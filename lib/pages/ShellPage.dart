import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_console_widget/flutter_console.dart";
import "package:mars_nav/main.dart";

class ShellPage extends StatefulWidget {

  ShellPage({super.key, required this.width, required this.height});
  double width, height;

  @override
  State<StatefulWidget> createState() {
    return ShellPageState();
  }

}
class ShellPageState extends State<ShellPage> {

  @override
  void initState() {
    super.initState();
    echoTimer ??= Timer.periodic(const Duration(milliseconds: 50), echoLoop);
    if (controllers.isEmpty) {
      controllers.add(Console(controller: FlutterConsoleController(), name: "Console 0"));
      tabs.add(FlutterConsole(controller: controllers.first.controller, height: widget.height, width: widget.width));
    }
  }

  static List<FlutterConsole> tabs = [];
  static List<Console> controllers = [];
  static List<Tab> tabBars = [];

  void echoLoop(timer) {
    for (int i = 0 ; i < controllers.length ; i++) {
      controllers[i].controller.scan().then((value) {
        controllers[i].controller.print(message: value, endline: true);
        controllers[i].controller.focusNode.requestFocus();
      });
    }
  }

  Timer? echoTimer;
  int _counter = 0;

  String newName = "";
  bool isTabAdded = false;

  void _updateTabs(context) {
    _counter = 0;
    tabBars = [];
    tabs.forEach((tab) {
      List<Widget> icons = [];
      if ((1+_counter) == tabs.length) {
         icons.add(IconButton(
           icon: Icon(Icons.add, color: Theme.of(context).primaryColor),
           onPressed: () {
             showDialog(
               context: context,
                 builder: (BuildContext context) {
                   TextEditingController _nameController = TextEditingController();
                   return AlertDialog(
                     backgroundColor: Main.scaffoldBackgroundColor,
                     title: const Text('Enter Console Name', style: TextStyle(color: Colors.white)),
                     content: TextField(
                       controller: _nameController,
                       style: const TextStyle(color: Colors.white),
                       decoration: InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: Colors.white), floatingLabelStyle: TextStyle(color: Theme.of(context).primaryColor)),
                     ),
                     actions: [
                       ElevatedButton(
                         onPressed: () {
                           isTabAdded = false;
                           Navigator.of(context).pop(); // Close the dialog
                         },
                         child: const Text('Cancel'),
                       ),
                       ElevatedButton(
                         onPressed: () {
                           newName = _nameController.text;
                           isTabAdded = true;
                           Navigator.of(context).pop();
                         },
                         child: const Text('OK'),
                       ),
                     ],
                   );
                 },
             ).then((name) {
               setState(() {
                 if (isTabAdded && newName.isNotEmpty) {
                   controllers.add(Console(controller: FlutterConsoleController(), name: newName));
                   tabs.add(FlutterConsole(controller: controllers.last.controller, height: widget.height, width: widget.width));
                 }
               });
             });
             ;
           },
         ));
      }
      if (tabs.length > 1) {
        icons.add(
          DeleteButton(parent: this, index: _counter),
        );
      }

      tabBars.add(Tab(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(controllers[_counter].name, style: const TextStyle(color: Colors.white)),
            Row(
              children: [
                ...icons,
              ],
            ),
          ],
        ),
      ));
      _counter++;
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (echoTimer != null) {
      echoTimer!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateTabs(context);

    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          TabBar(
            tabs: [
              ...tabBars,
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                ...tabs,
              ],
            ),
          )
        ],
      ),
    );
  }

}

class DeleteButton extends StatelessWidget {

  DeleteButton({required this.parent, required this.index});

  ShellPageState parent;
  int index;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete_outline, color: Colors.red),
      onPressed: () {
        parent.setState(() {
          ShellPageState.tabs.removeAt(index);
          ShellPageState.controllers.removeAt(index);
        });
      },
    );
  }

}

class Console {

  Console({required this.controller, required this.name});

  FlutterConsoleController controller;
  String name;

}
