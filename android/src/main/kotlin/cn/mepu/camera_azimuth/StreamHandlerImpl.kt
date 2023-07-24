package cn.mepu.camera_azimuth

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink

internal class StreamHandlerImpl(
  private val sensorManager: SensorManager
) : EventChannel.StreamHandler {
  private var sensorEventListener: SensorEventListener? = null

  private var aSensor: Sensor? = null
  private var mSensor: Sensor? = null
  private var accelerometerValues = FloatArray(3)
  private var magneticFieldValues = FloatArray(3)
  private var values = FloatArray(3)

  override fun onListen(arguments: Any?, events: EventSink) {
    aSensor = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
    mSensor = sensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)
    if (aSensor != null && mSensor != null) {
      sensorEventListener = createSensorEventListener(events)

      sensorManager.registerListener(
        sensorEventListener,
        aSensor,
        SensorManager.SENSOR_DELAY_NORMAL
      )

      sensorManager.registerListener(
        sensorEventListener,
        mSensor,
        SensorManager.SENSOR_DELAY_NORMAL
      )
    } else {
      events.error(
        "NO_SENSOR",
        "未找到传感器",
        "您的设备似乎没有加速计和磁场传感器"
      )
    }
  }

  override fun onCancel(arguments: Any?) {
    if (aSensor != null && mSensor != null) {
      sensorManager.unregisterListener(sensorEventListener)
    }
  }


  private fun createSensorEventListener(events: EventSink): SensorEventListener {
    return object : SensorEventListener {
      override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) {}

      override fun onSensorChanged(event: SensorEvent) {
        val R = FloatArray(9)

        if (event.sensor.type == Sensor.TYPE_ACCELEROMETER) {
          accelerometerValues = event.values.clone()
        }

        if (event.sensor.type == Sensor.TYPE_MAGNETIC_FIELD) {
          magneticFieldValues = event.values.clone()
        }

        // 调用getRotaionMatrix获得变换矩阵R[]
        SensorManager.getRotationMatrix(R, null, accelerometerValues, magneticFieldValues)

        val adjustedRotationMatrix = FloatArray(9)
        SensorManager.remapCoordinateSystem(
          R, SensorManager.AXIS_X, SensorManager.AXIS_Z,
          adjustedRotationMatrix
        )

        SensorManager.getOrientation(adjustedRotationMatrix, values)// 得到的values值为弧度

        // 弧度
        val radian = values[0].toDouble()
        // 转换为角度
        val value1 = Math.toDegrees(radian).toDouble()
//        val value2 = Math.toDegrees(values[1].toDouble()).toInt()
//        val value3 = Math.toDegrees(values[2].toDouble()).toInt()

        var previousAzimuthDegrees = value1
        // 范围限制在[0, 360)之间
        if (previousAzimuthDegrees < 0) {
          previousAzimuthDegrees += 360
        } else if (previousAzimuthDegrees >= 360) {
          previousAzimuthDegrees -= 360
        }

        val sensorValues = DoubleArray(2)
        sensorValues[0] = radian
        sensorValues[1] = previousAzimuthDegrees

        events.success(sensorValues)
      }
    }
  }
}
