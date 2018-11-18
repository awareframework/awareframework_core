# awareframework_core

A new flutter plugin project.

## Developing Aware Plugin for Flutter

### Flutter

1. Make a template app using flutter command
```console
$ flutter create --org com.awareframework.sample --template=plugin -i swift -a kotlin awareframework_sample
```

2. Add the awareframework_core into your pubspec.yaml
```yaml
dependencies:
  awareframework_core:
```
You can get more information about the package installation via the following [link](https://flutter.io/docs/development/packages-and-plugins/using-packages).

3. Implement your sensor using the core-library
```dart
/// install the library
import 'package:awareframework_core/awareframework_core.dart';
/// init sensor
class SampleSensor extends AwareSensorCore {
    static const MethodChannel _sampleMethod = const MethodChannel('awareframework_sample/method');
    static const EventChannel  _sampleStream  = const EventChannel('awareframework_sample/event');
    AccelerometerSensor(MethodChannel _sampleMethod, EventChannel _sampleStream) : super(_sampleMethod, _sampleStream);
    
      /// Init Accelerometer Sensor with AccelerometerSensorConfig
      SampleSensor(AwareSensorConfig config):this.convenience(config);
      SampleSensor.convenience(config) : super(config){
        /// Set sensor method & event channels
        super.setSensorChannels(_sampleMethod, _sampleStream);
      }
    
      /// A sensor observer instance
      Stream<Map<String,dynamic>> get onDataChanged {
         return super.receiveBroadcastStream("on_data_changed")
                     .map(
                        (dynamic event) => Map.from(event)
                     );
      }
    /// ...
}

/// Make an AwareWidget
class SampleCard extends StatefulWidget {
  SampleCard({Key key, @required this.sensor}) : super(key: key);

  SampleSensor sensor;

  @override
  SampleCardState createState() => new SampleCardState();
}

class SampleCardState extends State<SampleCard> {
  var data;
  @override
  void initState() {
    super.initState();
    if (widget.sensor == null) {
      widget.sensor = new SampleSensor(SampleSensor._myMethod, SampleSensor._myStream);
    }
    widget.sensor.receiveBroadcastStream("on_data_changed").listen((event) {
        setState((){
          data = event;
        });
      }, onError: (dynamic error) {
        // print('Received error: ${error.message}');
      });
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);
    return new AwareCard(
      contentWidget: Text(data),
      title: "Sample",
      sensor: widget.sensor
    );
  }
}
```

### Android
```kotlin

```

### iOS

1. Add following code into ios/awareframework_sample.podspec
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
import com_aware_ios_sensor_core

public class SwiftAwareframeworkSamplePlugin: AwareFlutterPluginCore, FlutterPlugin, AwareFlutterPluginSensorInitializationHandler {
    public static func register(with registrar: FlutterPluginRegistrar) {
        // add own channel
        super.setChannels(with: registrar,
                          instance:SwiftAwareframeworkSamplePlugin(),
                          methodChannelName: "awareframework_sample/method",
                          eventChannelName: "awareframework_sample/event")
    }
    
    public func initializeSensor(_ call: FlutterMethodCall, result: @escaping FlutterResult) -> AwareSensor? {
        // init sensor
        return AwareSensor();
    }
    
    //    func opnSomeChanged(){
    //        for handler in sController.streamHandlers {
    //            if handler.eventName == "eventName" {
    //                handler.eventSink(nil)
    //            }
    //        }
    //    }
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

