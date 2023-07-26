# camera_azimuth

camera_azimuth

计算摄像头正对方位的 方位角
需要依赖库  sensors_plus: ^3.0.2
监听 accelerometer和magneticField，然后使用SensorManager.processOrientation方法获取


      List<double> accelerometerValues = [];

      accelerometerEvents.listen((AccelerometerEvent event) {
        accelerometerValues = [event.x, event.y, event.z];
      });

      
      magnetometerEvents.listen((MagnetometerEvent event) {
        var magneticFieldValues = [event.x, event.y, event.z];
        // azimuthModel即是方位角
        var azimuthModel = SensorManager.processOrientation(
            accelerometerValues, magneticFieldValues);
      });