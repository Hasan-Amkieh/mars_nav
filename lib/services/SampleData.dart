import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';


class RestorableSampleSelections extends RestorableProperty<Set<int>> {
  Set<int> _sampleSelections = {};

  bool isSelected(int index) => _sampleSelections.contains(index);

  void setDessertSelections(List<Sample> desserts) {
    final updatedSet = <int>{};
    for (var i = 0; i < desserts.length; i += 1) {
      var dessert = desserts[i];
      if (dessert.selected) {
        updatedSet.add(i);
      }
    }
    _sampleSelections = updatedSet;
    notifyListeners();
  }

  @override
  Set<int> createDefaultValue() => _sampleSelections;

  @override
  Set<int> fromPrimitives(Object? data) {
    final selectedItemIndices = data as List<dynamic>;
    _sampleSelections = {
      ...selectedItemIndices.map<int>((dynamic id) => id as int),
    };
    return _sampleSelections;
  }

  @override
  void initWithValue(Set<int> value) {
    _sampleSelections = value;
  }

  @override
  Object toPrimitives() => _sampleSelections.toList();
}

int _idCounter = 0;

enum SampleType {
  debris("Debris"), rock("Rock");

  const SampleType(this.name);
  final String name;
}

enum SampleStatus {
  undelivered, delivered
}

class Sample {

  Sample({required this.name, required this.time, required this.type,
    required this.weight, required this.NIR_result, required this.temperature,
    required this.humidity, required this.pH_level, required this.EC_level,
    required this.NPK_level, required this.status
  });

  final int id = _idCounter++;

  String name;
  final DateTime time;
  final SampleType type;
  final double weight;
  final String NIR_result;
  final double temperature;
  final double humidity;
  final double pH_level;
  final double EC_level;
  final double NPK_level;
  SampleStatus status;

  bool selected = false;

  bool isEqual(Sample sample) {
    return sample.name == name && sample.time.toUtc() == time.toUtc() && sample.type == type &&
        sample.weight == weight && sample.NIR_result == NIR_result && sample.temperature == temperature &&
        sample.humidity == humidity && sample.pH_level == pH_level && sample.EC_level == EC_level &&
        sample.NPK_level == NPK_level && sample.status == status;
  }

  @override
  String toString() {
    return '$name\n$time\nweight: $weight g\nType: ${type.name}\nNIR result: $NIR_result\ntemperature: $temperature C\nhumidity: $humidity%\npH level: $pH_level'
        '\nEC level: $EC_level\nnpk level: $NPK_level\nstatus: ${status.name}';
  }
}

class SampleDataSource extends DataTableSource {
  SampleDataSource.empty(this.context, this.updateParent) {
    samples = [];
  }

  Function updateParent;

  static int selectedCount = 0;

  SampleDataSource(this.context,
      this.updateParent,
      [sortedByCalories = false,
        this.hasRowTaps = false,
        this.hasRowHeightOverrides = false,
        this.hasZebraStripes = false]) {
    samples = samples_list;
  }

  final BuildContext context;
  late List<Sample> samples;
  bool hasRowTaps = false;
  bool hasRowHeightOverrides = false;
  bool hasZebraStripes = false;

