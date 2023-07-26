import 'package:influxdb_client/api.dart';

class InfluxDBHandle {

  InfluxDBHandle._();

  bool _isInitted = false;
  late InfluxDBClient _client;

  void init() {

    if (!_isInitted) {
      _isInitted = true;
      _client = InfluxDBClient(
          url: 'http://localhost:8086',
          token: '',
          org: 'ATU-ROVER',
          bucket: 'ATU-ROVER',
          debug: true);
    }

  }

  void close() {

    _client.close();

  }

  static final InfluxDBHandle _instance = InfluxDBHandle._();

  factory InfluxDBHandle() => _instance;

}