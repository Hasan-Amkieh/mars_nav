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

      var record = 'mem,tag1=psps,tag2=value2 field1=123.45,field2=67.89 ${DateTime.now().millisecondsSinceEpoch * 1000000}';

      var writeService = _client.getWriteService();
      await writeService.write(record).then((value) {
        print('Write successful');
      }).catchError((exception) {
        print(exception);
      });

    }
  }

  void close() {

    _client.close();

  }

  void queryAll() async {

    var query = '''from(bucket: "ATU-ROVER") |> range(start: -1h)''';

    var queryService = _client.getQueryService();

    var records = await queryService.query(query);
    await records.forEach((record) {
      print('${record['_time']}: ${record['_field']} = ${record['_value']}');
    });

  }

  static final InfluxDBHandle _instance = InfluxDBHandle._();

  factory InfluxDBHandle() => _instance;

}