import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'camera_azimuth_method_channel.dart';

abstract class CameraAzimuthPlatform extends PlatformInterface {
  /// Constructs a CameraAzimuthPlatform.
  CameraAzimuthPlatform() : super(token: _token);

  static final Object _token = Object();

  static CameraAzimuthPlatform _instance = MethodChannelCameraAzimuth();

  /// The default instance of [CameraAzimuthPlatform] to use.
  ///
  /// Defaults to [MethodChannelCameraAzimuth].
  static CameraAzimuthPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CameraAzimuthPlatform] when
  /// they register themselves.
  static set instance(CameraAzimuthPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// A broadcast stream of events from the device accelerometer.
  Stream<AzimuthEvent> get azimuthEvents {
    throw UnimplementedError('accelerometerEvents has not been implemented.');
  }
}

class AzimuthEvent {
  AzimuthEvent(this.radian, this.angle);

  /// 弧度
  final double radian;

  /// 角度
  final double angle;

  @override
  String toString() => '[AzimuthEvent (angle: $angle, radian: $radian,)]';
}
