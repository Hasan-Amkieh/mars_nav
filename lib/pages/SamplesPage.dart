import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import 'package:mars_nav/services/SampleData.dart';

class SamplesPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  ;
                },
                icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                label: const Text("Delete Samples", style: TextStyle(color: Colors.red)),
              ),
              IconButton(
                icon: Icon(Icons.picture_in_picture, color: Theme.of(context).primaryColor),
                onPressed: () {
                  ;
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 700, child: DataTable2ScrollupDemo()),
      ],
    );
  }

}


class DataTable2ScrollupDemo extends StatefulWidget {
  const DataTable2ScrollupDemo({super.key});

  @override
  DataTable2ScrollupDemoState createState() => DataTable2ScrollupDemoState();
}

class DataTable2ScrollupDemoState extends State<DataTable2ScrollupDemo> {
  bool _sortAscending = true;
  int? _sortColumnIndex;
  late DessertDataSource _dessertsDataSource;
  bool _initialized = false;
  final ScrollController _controller = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _dessertsDataSource = DessertDataSource(context);
      _initialized = true;
      _dessertsDataSource.addListener(() {
        setState(() {});
      });
    }
  }

  void _sort<T>(
      Comparable<T> Function(Sample d) getField,
      int columnIndex,
      bool ascending,
      ) {
    _dessertsDataSource.sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  void dispose() {
    _dessertsDataSource.dispose();
    _controller.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(children: [
          Theme(
            // These makes scroll bars almost always visible. If horizontal scroll bar
            // is displayed then vertical migh be hidden as it will go out of viewport
              data: ThemeData(
                  scrollbarTheme: ScrollbarThemeData(
                      thumbVisibility: MaterialStateProperty.all(true),
                      thumbColor:
                      MaterialStateProperty.all<Color>(Colors.black))),
              child: DataTable2(
                  scrollController: _controller,
                  horizontalScrollController: _horizontalController,
                  columnSpacing: 0,
                  horizontalMargin: 12,
                  bottomMargin: 10,
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  onSelectAll: (val) =>
                      setState(() => _dessertsDataSource.selectAll(val)),
                  columns: [
                    DataColumn2(
                      label: const Text('Sample', style: TextStyle(color: Colors.white)),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) =>
                          _sort<String>((d) => d.name, columnIndex, ascending),
                    ),
                    DataColumn2(
                      label: const Text('Time', style: TextStyle(color: Colors.white)),
                      size: ColumnSize.S,
                      numeric: false,
                      onSort: (columnIndex, ascending) =>
                          _sort<num>((d) => d.time.millisecondsSinceEpoch, columnIndex, ascending),
                    ),
                    DataColumn2(
                      label: const Text('Type', style: TextStyle(color: Colors.white)),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) =>
                          _sort<num>((d) => d.type.index, columnIndex, ascending),
                    ),
                    DataColumn2(
                      label: const Text('Weight (g)', style: TextStyle(color: Colors.white)),
                      size: ColumnSize.S,
                      numeric: true,
                      onSort: (columnIndex, ascending) =>
                          _sort<num>((d) => d.weight, columnIndex, ascending),
                    ),
                    DataColumn2(
                      label: const Text('NIR Result', style: TextStyle(color: Colors.white)),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) =>
                          _sort<String>((d) => d.NIR_result, columnIndex, ascending),
                    ),
                    DataColumn2(
                      label: const Text('Temperature (C°)', style: TextStyle(color: Colors.white)),
                      size: ColumnSize.S,
                      numeric: true,
                      onSort: (columnIndex, ascending) =>
                          _sort<num>((d) => d.temperature, columnIndex, ascending),
                    ),
                    DataColumn2(
                      label: const Text('Humidity', style: TextStyle(color: Colors.white)),
                      size: ColumnSize.S,
                      numeric: true,
                      onSort: (columnIndex, ascending) =>
                          _sort<num>((d) => d.humidity, columnIndex, ascending),
                    ),
                    DataColumn2(
                      label: const Text('pH Level', style: TextStyle(color: Colors.white)),
                      size: ColumnSize.S,
                      numeric: true,
                      onSort: (columnIndex, ascending) =>
                          _sort<num>((d) => d.pH_level, columnIndex, ascending),
                    ),
                    DataColumn2(
                      label: const Text('EC Level', style: TextStyle(color: Colors.white)),
                      size: ColumnSize.S,
                      numeric: true,
                      onSort: (columnIndex, ascending) =>
                          _sort<num>((d) => d.EC_level, columnIndex, ascending),
                    ),
                    DataColumn2(
                      label: const Text('NPK Level', style: TextStyle(color: Colors.white)),
                      size: ColumnSize.S,
                      numeric: true,
                      onSort: (columnIndex, ascending) =>
                          _sort<num>((d) => d.NPK_level, columnIndex, ascending),
                    ),
                    DataColumn2(
                      label: const Text('Sample Status', style: TextStyle(color: Colors.white)),
                      size: ColumnSize.S,
                      numeric: true,
                      onSort: (columnIndex, ascending) =>
                          _sort<num>((d) => d.status.index, columnIndex, ascending),
                    ),
                  ],
                  rows: List<DataRow>.generate(_dessertsDataSource.rowCount,
                          (index) => _dessertsDataSource.getRow(index)))),
          Positioned(
              bottom: 20,
              right: 0,
              child: _ScrollXYButton(_controller, '↑↑ go up ↑↑')),
          Positioned(
              bottom: 60,
              right: 0,
              child: _ScrollXYButton(_horizontalController, '←← go left ←←'))
        ]));
  }
}

class _ScrollXYButton extends StatefulWidget {
  const _ScrollXYButton(this.controller, this.title);

  final ScrollController controller;
  final String title;

  @override
  _ScrollXYButtonState createState() => _ScrollXYButtonState();
}

class _ScrollXYButtonState extends State<_ScrollXYButton> {
  bool _showScrollXY = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (widget.controller.position.pixels > 20 && !_showScrollXY) {
        setState(() {
          _showScrollXY = true;
        });
      } else if (widget.controller.position.pixels < 20 && _showScrollXY) {
        setState(() {
          _showScrollXY = false;
        });
      }
      // On GitHub there was a question on how to determine the event
      // of widget being scrolled to the bottom. Here's the sample
      // if (widget.controller.position.hasViewportDimension &&
      //     widget.controller.position.pixels >=
      //         widget.controller.position.maxScrollExtent - 0.01) {
      //   print('Scrolled to bottom');
      //}
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showScrollXY
        ? OutlinedButton(
      onPressed: () => widget.controller.animateTo(0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.grey[800]),
          foregroundColor: MaterialStateProperty.all(Colors.white)),
      child: Text(widget.title),
    )
        : const SizedBox();
  }
}