import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:awareframework_core/awareframework_core.dart';

void main() => runApp(new MyApp());

const EventChannel _coreStream =
    const EventChannel('awareframework_core/event');
AwareSensorCore core = AwareSensorCore(null);

class MyApp extends StatefulWidget {
  var sensor;
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    var config = AwareSensorConfig();
    widget.sensor = AwareSensorCore(config);

    core.getBroadcastStream(_coreStream, "get_event").listen((event) {
      print(event);
    });
    core.cancelBroadcastStream("get_event");
  }

  String sampleValue = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: ListView(
          children: [
            Text(sampleValue),
            TextButton(
                child: Text("Start"),
                onPressed: () {
                  setState(() => sampleValue = "start");
                  widget.sensor.start();
                }),
            TextButton(
                child: Text("Stop"),
                onPressed: () {
                  setState(() => sampleValue = "stop");
                  widget.sensor.stop();
                }),
            TextButton(
              child: Text("Sync"),
              onPressed: () {
                setState(() => sampleValue = "sync");
                widget.sensor.sync(force: true);
              },
            ),
            TextButton(
              child: Text("Enable"),
              onPressed: () => setState(() => sampleValue = "enable"),
            ),
            TextButton(
              child: Text("Disable"),
              onPressed: () => setState(() => sampleValue = "disable"),
            ),
            TextButton(
              child: Text("Set Label"),
              onPressed: () => setState(() => sampleValue = "set-label"),
            ),
            TextButton(
              child: Text("isEnabled"),
              onPressed: () => setState(() => sampleValue = "is-enable"),
            ),
          ],
        ),
      ),
    );
  }
}