  void sort<T>(Comparable<T> Function(Sample d) getField, bool ascending) {
    samples.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  void updateSelectedDesserts(RestorableSampleSelections selectedRows) {
    selectedCount = 0;
    for (var i = 0; i < samples.length; i += 1) {
      var sample = samples[i];
      if (selectedRows.isSelected(i)) {
        sample.selected = true;
        selectedCount += 1;
      } else {
        sample.selected = false;
      }
    }
    updateParent(() {});
    notifyListeners();
  }

  @override
  DataRow getRow(int index, [Color? color]) {
    assert(index >= 0);
    if (index >= samples.length) throw 'index > _samples.length';
    final sample = samples[index];
    return DataRow2.byIndex(
      index: index,
      selected: sample.selected,
      color: color != null
          ? MaterialStateProperty.all(color)
          : (hasZebraStripes && index.isEven
          ? MaterialStateProperty.all(Theme.of(context).highlightColor)
          : null),
      onSelectChanged: (value) {
        if (sample.selected != value) {
          selectedCount += value! ? 1 : -1;
          assert(selectedCount >= 0);
          sample.selected = value;
          notifyListeners();
        }
        updateParent(() {});
      },
      cells: [
        DataCell(Text(sample.name, style: const TextStyle(color: Colors.white))),
        DataCell(Text('${sample.time.day}/${sample.time.month}/${sample.time.year} ${sample.time.hour < 10 ? '0' : ''}${sample.time.hour}:${sample.time.minute < 10 ? '0' : ''}${sample.time.minute}', style: const TextStyle(color: Colors.white))),
        DataCell(Text(sample.type.name, style: const TextStyle(color: Colors.white))),
        DataCell(Text('${sample.weight}', style: const TextStyle(color: Colors.white))),
        DataCell(Text(sample.NIR_result, style: const TextStyle(color: Colors.white))),
        DataCell(Text('${sample.temperature}', style: const TextStyle(color: Colors.white))),
        DataCell(Text('${sample.humidity}', style: const TextStyle(color: Colors.white))),
        DataCell(Text('${sample.pH_level}', style: const TextStyle(color: Colors.white))),
        DataCell(Text('${sample.EC_level}', style: const TextStyle(color: Colors.white))),
        DataCell(Text('${sample.NPK_level}', style: const TextStyle(color: Colors.white))),
        DataCell(Text(sample.status.name, style: const TextStyle(color: Colors.white))),
      ],
    );
  }

  @override
  int get rowCount => samples.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => selectedCount;

  void selectAll(bool? checked) {
    for (final sample in samples) {
      sample.selected = checked ?? false;
    }
    selectedCount = (checked ?? false) ? samples.length : 0;
    notifyListeners();
  }
}

class DessertDataSourceAsync extends AsyncDataTableSource {

  DessertDataSourceAsync();

  DessertDataSourceAsync.empty() {
    _empty = true;
  }

  DessertDataSourceAsync.error() {
    _errorCounter = 0;
  }

  bool _empty = false;
  int? _errorCounter;

  RangeValues? _caloriesFilter;

  RangeValues? get caloriesFilter => _caloriesFilter;
  set caloriesFilter(RangeValues? calories) {
    _caloriesFilter = calories;
    refreshDatasource();
  }

  final DesertsFakeWebService _repo = DesertsFakeWebService();

  String _sortColumn = "name";
  bool _sortAscending = true;

  void sort(String columnName, bool ascending) {
    _sortColumn = columnName;
    _sortAscending = ascending;
    refreshDatasource();
  }

  Future<int> getTotalRecords() {
    return Future<int>.delayed(
        const Duration(milliseconds: 0), () => _empty ? 0 : _dessertsX3.length);
  }

