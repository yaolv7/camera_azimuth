import 'camera_azimuth_platform_interface.dart';

class CameraAzimuth {
  factory CameraAzimuth() => _singleton ??= CameraAzimuth._();

  CameraAzimuth._();

  static CameraAzimuth? _singleton;

  static CameraAzimuthPlatform get _platform => CameraAzimuthPlatform.instance;

  /// A broadcast stream of events from the device accelerometer.
  static Stream<AzimuthEvent> get azimuthEvents {
    return _platform.azimuthEvents;
  }
}
