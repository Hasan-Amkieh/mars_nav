import 'package:mars_nav/services/SampleData.dart';


abstract class Command {

}

class NavigationCommand extends Command {

  double directionAngle;
  double distance;
  double distanceWalked = 0;

  NavigationCommand({required this.directionAngle, required this.distance}) {

    assert(validateDistance(distance) && validateDirectionAngle(directionAngle));

  }

  static bool validateDistance(double distance_) {

    return distance_ > 0.0;

  }

  static bool validateDirectionAngle(double direction_) {

    return direction_ >= 0.0 && direction_ <= 360.0;

  }

}

class DelayCommand extends Command {

  Duration toWait;
  DateTime? startedAt;

  DelayCommand({required this.toWait});

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
                required this.sampleType, required this.sampleDepth}) {

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
  mainCamera, armCamera
}

class PhotographyCommand extends Command {

  PhotographyType type;
  int videoDuration;
  RoverCameraResolution resolution;
  RoverCameras source;

  PhotographyCommand({required this.type, required this.videoDuration, required this.resolution, required this.source}) {

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
  bool isManualDeployment;

  DroneCommand({required this.altitude, required this.numberOfPics, required this.droneCamRes, required this.isManualDeployment}) {

    ;

  }

}
