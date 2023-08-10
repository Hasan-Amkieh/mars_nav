import 'dart:io';
import 'dart:math';

import 'package:influxdb_client/api.dart';

import '../main.dart';
import 'SampleData.dart';

class InfluxDBHandle {

  InfluxDBHandle._();

  bool _isInitted = false;
  late InfluxDBClient _client;
  late QueryService _queryService;

  static const bucketId = "84f6a696ed2d0d2d";
  static const orgId = "ee1fbc21f5685216";
  static const bucket = "ATU-ROVER";
  static const org = "ATU-ROVER";
  static const username = "hassan1551";
  static const pass = "susu12134";
  static const token = "u8kIvdK-KLv_ttutkxfSc2Gb7xUI-8K0oWGl6-QmrNbBVB7FmX79KM6ljL6yPPMb909mBG4JjpG4hYLjrKBS-Q==";
  static const url = "http://localhost:8086";

  static const Map<String, String> valueNames = {
    'temperature' : 'temperature',
    'humidity' : 'humidity',
    'air-pressure' : 'Air Pressure',
    'drone-altitude' : 'Drone Altitude',
    'light-intensity' : 'Light Intensity',
    'UV-light-intensity' : 'UV Light Intensity',
    'rover-signal-strength' : 'Rover Signal Strength',
    'x-angle' : 'x Angle',
    'y-angle' : 'y Angle',
    'compass-angle' : 'Compass Angle',
    'rover-speed' : 'Rover Speed',
    'CPU-util' : 'CPU Util',
    'GPU-util' : 'GPU Util',
    'used-RAM' : 'Used RAM',
    'battery-voltage' : 'Battery Voltage',
    'power-consumption' : 'Power Consumption',
    'CO' : 'CO',
    'CO2' : 'CO₂',
    'CH4 C4H10 C3H8' : 'CH₄ C₄H₁₀ C₃H₈',
    'NH3 NO2 C6H6' : 'NH₃ NO₂ C₆H₆',
    'H2' : 'H₂',
    'electrical-current' : 'Electrical Current',
    'motors-current' : 'Motors Current',
    'PM1.0' : 'PM1.0',
    'PM2.5' : 'PM2.5',
    'PM10.0' : 'PM10.0',
  };

  void init() async {

    if (!_isInitted) {

      _isInitted = true;
      _client = InfluxDBClient(
          url: url,
          token: token,
          org: org,
          bucket: bucket,
          username: username,
          password: pass,
          debug: true
      );

      _queryService = _client.getQueryService(queryOptions: QueryOptions(
          gzip: true
      ));

      // for (int i = 0; i < 1000; i++) {
      //   DateTime randomDateTime = generateRandomDateTime();
      //   String randomValueName = generateRandomValueName();
      //   double randomValue = generateRandomValue();
      //
      //   write(randomDateTime, randomValueName, randomValue);
      // }

    } else {
      print("InfluxDB client has already been initialized");
    }
  }

  static DateTime generateRandomDateTime() {
    Random random = Random();
    DateTime now = DateTime.now();
    DateTime startDate = DateTime(now.year, now.month - 1, 1);
    DateTime endDate = now;

    // 2592000000 is equivalent to 30 days in milliseconds
    int randomMilliseconds = min(2592000000, random.nextInt(min(2592000000, (endDate.millisecondsSinceEpoch - startDate.millisecondsSinceEpoch).abs())));
    return startDate.add(Duration(milliseconds: randomMilliseconds));
  }

  static String generateRandomValueName() {
    Random random = Random();
    return valueNames.keys.toList()[random.nextInt(valueNames.length)];
  }

  static double generateRandomValue() {
    Random random = Random();
    return random.nextDouble() * 100; // Random value between 0 and 100
  }

  void close() {

    _client.close();

  }

