import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

/// ISensorController expresses the interfaces of AwareSensor. The methods in
/// the abstract class are connected to the backend iOS and Android code.
abstract class ISensorController {
  Future<Null> start();
  Future<Null> stop();
  Future<Null> sync({bool force = false});
  Future<Null> enable();
  Future<Null> disable();
  Future<Null> setLabel(String label);
  Future<dynamic> isEnabled();
}

/// The foundation class of Aware-Sensor
/// All of AWARE sensor have to succeed AwareSensor class. This class provide
/// functions to control back-end an AWARE Sensor which are written in
/// Kotlin (Android) and Swift (iOS).
///
/// For using this method, you need following five steps:
///  1. Make a subclass of AwareSensorConfiguration class for making an
///  optimized configuration class for each sensor.
///  2. Make and initialize a subclass of AwareSensor class the sub-class of
///  the configuration.
///  3. Add a unique method channel for connecting backend methods using
///  -setMethodChannel() method.
///  4. If you need to subscribe to event(s) from backend, you can get an
///  instance for subscribing the events using -getBroadcastStream()
///  5. To cancel all of the subscribed events, you have to overwrite with
///  cancelAllEventChannels(). In the method, you should call
///  -cancelBroadcastStream() for all subscribed event.
///
class AwareSensor extends ISensorController {
  ///
  /// The _channel (MethodChannel) is a gateway for calling AWARE sensor
  /// methods on iOS and Android. You need to set a unique MethodChannel
  /// by each sensor using -setMethodChannel(channel). Also, the event channel
  /// instance should call as `static const`.
  ///
  ///   static const MethodChannel _coreChannel
  ///                     = const MethodChannel('awareframework_core/method');
  ///
  MethodChannel _channel;

  ///
  /// The config manage configurations of sensor. Each sensor should overwrite
  /// AwareSensorConfig class for optimizing its for each sensor configuration.
  /// For example in the Accelerometer sensor, you need to add sensing frequency
  /// parameter into the configuration class. Finally, you also need to
  /// overwrite the -toMap() method which is required for sending the
  /// configuration to backend as a Map object.
  ///
  AwareSensorConfig config;

  ///
  /// Initializer for AWARE Sensor
  /// You can initialize an AwareSensor Instance with an
  /// AwareSensorConfiguration instance. If the configuration parameter is null,
  /// the initializer uses the default setting.
  ///
  AwareSensor(this.config) {
    if (this.config == null) {
      this.config = AwareSensorConfig();
    }
  }

