
import 'camera_azimuth_platform_interface.dart';

class CameraAzimuth extends CameraAzimuthPlatform{
  factory CameraAzimuth() => _singleton ??= CameraAzimuth._();

  CameraAzimuth._();

  static CameraAzimuth? _singleton;

  static CameraAzimuthPlatform get _platform => CameraAzimuthPlatform.instance;

  /// A broadcast stream of events from the device accelerometer.
  @override
  Stream<AzimuthEvent> get azimuthEvents {
    return _platform.azimuthEvents;
  }
}
