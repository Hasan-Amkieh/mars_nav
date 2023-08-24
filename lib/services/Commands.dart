import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mars_nav/services/SampleData.dart';

import '../main.dart';


abstract class Command {

  DateTime? createdAt;
  Function()? onDeleted;
  Function()? onStarted;
  Function()? onFinished;

  int index;

  Command({this.createdAt, this.onStarted, this.onFinished, this.onDeleted, this.index = -1});

  String getTitle();
  String getDescription();

  Widget resolveIcon(Color color);

}

class NavigationCommand extends Command {

  List<DirectionalVector> directionalVectors;
  double distanceWalked = 0;

  NavigationCommand({required this.directionalVectors, super.createdAt, super.onStarted, super.onFinished, super.onDeleted, super.index});

  @override
  String getTitle() {
    return "Navigation";
  }

  @override
  String getDescription() {
    String msg = "";
    directionalVectors.forEach((element) {
      msg += "${element.distance.toStringAsFixed(2)} m, ${element.compassAngle.toStringAsFixed(2)} ${getDirectionExpressionFromAngle(element.compassAngle)}\n";
    });
    if (msg.endsWith("\n")) {
      msg = msg.substring(0, msg.length);
    }

    return msg;
  }
  
  @override
  Widget resolveIcon(Color color) {
    return Image.asset("lib/assets/icons/navigate.png", color: color, width: Main.iconSize * 2, height: Main.iconSize * 2);
  }

  static String getDirectionExpressionFromAngle(double angle) {
    if (angle >= 0 && angle < 22.5) {
      return 'North';
    } else if (angle >= 22.5 && angle < 67.5) {
      return 'Northeast';
    } else if (angle >= 67.5 && angle < 112.5) {
      return 'East';
    } else if (angle >= 112.5 && angle < 157.5) {
      return 'Southeast';
    } else if (angle >= 157.5 && angle < 202.5) {
      return 'South';
    } else if (angle >= 202.5 && angle < 247.5) {
      return 'Southwest';
    } else if (angle >= 247.5 && angle < 292.5) {
      return 'West';
    } else if (angle >= 292.5 && angle < 337.5) {
      return 'Northwest';
    } else if (angle >= 337.5 && angle < 360) {
      return 'North';
    }

    return "ERROR";
  }

}

class DelayCommand extends Command {

  Duration toWait;
  Duration? timePassed;

  DelayCommand({required this.toWait, super.createdAt, super.onStarted, super.onFinished, super.onDeleted, super.index});

  @override
  String getTitle() {
    return "DELAY";
  }

  @override
  String getDescription() {
    int hours = toWait.inHours;
    int minutes = toWait.inMinutes.remainder(60);
    int seconds = toWait.inSeconds.remainder(60);
    String msg = "";

    msg += "Halt for";
    if (hours > 0) {
      msg += " ${hours}h";
    }
    if (minutes > 0) {
      msg += " ${minutes}m";
    }
    if (seconds > 0) {
      msg += " ${seconds}s";
    }

    if (timePassed != null) {
      Duration dur = Duration(seconds: toWait.inSeconds - timePassed!.inSeconds);
      hours = dur.inHours;
      minutes = dur.inMinutes.remainder(60);
      seconds = dur.inSeconds.remainder(60);

      msg += '\n';
      if (hours > 0) {
        msg += " ${hours}h";
      }
      if (minutes > 0) {
        msg += " ${minutes}m";
      }
      if (seconds > 0) {
        msg += " ${seconds}s";
      }

      if (hours > 0 || minutes > 0 || seconds > 0) {
        msg += " remains";
      }
    }
    return msg;
  }

  @override
  Widget resolveIcon(Color color) {
    return Icon(Icons.more_time_outlined, size: Main.iconSize * 2, color: color
    );
  }

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
                required this.sampleType, required this.sampleDepth, super.createdAt, super.onStarted, super.onFinished, super.onDeleted, super.index}) {

    if (locationType == LocationType.inRadius) { assert(validateNumberOfSamples(numberOfSamples) && validateSampleRadius(sampleRadius)); }
    if (sampleType == SampleType.rock) assert(validateSampleDepth(sampleDepth));

  }

  @override
  String getTitle() {
    return "${sampleType.name.toUpperCase()} SAMPLE EXTRACTION";
  }

  @override
  String getDescription() {
    String msg = '';
    if (locationType == LocationType.inRadius) {
      msg += "$numberOfSamples samples in radius of $sampleRadius meters\n";
    }

    if (sampleType == SampleType.rock) {
      msg += "$sampleDepth cm deep";
    }

    return msg;
  }

  @override
  Widget resolveIcon(Color color) {

    return Image.asset("lib/assets/icons/${sampleType == SampleType.debris ? "sand" : "drill"}.png", color: color, width: Main.iconSize * 2, height: Main.iconSize * 2);
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

  PhotographyCommand({required this.type, this.videoDuration = -1, required this.resolution, required this.source, super.createdAt, super.onStarted, super.onFinished, super.onDeleted, super.index}) {

    if (type == PhotographyType.video) validateVideoDuration(videoDuration);

  }

  @override
  Widget resolveIcon(Color color) {
    final IconData icon;

    if (type.index == 1) {
      icon = Icons.image_outlined;
    } else if (type.index == 0) {
      icon = Icons.panorama_outlined;
    } else {
      icon = Icons.video_camera_back;
    }

    return Icon(icon, size: Main.iconSize * 2, color: color);
  }

  @override
  String getTitle() {
    return "${type.name.toUpperCase()} ${resolution.width}x${resolution.height}";
  }

  @override
  String getDescription() {
    return "${source.name} ${type.index == 2 ? "${videoDuration ~/ 60}m ${videoDuration % 60}s" : ""}";
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

  DroneCommand({required this.altitude, required this.numberOfPics, required this.droneCamRes, required this.isManualDemobilization, super.createdAt, super.onStarted, super.onFinished, super.onDeleted, super.index}) {

    assert(validateAltitude(altitude));
    assert(validateNumberOfCPhotos(numberOfPics));

  }

  @override
  Widget resolveIcon(Color color) {
    return Image.asset("lib/assets/icons/drone.png", color: color, width: Main.iconSize * 2, height: Main.iconSize * 2);
  }

  @override
  String getTitle() {
    return "";
  }

  @override
  String getDescription() {
    return "";
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

    print("$distance $compassAngle");

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
