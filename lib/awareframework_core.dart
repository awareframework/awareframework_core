import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class AwareSensorCore {

  static const MethodChannel _coreChannel = const MethodChannel('awareframework_core/method');
  static const EventChannel  _coreStream  = const EventChannel('awareframework_core/event');

  /// method handling channel
  /// e.g.,
  ///   static const MethodChannel _channel
  ///           = const MethodChannel('awareframework_core/method');
  MethodChannel _channel;

  /// event handling channel
  /// e.g.,
  ///   static const EventChannel  _coreStream
  ///           = const EventChannel('awareframework_core/event');
  EventChannel  _stream;

  /// configuration of sensor
  /// e.g.,
  ///   var config = AwareSensorConfig(debug:true, label:"sample");
  AwareSensorConfig config;

  ///
  /// An initializer for AwareSensorCore.
  /// e.g.,
  /// var config = AwareSensorConfig(debug:true, label:"sample");
  /// var sensor = AwareSensorCore(config);
  ///
  /// NOTE: If you are making a sensor, you have to set your own channels
  /// by using setSensorChannels() after this initialization.
  ///
  AwareSensorCore(config):this.convenience(config);
  AwareSensorCore.convenience(this.config){
    this._channel = _coreChannel;
    this._stream  = _coreStream;
  }

  void setSensorChannels(MethodChannel channel, EventChannel stream){
    this._channel = channel;
    this._stream  = stream;
  }

  /// Start sensing
  Future<Null> start() async {
    try {
      if (config == null){
        await _channel.invokeMethod('start', null);
      }else{
        await _channel.invokeMethod('start', config.toMap());
      }
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  /// Stop sensing
  Future<Null> stop () async {
    try {
      await _channel.invokeMethod('stop', null);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  /// sync local-database with remote-database
  Future<Null> sync (bool force) async {
    try {
      await _channel.invokeMethod('sync', force);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<Null> enable () async {
    try {
      await _channel.invokeMethod('enable', null);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<Null> disable () async {
    try {
      await _channel.invokeMethod('disable', null);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<bool> isEnabled() async {
    try {
      return await _channel.invokeMethod('is_enable', null);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  /// https://medium.com/flutter-io/flutter-platform-channels-ce7f540a104e
  //    channel.receiveBroadcastStream().listen((dynamic event) {
  //      // print('Received event: $event');
  //    }, onError: (dynamic error) {
  //      // print('Received error: ${error.message}');
  //    });
  Stream<dynamic> receiveBroadcastStream(String eventName){
    return _stream.receiveBroadcastStream([eventName]);
  }

}

///
/// A configuration of AwareSensor
///
/// e.g.,
///   var config = AwareSensorConfig(debug:true, label:"sample");
///
class AwareSensorConfig {
  bool enabled    = false;
  bool debug      = false;
  var label    = "";
  var deviceId = "";
  var dbEncryptionKey;
  var dbType = 0;
  var dbPath = "aware";
  var dbHost;

  AwareSensorConfig({
    Key key,
    this.debug,
    this.enabled,
    this.label,
    this.deviceId,
    this.dbEncryptionKey,
    this.dbType,
    this.dbPath,
    this.dbHost
  });

  Map<String,dynamic> toMap() {
    var config =
    {"enabled":enabled,
      "debug":debug,
      "label":label,
      "deviceId":deviceId,
      "dbType":dbType,
      "dbPath":dbPath};
    if(dbEncryptionKey != null){
      config["dbEncryptionKey"] = dbEncryptionKey;
      config["dbHost"] = dbHost;
    }
    return config;
  }
}


class AwareDbSyncManagerConfig{
  double syncInterval      = 1.0;
  bool wifiOnly            = true;
  bool batteryChargingOnly = false;
  bool debug               = false;
  List<String> sensors     = List<String>();

  Map<String,dynamic> toMap() {
    var config = {
      "syncInterval" : syncInterval,
      "wifiOnly" : wifiOnly,
      "batteryChargingOnly" : batteryChargingOnly,
      "debug"    : debug,
      "sensors"  : sensors
    };
    return config;
  }

}

/// A widget for Accelerometer Sensor
class AwareCard extends StatefulWidget {
  AwareCard({Key key, this.contentWidget, this.title, this.sensor}) : super(key: key);
  Widget contentWidget;
  AwareSensorCore sensor;
  String title;

  @override
  AwareCardState createState() => new AwareCardState();
}

class AwareCardState extends State<AwareCard> {

  bool _isSensing  = false;

  @override
  void initState() {
    super.initState();
  }

  Widget getContentWidget(){
    if(widget.contentWidget == null) {
      return widget.contentWidget = new Icon(Icons.show_chart, size: 150.0);
    }else{
      return widget.contentWidget;
    }
  }

  Widget getSensorController(){

    return Column(
      //mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Switch(value: _isSensing, onChanged: (bool isOn) {
            setState(() {
              _isSensing = isOn;
              if (isOn) {
                widget.sensor.start();
              }else{
                widget.sensor.stop();
              }
            });
          }),
        ]
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle _biggerFont = new TextStyle(color: Color.fromARGB(255, 117, 117, 117),
        fontSize: 24.0,
        fontWeight: FontWeight.bold);

    return new Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 16.0, left: 12.0, right: 12.0),
        child: new Card(
            child: new Row(
              children: <Widget>[
                new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.only(top: 22.0, bottom: 8.0),
                      child: new Text("${widget.title}", style:_biggerFont),
                    ),
                    getContentWidget(),
                    getSensorController(),
                    new Divider()
                  ],
                ),
              ],
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
            )
        )
    );

  }
}

