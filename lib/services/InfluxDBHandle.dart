import 'dart:math';

import 'package:influxdb_client/api.dart';

class InfluxDBHandle {

  InfluxDBHandle._();

  bool _isInitted = false;
  late InfluxDBClient _client;

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
          debug: true);

      // read(DateTime.now().toUtc().subtract(Duration(hours: 3)), DateTime.now().toUtc(), "mem");

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
        measurementPredicate += 'or r["_measurement"] == "$element"';
      }
    });

    var query = '''from(bucket: "$bucket") |> range(start: ${from.millisecondsSinceEpoch * 1000000}, stop: ${to.millisecondsSinceEpoch * 1000000}) |> filter(fn: (r) => $measurementPredicate)''';

    var queryService = _client.getQueryService();

    List<String> recordsFormatted = [];
    var records = await queryService.query(query);
    await records.forEach((record) {
      recordsFormatted.add('${record['_time']} | ${record['_measurement']} | ${record['_value']}');
    });

    return recordsFormatted;

  }

  void write(DateTime time, String valueName, double value) async {

    final writeApi = _client.getWriteService(WriteOptions(
      batchSize: 100,
      flushInterval: 5000, // meaning it will wait for 5 seconds or for the batch size to get to 100 points and then submit
    ));

    String point = "$valueName value=$value ${time.millisecondsSinceEpoch * 1000000}";
    print("Writing $point");

    writeApi.write(point).then((value) {
      print('Write completed 1');
    }).catchError((exception) {
      // error block
      print("Handle write error here!");
      print(exception);
    });

  }

  static final InfluxDBHandle _instance = InfluxDBHandle._();

  factory InfluxDBHandle() => _instance;

}