import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:awareframework_core/awareframework_core.dart';

void main() => runApp(new MyApp());

const EventChannel  _coreStream  = const EventChannel('awareframework_core/event');

class MyApp extends StatefulWidget {

  AwareSensorCore core = AwareSensorCore(null);

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
    
    var sensor = AwareSensorCore.convenience(null);
    sensor.start();
    sensor.stop();
    sensor.enable();
    sensor.sync(true);
    sensor.disable();
    
    widget.core.getBroadcastStream(_coreStream, "get_event").listen((event){
      print(event);
    });
    widget.core.cancelBroadcastStream("get_event");
    
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: const Text('Plugin example app'),
          ),
          body: new AwareCard(title:"Aware Sensor Core\n", )
      ),
    );
  }
}
