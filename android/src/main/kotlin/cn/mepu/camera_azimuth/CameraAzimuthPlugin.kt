package cn.mepu.camera_azimuth

import androidx.annotation.NonNull

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

/** CameraAzimuthPlugin */
class CameraAzimuthPlugin : FlutterPlugin {
  private lateinit var channel: EventChannel

  private lateinit var streamHandler: StreamHandlerImpl

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    setupEventChannels(binding.applicationContext, binding.binaryMessenger)
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    teardownEventChannels()
  }

  private fun setupEventChannels(context: Context, messenger: BinaryMessenger) {
    val sensorsManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager

    channel = EventChannel(messenger, CAMERA_AZIMUT_CHANNEL_NAME)
    streamHandler = StreamHandlerImpl(
      sensorsManager
    )
    channel.setStreamHandler(streamHandler)
  }

  private fun teardownEventChannels() {
    channel.setStreamHandler(null)
    streamHandler.onCancel(null)
  }


  companion object {
    private const val CAMERA_AZIMUT_CHANNEL_NAME =
      "cn.mepu./sensors/camera_azimut"
  }
}
