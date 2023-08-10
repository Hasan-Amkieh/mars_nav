import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:mars_nav/services/InfluxDBHandle.dart';

import 'package:mars_nav/services/SampleData.dart';

class SamplesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SamplesPageState();
  }
}

class SamplesPageState extends State<SamplesPage> {

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.red.withOpacity(0.2)),
                ),
                onPressed: SampleDataSource.selectedCount == 0 ? null : () {
                  List<Sample> toDelete = [];
                  SampleTableState.samplesDataSource.samples.forEach((element) {
                    if (element.selected) {
                      toDelete.add(element);
                    }
                  });
                  setState(() {
                    toDelete.forEach((element) async {
                      SampleTableState.samplesDataSource.samples.remove(element);
                      InfluxDBHandle().writeAllSamples(SampleTableState.samplesDataSource.samples);
                    });
                  });
                },
                icon: Icon(Icons.delete_forever_rounded, color: SampleDataSource.selectedCount == 0 ? Colors.grey : Colors.red),
                label: Text("Delete Samples", style: TextStyle(color: SampleDataSource.selectedCount == 0 ? Colors.grey : Colors.red)),
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
        SizedBox(height: MediaQuery.of(context).size.height * 0.9, child: SampleTable(updateParent: setState)),
      ],
    );
  }

}


class SampleTable extends StatefulWidget {
  SampleTable({super.key, required this.updateParent});

  Function updateParent;

  @override
  SampleTableState createState() => SampleTableState();
}

class SampleTableState extends State<SampleTable> {
  bool _sortAscending = true;
  int? _sortColumnIndex;
  static late SampleDataSource samplesDataSource;
  bool _initialized = false;
  final ScrollController _controller = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void initState() {
    super.initState();

    // InfluxDBHandle().writeAllSamples([Sample(
    //       name: 'Playground1 Sample',
    //       time: DateTime.now().subtract(Duration(minutes: 30)),
    //       type: SampleType.rock,
    //       weight: 12,
    //       NIR_result: "Any",
    //       temperature: 15,
    //       humidity: 14,
    //       pH_level: 10,
    //       EC_level: 15,
    //       NPK_level: 50,
    //       status: SampleStatus.undelivered,
    //     ),
    //     Sample(
    //       name: 'Playground 2 Sample',
    //       time: DateTime.now().subtract(Duration(hours: 20)),
    //       type: SampleType.debris,
    //       weight: 37,
    //       NIR_result: "Any",
    //       temperature: 129,
    //       humidity: 8,
    //       pH_level: 1,
    //       EC_level: 16,
    //       NPK_level: 5,
    //       status: SampleStatus.delivered,
    //     )]);

    InfluxDBHandle().readAllSamples().then((List<Sample> samples) {
      setState(() {
        samplesDataSource.samples = samples;
        samples_list = samples;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      samplesDataSource = SampleDataSource(context, widget.updateParent);
      _initialized = true;
      samplesDataSource.addListener(() {
        setState(() {});
      });
    }
  }

  void _sort<T>(
      Comparable<T> Function(Sample d) getField,
      int columnIndex,
      bool ascending,
      ) {
    samplesDataSource.sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  void dispose() {
    samplesDataSource.dispose();
    _controller.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(12),
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
                      setState(() {
                        samplesDataSource.selectAll(val);
                        widget.updateParent((){});
                      }),
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
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) =>
                          _sort<num>((d) => d.temperature, columnIndex, ascending),
                    ),
                    DataColumn2(
                      label: const Text('Humidity', style: TextStyle(color: Colors.white)),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) =>
                          _sort<num>((d) => d.humidity, columnIndex, ascending),
                    ),
                    DataColumn2(
                      label: const Text('pH Level', style: TextStyle(color: Colors.white)),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) =>
                          _sort<num>((d) => d.pH_level, columnIndex, ascending),
                    ),
                    DataColumn2(
                      label: const Text('EC Level', style: TextStyle(color: Colors.white)),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) =>
                          _sort<num>((d) => d.EC_level, columnIndex, ascending),
                    ),
                    DataColumn2(
                      label: const Text('NPK Level', style: TextStyle(color: Colors.white)),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) =>
                          _sort<num>((d) => d.NPK_level, columnIndex, ascending),
                    ),
                    DataColumn2(
                      label: const Text('Sample Status', style: TextStyle(color: Colors.white)),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) =>
                          _sort<num>((d) => d.status.index, columnIndex, ascending),
                    ),
                  ],
                  rows: List<DataRow>.generate(samplesDataSource.rowCount,
                          (index) => samplesDataSource.getRow(index)))),
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