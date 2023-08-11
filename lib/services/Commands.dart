import 'dart:math';

import 'package:mars_nav/services/SampleData.dart';


abstract class Command {

  DateTime? createdAt;

  Command({this.createdAt});

}

class NavigationCommand extends Command {

  DirectionalVector directionalVector;
  double distanceWalked = 0;

  NavigationCommand({required this.directionalVector, super.createdAt});

}

class DelayCommand extends Command {

  Duration toWait;
  DateTime? startedAt;

  DelayCommand({required this.toWait, super.createdAt});

}

enum LocationType {
  currentLocation(name: "Current Location"), inRadius(name: "In Radius");
  const LocationType({required this.name});

  final String name;
}

class SampleCommand extends Command {

  LocationType locationType;
  double sampleRadius;
  int numberOfSamples;
  SampleType sampleType;
  double sampleDepth;

  SampleCommand({required this.locationType, required this.sampleRadius, required this.numberOfSamples,
                required this.sampleType, required this.sampleDepth, super.createdAt}) {

    if (locationType == LocationType.inRadius) assert(validateSampleRadius(sampleRadius));
    assert(validateNumberOfSamples(numberOfSamples));
    if (sampleType == SampleType.rock) assert(validateSampleDepth(sampleDepth));

  }

  static bool validateSampleRadius(double radius) {
    return radius > 0.0;
  }

  static bool validateNumberOfSamples(int samples) {
    return samples > 0;
  }

  static bool validateSampleDepth(double depth) {
    return depth > 0.0;
  }

}

enum PhotographyType {
  panoramicPhoto(name: "Panoramic Photo"), normalPhoto(name: "Photo"), video(name: "Video");

  const PhotographyType({required this.name});
  final String name;
}

enum RoverCameraResolution {
  r1280_720(width: 1280, height: 720), r720_480(width: 720, height: 480), r360_280(width: 360, height: 280);

  const RoverCameraResolution({required this.width, required this.height});
  final int width;
  final int height;
}

enum RoverCameras {
  mainCamera(name: "Main Camera"), armCamera(name: "Robotic Arm Cam");

  const RoverCameras({required this.name});

  final String name;
}

class PhotographyCommand extends Command {

  PhotographyType type;
  int videoDuration;
  RoverCameraResolution resolution;
  RoverCameras source;

  PhotographyCommand({required this.type, required this.videoDuration, required this.resolution, required this.source, super.createdAt}) {

    if (type == PhotographyType.video) validateVideoDuration(videoDuration);

  }

  static bool validateVideoDuration(int duration) {
    return duration > 0;
  }

}

enum DroneCameraResolution {
  r1600_1200(width: 1600, height: 1200), r1280_720(width: 1280, height: 720), r720_480(width: 720, height: 480);

  const DroneCameraResolution({required this.width, required this.height});

  final int width;
  final int height;
}

class DroneCommand extends Command {

  double altitude;
  int numberOfPics;
  DroneCameraResolution droneCamRes;
  bool isManualDemobilization;

  DroneCommand({required this.altitude, required this.numberOfPics, required this.droneCamRes, required this.isManualDemobilization, super.createdAt}) {

    assert(validateAltitude(altitude));
    assert(validateNumberOfCPhotos(numberOfPics));

  }

  static bool validateAltitude(double altitude) {
    return altitude > 0.0 && altitude <= 250;
  }

  static bool validateNumberOfCPhotos(int noOfPhotos) {
    return noOfPhotos > 0 && noOfPhotos <= 10;
  }

}

class DirectionalVector {

  double distance;
  double compassAngle;

  DirectionalVector({required this.distance, required this.compassAngle}) {

    assert(validateDirectionalAngle(compassAngle) && validateDistance(distance));

  }

  static bool validateDistance(double distance_) {

    return distance_ > 0.0;

  }

  static bool validateDirectionalAngle(double direction_) {

    return direction_ >= 0.0 && direction_ <= 360.0;

  }

}

class GPSLocation {

  double latitude;
  double longitude;
  int timestampInMillis;

  GPSLocation({required this.latitude, required this.longitude, this.timestampInMillis = -1}) {
    assert(validateLatitude(latitude) && validateLongitude(longitude));
    assert(validateTimestamp(timestampInMillis));
  }

  static bool validateLatitude(double latitude) {
    return latitude >= -90 && latitude <= 90;
  }

  static bool validateLongitude(double longitude) {
    return longitude >= -180 && longitude <= 180;
  }

  static bool validateTimestamp(int stamp) {
    return stamp == -1 || stamp > 0.0;
  }

  static double _haversineDistance(GPSLocation start, GPSLocation end) {
    const R = 6371000; // Earth's radius in meters

    double phi1 = start.latitude * pi / 180;
    double phi2 = end.latitude * pi / 180;
    double deltaPhi = (end.latitude - start.latitude) * pi / 180;
    double deltaLambda = (end.longitude - start.longitude) * pi / 180;

    double a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // Distance in meters
  }

  static double _bearing(GPSLocation start, GPSLocation end) {
    double phi1 = start.latitude * pi / 180;
    double phi2 = end.latitude * pi / 180;
    double deltaLambda = (end.longitude - start.longitude) * pi / 180;

    double x = cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(deltaLambda);
    double y = sin(deltaLambda) * cos(phi2);

    double angle = atan2(y, x);

    return (angle * 180 / pi + 360) % 360; // Convert to degrees and ensure positive angle
  }

  static DirectionalVector toDirectionalVector(GPSLocation start, GPSLocation end) {

    return DirectionalVector(distance: _haversineDistance(start, end), compassAngle: _bearing(start, end));

  }

}
