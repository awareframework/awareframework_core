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
  awareframework__core:
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
    
    /// overwrite methos and config classes.
    /// ...
}

/// Make an AwareWidget
class SampleCard extends StatefulWidget {
  SampleCard({Key key, this.sensor, this.config}) : super(key: key);

  SampleSensor sensor;
  SampleSensorConfig config;

  @override
  SampleCardState createState() => new SampleCardState();
}

class SampleCardState extends State<ASampleCard> {
  var data;
  @override
  void initState() {
    super.initState();
    if (widget.sensor == null) {
      widget.sensor = new AccelerometerSensor(AccelerometerSensor._myMethod, AccelerometerSensor._myStream);
    }
    widget.sensor.receiveBroadcastStream("on_data_changed").listen((dynamic event) {
        var result = event;
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
      sensor: widget.sensor,
      sensorConfig: widget.config,
    );
  }
}
```

### Android
```kotlin

```

### iOS
```swift
import Flutter
import UIKit
import com_aware_ios_sensor_core

public class SwiftAwareframeworkCorePlugin: AwareFlutterPluginCore, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        // add own channel
        super.setChannels(with: registrar,
                          methodChannelName: "awareframework_core/method",
                          eventChannelName: "awareframework_core/event")
    }
    
    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("handle")
        super.handle(call, result: result)
    }
    
    open override func start(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // your code here
        print("start")
        super.start(call, result: result)
    }
    
    open override func sync(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // your code here
        print("sync")
        super.start(call, result: result)
    }
    
    // /** handling sample */
    //    func onChange(){
    //        for handler in self.streamHandlers {
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
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: const Text('Plugin Example App'),
          ),
          body: new SampleCard(title:"Sample Card", )
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

### Dry Run
```console
$ flutter packages pub publish --dry-run
```

### 