  /// Start this sensor
  /// NOTE: You need to set a method channel before using this method.
  Future<Null> start() async {
    if (_channel == null) {
      print("Please set a method channel before use the start method.");
      return null;
    }
    try {
      if (config == null) {
        await _channel.invokeMethod('start', null);
      } else {
        await _channel.invokeMethod('start', config.toMap());
      }
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  /// Stop this sensor
  /// NOTE: You need to set a method channel before using this method.
  Future<Null> stop() async {
    if (_channel == null) {
      print("Please set a method channel before use the start method.");
      return null;
    }
    try {
      await _channel.invokeMethod('stop', null);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  /// Sync the local-database on this phone with a remote-database
  /// You can sync the database forcefully by using `force=true` option.
  /// NOTE: You need to set a method channel before using this method.
  Future<Null> sync({bool force = false}) async {
    if (_channel == null) {
      print("Please set a method channel before use the start method.");
      return null;
    }
    try {
      await _channel.invokeMethod('sync', {"force": force});
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  /// Enable this sensor
  /// NOTE: You need to set a method channel before using this method.
  Future<Null> enable() async {
    if (_channel == null) {
      print("Please set a method channel before use the start method.");
      return null;
    }
    try {
      await _channel.invokeMethod('enable', null);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  /// Disable this sensor
  /// NOTE: You need to set a method channel before using this method.
  Future<Null> disable() async {
    if (_channel == null) {
      print("Please set a method channel before use the start method.");
      return null;
    }
    try {
      await _channel.invokeMethod('disable', null);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  /// Get the status of this sensor (enabled or not)
  /// NOTE: You need to set a method channel before using this method.
  Future<dynamic> isEnabled() async {
    if (_channel == null) {
      print("Please set a method channel before use the start method.");
      return null;
    }
    try {
      return await _channel.invokeMethod('is_enable', null);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  /// Set a label to stored data
  /// NOTE: You need to set a method channel before using this method.
  Future<Null> setLabel(String label) async {
    if (_channel == null) {
      print("Please set a method channel before use the start method.");
      return null;
    }
    try {
      return await _channel.invokeMethod('set_label', {"labeel": label});
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  /// Set a method channel for this sensor.
  /// NOTE: This method name should be unique name. In addition, the instance
  /// should initialize as `static const`.
  ///
  ///   static const MethodChannel _coreChannel
  ///                     = const MethodChannel('awareframework_core/method');
  void setMethodChannel(MethodChannel channel) {
    this._channel = channel;
  }

  /// For subscribing an event channel (stream channel),
  /// (1) your have to prepare the channel instance by each channels.
  ///    static const EventChannel  _stream  = const EventChannel('awareframework_core/event');
  /// (2) after that, you have to set the channel by using the following method with a unique name
  ///    .getBroadcastStream(_stream, "UNIQUE_NAME")
  Stream<dynamic> getBroadcastStream(
      EventChannel eventChannel, String eventName) {
    return eventChannel.receiveBroadcastStream({"name": eventName});
  }

  /// Cancel a broadcast stream (= event channel)
  /// NOTE: You need to set a method channel before using this method.
  Future<Null> cancelBroadcastStream(String eventName) async {
    try {
      return await _channel
          .invokeMethod("cancel_broadcast_stream", {"name": eventName});
    } on PlatformException catch (e) {
      print(e.message);
    }
  }
}

///
/// A default sensor configuration
///
/// You can make a configuration class for a subclass of AwareSensor.
/// NOTE: Please don't forget overwrite -toMap() method. This method is called
/// when AwareSensor send the configuration instance as a Map object.
///
/// You can initialize the instance as following:
/// [Example 1]
/// var config = AwareSensorConfig(debug:true, label:"sample");
///
/// [Example 2]
/// var config = AwareSenorConfig();
///   ..debug = true
///   ..label = "sample";
///
class AwareSensorConfig {
  /// The status of sensor enabled of not (default = false)
  bool enabled = false;

  /// The status of debug mode (default = false)
  bool debug = false;

  /// The label for the sensor data (default = "")
  String label = "";

  /// The deviceId of the sensor (default = `null`).
  String deviceId;

  /// The database encryption key (default = `null`)
  String dbEncryptionKey;

  /// The database type on Android (default = DatabaseTypeAndroid.ROOM)
  DatabaseType dbType = DatabaseType.DEFAULT;

  /// The local database path (default = "aware")
  String dbPath = "aware";

  /// The remote database host name (default = `null`)
  String dbHost;

  AwareSensorConfig(
      {this.debug = false,
      this.enabled = false,
      this.label = "",
      this.deviceId,
      this.dbEncryptionKey,
      this.dbType = DatabaseType.DEFAULT,
      this.dbPath = "aware",
      this.dbHost});

  /// Generate a Map<String,dynamic> object for sensing the configuration via
  /// MethodChannel. Sending the configuration object through the MethodChannel,
  /// we have to use a Map object.
  ///
  /// If you need to save the data into database, please set
  /// DatabaseType.DEFAULT to dbType. In the setting, iOS uses Realm,
  /// and Android uses Room database internally. In addition, If you do NOT
  /// want to save data into database, please set NONE as a dbType.
  ///
  /// When you call -toMap(), the method converts the dbType element depends on the
  /// current platform.
  Map<String, dynamic> toMap() {
    var config = {
      "enabled": enabled,
      "debug": debug,
      "label": label,
      "deviceId": deviceId,
      "dbPath": dbPath
    };

    if (dbEncryptionKey != null) {
      config["dbEncryptionKey"] = dbEncryptionKey;
    }

    if (dbHost != null) {
      config["dbHost"] = dbHost;
    }

    // change dbType setting depends on the platform (iOS or Android)
    if (Platform.isIOS) {
      if (this.dbType == DatabaseType.NONE) {
        config["dbType"] = 0;
      } else if (this.dbType == DatabaseType.DEFAULT) {
        config["dbType"] = 1;
      }
    }

    return config;
  }
}

/// The list of supported database types on iOS
///
/// NONE:  No database
/// REALM: Realm database [Realm](https://realm.io)
enum DatabaseType {
  NONE,
  DEFAULT,
}

class AwareDbSyncManagerConfig {
  double syncInterval = 1.0;
  bool wifiOnly = true;
  bool batteryChargingOnly = false;
  bool debug = false;
  List<String> sensors = List<String>();

  Map<String, dynamic> toMap() {
    var config = {
      "syncInterval": syncInterval,
      "wifiOnly": wifiOnly,
      "batteryChargingOnly": batteryChargingOnly,
      "debug": debug,
      "sensors": sensors
    };
    return config;
  }
}

class AwareData {
  Map<String, dynamic> source;

  int timestamp = 0;
  String deviceId = "";
  String label = "";
  int timezone = 0;
  String os = "";
  int jsonVersion = 0;

  AwareData() : this.from(null);
  AwareData.from(Map<String, dynamic> data) {
    if (data != null) {
      deviceId = data["deviceId"] ?? "";
      timestamp = data["timestamp"] ?? 0;
      label = data["label"] ?? "";
      timezone = data["timezone"] ?? 0;
      os = data["os"] ?? "";
      jsonVersion = data["jsonVersion"] ?? 0;
      source = data;
    }
  }

  @override
  String toString() {
    if (source != null) {
      return source.toString();
    }
    return super.toString();
  }
}

/// AWARE Core Sensor class
class AwareSensorCore extends AwareSensor {
  static const MethodChannel _coreChannel =
      const MethodChannel('awareframework_core/method');

  AwareSensorConfig config;

  AwareSensorCore(config) : super(config) {
    this._channel = _coreChannel;
  }

  // TODO: Extend core functions here

}

///
/// The foundation class of AWARE Card.
///
class AwareCard extends StatefulWidget {
  AwareCard({Key key, this.contentWidget, this.title, this.sensor})
      : super(key: key);
  final Widget contentWidget;
  final AwareSensor sensor;
  final String title;

  @override
  AwareCardState createState() => new AwareCardState();
}

class AwareCardState extends State<AwareCard> {
  @override
  void initState() {
    super.initState();
  }

  Widget getContentWidget() {
    if (widget.contentWidget == null) {
      return new Icon(Icons.show_chart, size: 150.0);
    } else {
      return widget.contentWidget;
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle _biggerFont = new TextStyle(
        color: Color.fromARGB(255, 117, 117, 117),
        fontSize: 24.0,
        fontWeight: FontWeight.bold);

    return new Padding(
        padding: const EdgeInsets.only(
            top: 16.0, bottom: 16.0, left: 12.0, right: 12.0),
        child: new Card(
            child: new Row(
          children: <Widget>[
            new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: new Text("${widget.title}", style: _biggerFont),
                ),
                getContentWidget(),
                new Divider()
              ],
            ),
          ],
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
        )));
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

  static void add(
      {Key key,
      double data,
      List<LineSeriesData> into,
      String id,
      int buffer}) {
    into.add(new LineSeriesData(id, into.length + 1, data));

    if (into.length > buffer) {
      for (int i = 0; i < buffer; i++) {
        into[i].time = into[i].time - 1;
      }
      into.removeAt(0);
    }
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<LineSeriesData, int>> createTimeSeriesData(
    List<LineSeriesData> x,
    List<LineSeriesData> y,
    List<LineSeriesData> z,
  ) {
    var data = List<charts.Series<LineSeriesData, int>>();

    if (x.length == 0 && y.length == 0 && z.length == 0) {
      data.add(new charts.Series<LineSeriesData, int>(
        id: "line",
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (LineSeriesData sales, _) => sales.time,
        measureFn: (LineSeriesData sales, _) => sales.value,
        data: x,
      ));
      return data;
    }

    if (x.length > 0) {
      var id = x[0].id;
      data.add(new charts.Series<LineSeriesData, int>(
        id: id,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (LineSeriesData sales, _) => sales.time,
        measureFn: (LineSeriesData sales, _) => sales.value,
        data: x,
      ));
    }
    if (y.length > 0) {
      var id = x[0].id;
      data.add(new charts.Series<LineSeriesData, int>(
        id: id,
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (LineSeriesData sales, _) => sales.time,
        measureFn: (LineSeriesData sales, _) => sales.value,
        data: y,
      ));
    }
    if (z.length > 0) {
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
    return new charts.LineChart(widget.seriesList, animate: false);
  }
}
