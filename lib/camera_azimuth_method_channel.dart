import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'camera_azimuth_platform_interface.dart';

/// An implementation of [CameraAzimuthPlatform] that uses method channels.
class MethodChannelCameraAzimuth extends CameraAzimuthPlatform {
  static const EventChannel _azimuthEventChannel =
  EventChannel('cn.mepu./sensors/camera_azimut');
  Stream<AzimuthEvent>? _azimuthEvents;

  /// A broadcast stream of events from the device accelerometer.
  @override
  Stream<AzimuthEvent> get azimuthEvents {
    _azimuthEvents ??= _azimuthEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) {
      final list = event.cast<double>();
      return AzimuthEvent(list[0]!, list[1]!);
    });
    return _azimuthEvents!;
  }
}
