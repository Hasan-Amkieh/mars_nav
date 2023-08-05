import 'dart:math';

import 'package:influxdb_client/api.dart';

import 'SampleData.dart';

class InfluxDBHandle {

  InfluxDBHandle._();

  bool _isInitted = false;
  late InfluxDBClient _client;
  late QueryService queryService;

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

      queryService = _client.getQueryService(queryOptions: QueryOptions(
          gzip: true
      ));

      // List<Sample> samples = <Sample>[
      //   Sample(
      //     name: 'Playground1 Sample',
      //     time: DateTime.now().subtract(Duration(minutes: 30)),
      //     type: SampleType.rock,
      //     weight: 12,
      //     NIR_result: "Any",
      //     temperature: 15,
      //     humidity: 14,
      //     pH_level: 10,
      //     EC_level: 15,
      //     NPK_level: 50,
      //     status: SampleStatus.undelivered,
      //   ),
      //   Sample(
      //     name: 'Playground 2 Sample',
      //     time: DateTime.now().subtract(Duration(hours: 20)),
      //     type: SampleType.debris,
      //     weight: 37,
      //     NIR_result: "Any",
      //     temperature: 129,
      //     humidity: 8,
      //     pH_level: 1,
      //     EC_level: 16,
      //     NPK_level: 5,
      //     status: SampleStatus.delivered,
      //   ),
      //   Sample(
      //     name: 'Eclair',
      //     time: DateTime.now().subtract(Duration(hours: 40)),
      //     type: SampleType.rock,
      //     weight: 24,
      //     NIR_result: "Any",
      //     temperature: 337,
      //     humidity: 6,
      //     pH_level: 7,
      //     EC_level: 10,
      //     NPK_level: 550,
      //     status: SampleStatus.undelivered,
      //   ),
      //   Sample(
      //     name: 'Cupcake',
      //     time: DateTime.now().subtract(Duration(days: 20)),
      //     type: SampleType.rock,
      //     weight: 67,
      //     NIR_result: "Any",
      //     temperature: 413,
      //     humidity: 3,
      //     pH_level: 8,
      //     EC_level: 69,
      //     NPK_level: 70,
      //     status: SampleStatus.undelivered,
      //   ),
      //   Sample(
      //     name: 'Gingerbread',
      //     time: DateTime.now().subtract(Duration(minutes: 10)),
      //     type: SampleType.debris,
      //     weight: 49,
      //     NIR_result: "Any",
      //     temperature: 327,
      //     humidity: 7,
      //     pH_level: 16,
      //     EC_level: 20,
      //     NPK_level: 10,
      //     status: SampleStatus.delivered,
      //   ),
      //   Sample(
      //     name: 'Jelly Bean',
      //     time: DateTime.now().subtract(Duration(minutes: 5)),
      //     type: SampleType.debris,
      //     weight: 94,
      //     NIR_result: "Any",
      //     temperature: 50,
      //     humidity: 0,
      //     pH_level: 0,
      //     EC_level: 105,
      //     NPK_level: 2,
      //     status: SampleStatus.delivered,
      //   ),
      //   Sample(
      //     name: 'Lollipop',
      //     time: DateTime.now().subtract(Duration(minutes: 1)),
      //     type: SampleType.debris,
      //     weight: 98,
      //     NIR_result: "Any",
      //     temperature: 38,
      //     humidity: 0,
      //     pH_level: 2,
      //     EC_level: 195,
      //     NPK_level: 59,
      //     status: SampleStatus.delivered,
      //   ),
      //   Sample(
      //     name: 'Honeycomb',
      //     time: DateTime.now().subtract(Duration(minutes: 3000)),
      //     type: SampleType.rock,
      //     weight: 87,
      //     NIR_result: "Any",
      //     temperature: 562,
      //     humidity: 0,
      //     pH_level: 45,
      //     EC_level: 1,
      //     NPK_level: 47,
      //     status: SampleStatus.delivered,
      //   ),
      //   Sample(
      //     name: 'Donut',
      //     time: DateTime.now().subtract(Duration(minutes: 1000)),
      //     type: SampleType.rock,
      //     weight: 51,
      //     NIR_result: "Any",
      //     temperature: 326,
      //     humidity: 2,
      //     pH_level: 22,
      //     EC_level: 5,
      //     NPK_level: 50,
      //     status: SampleStatus.undelivered,
      //   ),
      // ];
      // samples.forEach((sample) {
      //   writeSample(sample);
      // });

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
    var records = await queryService.query(query);
    await records.forEach((record) {
      recordsFormatted.add('${record['_time']} | ${record['_measurement']} | ${record['_value']}');
    });

    return recordsFormatted;

  }

  Future<Map<String, int>> countByDays(DateTime from, DateTime to) async {

    String query = """from(bucket: "$bucket")
    |> range(start: ${from.millisecondsSinceEpoch ~/ 1000}, stop: ${to.millisecondsSinceEpoch ~/ 1000})
    |> aggregateWindow(every: 1d, fn: count)""";

    final result = await queryService.query(query);
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

    String measurementPredicate = 'r["_measurement"] == "sample"';

    var query = '''from(bucket: "$bucket") |> range(start: 0) |> filter(fn: (r) => $measurementPredicate)''';
    // print(query);

    List<Sample> samples = [];
    var records = await queryService.query(query);
    await records.forEach((record) {
      if (record['deleted'] == 'false') {
        samples.add(Sample(name: _unescapeTagValue(record['name']), time: DateTime.parse(record['_time']), type: record['type'] == SampleType.rock.name ? SampleType.rock : SampleType.debris,
            status: record['status'] == SampleStatus.delivered.name ? SampleStatus.delivered : SampleStatus.undelivered, NIR_result: _unescapeTagValue(record["nir_result"]),
            EC_level: record["ec_level"], NPK_level: record['npk_level'], pH_level: record['ph_level'], weight: record['weight'], humidity: record['humidity'],
            temperature: record['temperature']));
      }
    });
    // print(samples);

    return samples;

  }

  void writeSample(Sample sample) async {

    final writeApi = _client.getWriteService(WriteOptions(
      batchSize: 100,
      flushInterval: 5000, // meaning it will wait for 5 seconds or for the batch size to get to 100 points and then submit
    ));

    String point = "sample,name=${_escapeTagValue(sample.name)},type=${sample.type.name},"
        "weight=${sample.weight},nir_result=${_escapeTagValue(sample.NIR_result)},ph_level=${sample.pH_level},"
        "npk_level=${sample.NPK_level},deleted=${sample.isDeleted},ec_level=${sample.EC_level},"
        "temperature=${sample.temperature},humidity=${sample.humidity},status=${sample.status.name} "
        "value=0.0 ${sample.time.toUtc().millisecondsSinceEpoch * 1000000}";
    // print("Writing Sample: $point");

    writeApi.write(point).then((value) {
      print('Write completed');
    }).catchError((exception) {
      // error block
      print("Handle write error here!");
      print(exception);
    });

  }

  String _escapeTagValue(String value) {
    return value.replaceAll(' ', r'\\$1');
  }

  String _unescapeTagValue(String escapedValue) {
    return escapedValue.replaceAll(r'\\$1', ' ');
  }

  static final InfluxDBHandle _instance = InfluxDBHandle._();

  factory InfluxDBHandle() => _instance;

}