  Future<List<String>> read(DateTime from, DateTime to, List<String> sensorNames) async {

    String measurementPredicate = "";
    sensorNames.forEach((element) {
      if (measurementPredicate.isEmpty) {
        measurementPredicate = 'r["_measurement"] == "$element"';
      } else {
        measurementPredicate += ' or r["_measurement"] == "$element"';
      }
    });

    var query = '''from(bucket: "$bucket") |> range(start: ${from.millisecondsSinceEpoch ~/ 1000}, stop: ${to.millisecondsSinceEpoch ~/ 1000}) |> filter(fn: (r) => $measurementPredicate)''';

    // print(query);

    List<String> recordsFormatted = [];
    var records = await _queryService.query(query);
    await records.forEach((record) {
      recordsFormatted.add('${record['_time']} | ${record['_measurement']} | ${record['_value']}');
    });

    return recordsFormatted;

  }

  Future<Map<String, int>> countByDays(DateTime from, DateTime to) async {

    String query = """from(bucket: "$bucket")
    |> range(start: ${from.millisecondsSinceEpoch ~/ 1000}, stop: ${to.millisecondsSinceEpoch ~/ 1000})
    |> aggregateWindow(every: 1d, fn: count)""";

    final result = await _queryService.query(query);
    Map<String, int> counts = {};

    await result.forEach((record) {
      if (valueNames.containsKey(record['_measurement'])) {
        if (counts.containsKey(record['_time'])) {
          counts[record['_time']] = (counts[record['_time']]! + record['_value']).toInt();
        } else {
          counts[record['_time']] = record['_value'];
        }
      }
    });

    return counts;

  }

  void write(DateTime time, String valueName, double value) async {

    final writeApi = _client.getWriteService(WriteOptions(
      batchSize: 100,
      flushInterval: 5000, // meaning it will wait for 5 seconds or for the batch size to get to 100 points and then submit
    ));

    String point = "$valueName value=$value ${time.millisecondsSinceEpoch * 1000000}";
    // print("Writing $point");

    writeApi.write(point).then((value) {
      print('Write completed');
    }).catchError((exception) {
      // error block
      print("Handle write error here!");
      print(exception);
    });

  }

  Future<List<Sample>> readAllSamples() async {

    List<Sample> samples = [];
    List<String> contents = [];

    final File sampleFile = File(Main.appDir + r"\mars_nav\samples.txt");
    if (sampleFile.existsSync()) {
      ((await sampleFile.readAsString()).split("\r\n*-*-*\r\n")).forEach((line) {
        // print("Line is $line");
        contents = line.split(',');
        samples.add(Sample(name: contents[0], time: DateTime.fromMillisecondsSinceEpoch(int.parse(contents[1])),
            type: SampleType.rock.name == contents[2] ? SampleType.rock : SampleType.debris, weight: double.parse(contents[3]),
            NIR_result: contents[4], temperature: double.parse(contents[5]), humidity: double.parse(contents[6]),
            pH_level: double.parse(contents[7]), EC_level: double.parse(contents[8]), NPK_level: double.parse(contents[9]),
            status: SampleStatus.delivered.name == contents[10] ? SampleStatus.delivered : SampleStatus.undelivered));
      });
    } else {
      sampleFile.createSync();
    }

    return samples;

  }

  void writeAllSamples(List<Sample> samples) {

    String toWrite = "";
    const separator = "\r\n*-*-*\r\n"; // 9 characters

    for (int i = 0 ; i < samples.length ; i++) {
      if ((i+1) == samples.length) {
        toWrite += "${samples[i].name},${samples[i].time.millisecondsSinceEpoch},${samples[i].type.name},${samples[i].weight},"
            "${samples[i].NIR_result},${samples[i].temperature},${samples[i].humidity},${samples[i].pH_level},${samples[i].EC_level},"
            "${samples[i].NPK_level},${samples[i].status.name}";
        break;
      } else {
        toWrite += "${samples[i].name},${samples[i].time.millisecondsSinceEpoch},${samples[i].type.name},${samples[i].weight},"
            "${samples[i].NIR_result},${samples[i].temperature},${samples[i].humidity},${samples[i].pH_level},${samples[i].EC_level},"
            "${samples[i].NPK_level},${samples[i].status.name} $separator";
      }
    }

    final File sampleFile = File(Main.appDir + r"\mars_nav\samples.txt");
    if (!sampleFile.existsSync()) {
      sampleFile.createSync();
    }
    sampleFile.writeAsStringSync(toWrite, flush: true);

  }

  static final InfluxDBHandle _instance = InfluxDBHandle._();

  factory InfluxDBHandle() => _instance;

}