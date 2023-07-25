import 'dart:async';

import 'package:camera_azimuth/camera_azimuth.dart';
import 'package:camera_azimuth/camera_azimuth_platform_interface.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<AzimuthEvent>? _sensorSubscription;
  String? _info;

  @override
  void initState() {
    _sensorSubscription = CameraAzimuth.azimuthEvents.listen((event) {
      setState(() {
        _info = event.toString();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_info\n'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    super.dispose();
  }
}
