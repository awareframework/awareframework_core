import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class AwareSensorCore {

  static const MethodChannel _coreChannel = const MethodChannel('awareframework_core/method');

  /// method handling channel
  /// e.g.,
  ///   static const MethodChannel _channel
  ///           = const MethodChannel('awareframework_core/method');
  MethodChannel _channel;

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
  }

  void setMethodChannel(MethodChannel channel){
    this._channel = channel;
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
      await _channel.invokeMethod('sync', {"force":bool} );
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

  isEnabled() async {
    try {
      return await _channel.invokeMethod('is_enable', null);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<Null> cancelBroadcastStream(String eventName) async {
    try {
      return await _channel.invokeMethod("cancel_broadcast_stream", {"name":eventName});
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  // For subscribing an event channel (stream channel),
  // (1) your have to prepare the channel instance by each channels.
  //    static const EventChannel  _stream  = const EventChannel('awareframework_core/event');
  // (2) after that, you have to set the channel by using the following method with a unique name
  //    .getBroadcastStream(_stream, "UNIQUE_NAME")
  Stream<dynamic> getBroadcastStream(EventChannel eventChannel, String eventName){
    return eventChannel.receiveBroadcastStream({"name":eventName});
  }


  void cancelAllEventChannels(){
    // self.cancelBroadcastStream("on_data_changed");
  }

/// https://medium.com/flutter-io/flutter-platform-channels-ce7f540a104e
//    channel.receiveBroadcastStream().listen((dynamic event) {
//      // print('Received event: $event');
//    }, onError: (dynamic error) {
//      // print('Received error: ${error.message}');
//    });

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


class AwareDbSyncManagerConfig {
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
                    Padding(
                      padding: EdgeInsets.all(12.0),
                      child: new Text("${widget.title}", style:_biggerFont),
                    ),
                    getContentWidget(),
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

class LineSeriesData {
  String id;
  int time;
  double value;
  LineSeriesData(this.id, this.time, this.value);
}


class StreamLineSeriesChart extends StatefulWidget {
  StreamLineSeriesChart(this.seriesList);

  final List<charts.Series> seriesList;

  static void add({Key key, @required double data,
    @required List<LineSeriesData> into,
    @required String id,
    @required int buffer}){
    into.add(new LineSeriesData(id, into.length + 1, data));

    if (into.length > buffer) {
      for (int i = 0; i < buffer; i++){
        into[i].time = into[i].time - 1;
      }
      into.removeAt(0);
    }
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<LineSeriesData, int>> createTimeSeriesData(List<LineSeriesData> x,
      List<LineSeriesData> y,
      List<LineSeriesData> z,) {

    var data = List<charts.Series<LineSeriesData, int>>();

    if (x.length == 0 && y.length==0 && z.length == 0 ){
      data.add(new charts.Series<LineSeriesData, int>(
        id: "line",
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (LineSeriesData sales, _) => sales.time,
        measureFn: (LineSeriesData sales, _) => sales.value,
        data: x,
      ));
      return data;
    }

    if (x.length > 0){
      var id = x[0].id;
      data.add(new charts.Series<LineSeriesData, int>(
        id: id,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (LineSeriesData sales, _) => sales.time,
        measureFn: (LineSeriesData sales, _) => sales.value,
        data: x,
      ));
    }
    if (y.length > 0){
      var id = x[0].id;
      data.add(new charts.Series<LineSeriesData, int>(
        id: id,
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (LineSeriesData sales, _) => sales.time,
        measureFn: (LineSeriesData sales, _) => sales.value,
        data: y,
      ));
    }
    if (z.length > 0){
      var id = x[0].id;
      data.add(new charts.Series<LineSeriesData, int>(
        id: id,
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (LineSeriesData sales, _) => sales.time,
        measureFn: (LineSeriesData sales, _) => sales.value,
        data: z,
      ));
    }
    return data;
  }

  @override
  StreamLineSeriesChartState createState() => new StreamLineSeriesChartState();
}

class StreamLineSeriesChartState extends State<StreamLineSeriesChart> {

  @override
  Widget build(BuildContext context) {
    return new charts.LineChart(
        widget.seriesList,
        animate: false
    );
  }

}