  @override
  Future<AsyncRowsResponse> getRows(int start, int end) async {
    if (_errorCounter != null) {
      _errorCounter = _errorCounter! + 1;

      if (_errorCounter! % 2 == 1) {
        await Future.delayed(const Duration(milliseconds: 1000));
        throw 'Error #${((_errorCounter! - 1) / 2).round() + 1} has occurred';
      }
    }

    var index = start;
    assert(index >= 0);

    // List returned will be empty is there're fewer items than startingAt
    var x = _empty
        ? await Future.delayed(const Duration(milliseconds: 2000),
            () => DesertsFakeWebServiceResponse(0, []))
        : await _repo.getData(
        start, end, _caloriesFilter, _sortColumn, _sortAscending);

    var r = AsyncRowsResponse(
        x.totalRecords,
        x.data.map((sample) {
          return DataRow(
            key: ValueKey<int>(sample.id),
            selected: sample.selected,
            onSelectChanged: (value) {
              if (value != null) {
                setRowSelection(ValueKey<int>(sample.id), value);
              }
            },
            cells: [
              DataCell(Text(sample.name)),
              DataCell(Text('${sample.time}')),
              DataCell(Text(sample.type.name)),
              DataCell(Text('${sample.weight}')),
              DataCell(Text(sample.NIR_result)),
              DataCell(Text('${sample.temperature}')),
              DataCell(Text('${sample.humidity}')),
              DataCell(Text('${sample.pH_level}')),
              DataCell(Text('${sample.EC_level}')),
              DataCell(Text('${sample.NPK_level}')),
              DataCell(Text(sample.status.name)),
            ],
          );
        }).toList());

    return r;
  }
}

class DesertsFakeWebServiceResponse {
  DesertsFakeWebServiceResponse(this.totalRecords, this.data);

  final int totalRecords;

  final List<Sample> data;
}

class DesertsFakeWebService {
  int Function(Sample, Sample)? _getComparisonFunction(
      String column, bool ascending) {
    var coef = ascending ? 1 : -1;
    switch (column) {
      case 'name':
        return (Sample d1, Sample d2) => coef * d1.name.compareTo(d2.name);
      case 'Time':
        return (Sample d1, Sample d2) => coef * (d1.time.millisecondsSinceEpoch - d2.time.millisecondsSinceEpoch);
      case 'Type':
        return (Sample d1, Sample d2) => coef * (d1.type.index - d2.type.index).round();
      case 'Weight':
        return (Sample d1, Sample d2) => coef * (d1.weight - d2.weight).round();
      case 'NIR Result':
        return (Sample d1, Sample d2) => coef * (d1.NIR_result.compareTo(d2.NIR_result));
      case 'Temperature':
        return (Sample d1, Sample d2) => coef * (d1.temperature - d2.temperature).round();
      case 'Humidity':
        return (Sample d1, Sample d2) => coef * (d1.humidity - d2.humidity).round();
      case 'pH Level':
        return (Sample d1, Sample d2) => coef * (d1.pH_level - d2.pH_level).round();
      case 'EC Level':
        return (Sample d1, Sample d2) => coef * (d1.EC_level - d2.EC_level).round();
      case 'NPK Level':
        return (Sample d1, Sample d2) => coef * (d1.NPK_level - d2.NPK_level).round();
      case 'Sample Status':
        return (Sample d1, Sample d2) => coef * (d1.status.index - d2.status.index);
    }

    return null;
  }

  Future<DesertsFakeWebServiceResponse> getData(int startingAt, int count,
      RangeValues? caloriesFilter, String sortedBy, bool sortedAsc) async {
    return Future.delayed(
        Duration(
            milliseconds: startingAt == 0
                ? 2650
                : startingAt < 20
                ? 2000
                : 400), () {
      var result = _dessertsX3;

      result.sort(_getComparisonFunction(sortedBy, sortedAsc));
      return DesertsFakeWebServiceResponse(
          result.length, result.skip(startingAt).take(count).toList());
    });
  }
}

List<Sample> samples_list = [];

List<Sample> _dessertsX3 = samples_list.toList()
  ..addAll(samples_list.map((i) => Sample(name: '${i.name} x2', type: i.type, time: i.time,
      weight: i.weight, humidity: i.humidity, temperature: i.temperature,
      pH_level: i.pH_level, NPK_level: i.NPK_level, EC_level: i.EC_level, NIR_result: i.NIR_result, status: i.status)))
  ..addAll(samples_list.map((i) => Sample(name: '${i.name} x3', type: i.type, time: i.time,
      weight: i.weight, humidity: i.humidity, temperature: i.temperature,
      pH_level: i.pH_level, NPK_level: i.NPK_level, EC_level: i.EC_level, NIR_result: i.NIR_result, status: i.status)));
