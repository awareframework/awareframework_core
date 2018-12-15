# Aware Core

[![Build Status](https://travis-ci.com/awareframework/awareframework_core.svg?branch=master)](https://travis-ci.com/awareframework/awareframework_core)

A Core Plugin for Aware Framework on Flutter

## Developing Aware Plugin for Flutter

### Flutter

1. Make a template app using flutter command
```console
$ flutter create --org com.awareframework.accelerometer --template=plugin -i swift -a kotlin awareframework_accelerometer
```

2. Add the awareframework_core into your pubspec.yaml
```yaml
dependencies:
  awareframework_core:
```
You can get more information about the package installation via the following [link](https://flutter.io/docs/development/packages-and-plugins/using-packages).

3. Implement your sensor using the core-library
```dart
/// The Accelerometer Sensor class
class AccelerometerSensor extends AwareSensor {

  /// Accelerometer Method Channel
  static const MethodChannel _accelerometerMethod = const MethodChannel('awareframework_accelerometer/method');

  /// Accelerometer Event Channel
  static const EventChannel  _accelerometerStream  = const EventChannel('awareframework_accelerometer/event');

  /// Init Accelerometer Sensor with AccelerometerSensorConfig
  AccelerometerSensor():this.init(null);
  AccelerometerSensor.init(AccelerometerSensorConfig config) : super.init(config){
    super.setMethodChannel(_accelerometerMethod);
  }

  Stream<Map<String,dynamic>> get onDataChanged {
     return super.getBroadcastStream( _accelerometerStream, "on_data_changed").map((dynamic event) => Map<String,dynamic>.from(event));
  }

  @override
  void cancelAllEventChannels() {
    super.cancelBroadcastStream("on_data_changed");
  }

}

///
/// The Sensor Configuration Parameter class
///
class AccelerometerSensorConfig extends AwareSensorConfig {

  int frequency    = 5;
  double period    = 1.0;
  double threshold = 0.0;

  AccelerometerSensorConfig();

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map['frequency'] = frequency;
    map['period']    = period;
    map['threshold'] = threshold;
    return map;
  }
}

```

### Android
```kotlin

```

### iOS

1. Add following code into ios/awareframework_accelerometer.podspec
```console
  # update author information and url
  s.dependency 'awareframework_core'
  s.ios.deployment_target = '10.0'
  # add other dependency
```
2. Run `pod install` at example/ios  

3. Open iOS project (example/ios/Runner.xcworkspace) and change a deplyment target to 10.0
```swift
import Flutter
import UIKit
import com_awareframework_ios_sensor_accelerometer
import com_awareframework_ios_sensor_core
import awareframework_core

public class SwiftAwareframeworkAccelerometerPlugin: AwareFlutterPluginCore, FlutterPlugin, AwareFlutterPluginSensorInitializationHandler, AccelerometerObserver{
        
    var accelerometerSensor:AccelerometerSensor?
    
    public override init() {
        super.init()
        super.initializationCallEventHandler = self
    }
    
    public func initializeSensor(_ call: FlutterMethodCall, result: @escaping FlutterResult) -> AwareSensor? {
        if self.sensor == nil {
            if let config = call.arguments as? Dictionary<String,Any>{
                self.accelerometerSensor = AccelerometerSensor.init(AccelerometerSensor.Config(config))
            }else{
                self.accelerometerSensor = AccelerometerSensor.init(AccelerometerSensor.Config())
            }
            self.accelerometerSensor?.CONFIG.sensorObserver = self
            return self.accelerometerSensor
        }else{
            return nil
        }
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftAwareframeworkAccelerometerPlugin()
        // add own channel
        super.setMethodChannel(with: registrar,
                               instance: instance,
                               channelName: "awareframework_accelerometer/method");
        super.setEventChannels(with: registrar,
                               instance: instance,
                               channelNames: ["awareframework_accelerometer/event"]);

    }
    
    public func onDataChanged(data: AccelerometerData) {
        for handler in self.streamHandlers {
            if handler.eventName == "on_data_changed" {
                handler.eventSink(data.toDictionary())
            }
        }
    }
}

```

### Eaxample App
```dart
import 'package:awareframework_core/awareframework_core.dart';

class _MyAppState extends State<MyApp> {
  
  AccelerometerSensor sensor;
  AccelerometerSensorConfig config;
    
  @override
  void initState() {
    super.initState();
    config = AccelerometerSensorConfig()
      ..debug = true
      ..label = "label";
    
    sensor = new SampleSensor(config);

  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: const Text('Plugin Example App'),
          ),
          body: new AccelerometerCard(sensor: sensor)
      ),
    );
  }
}

```

## Publishing the your plugin
### Add author and homepage information into pubspec.yaml
```yaml
author: AWARE Mobile Context Instrumentation Middleware/Framework <yuuki.nishiyama@oulu.fi>
homepage: http://www.awareframework.com
```

### Publish
```console
$ flutter packages pub publish --dry-run
$ flutter packages pub publish
```

