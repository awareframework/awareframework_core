import Flutter
import UIKit
import com_aware_ios_sensor_core

public class SwiftAwareframeworkCorePlugin: AwareFlutterPluginCore, FlutterPlugin, AwareFlutterPluginSensorInitializationHandler {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        // add own channel
        super.setChannels(with: registrar,
                          instance:SwiftAwareframeworkCorePlugin(),
                          methodChannelName: "awareframework_core/method",
                          eventChannelName: "awareframework_core/event"
                          )
    }
    
    public func initializeSensor(_ call: FlutterMethodCall, result: @escaping FlutterResult) -> AwareSensor? {
        return AwareSensor();
    }
    
    // /** handling sample */
    //    func opnSomeChanged(){
    //        for handler in sController.streamHandlers {
    //            if handler.eventName == "eventName" {
    //                handler.eventSink(nil)
    //            }
    //        }
    //    }
}

//////////////////
public protocol AwareFlutterPluginSensorInitializationHandler {
    func initializeSensor(_ call: FlutterMethodCall, result: @escaping FlutterResult) -> AwareSensor?
}

public protocol AwareFlutterPluginMethodHandler{
    func beginMethodHandle(_ call: FlutterMethodCall, result: @escaping FlutterResult)
    func endMethodHandle(_ call: FlutterMethodCall, result: @escaping FlutterResult)
}

open class AwareFlutterPluginCore: NSObject, FlutterStreamHandler {

    public static func setChannels(with registrar: FlutterPluginRegistrar,
                                   instance:FlutterPlugin & FlutterStreamHandler,
                                   methodChannelName:String, eventChannelName:String) {
        // add own channel
        let channel = FlutterMethodChannel(name: methodChannelName, binaryMessenger: registrar.messenger())
        let stream = FlutterEventChannel(name: eventChannelName,    binaryMessenger: registrar.messenger())
        // let  = SwiftAwareframeworkCorePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        stream.setStreamHandler(instance)
    }
    
    public var sensor:AwareSensor?
    public var streamHandlers:Array<StreamHandler> = Array<StreamHandler>();
    public var initializationCallEventHandler:AwareFlutterPluginSensorInitializationHandler?
    public var methodEventHandler:AwareFlutterPluginMethodHandler?
    
    @objc(handleMethodCall:result:) public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        if let methodHandler = self.methodEventHandler{
            methodHandler.beginMethodHandle(call, result: result)
        }
        if call.method == "init"{
            if let handler = self.initializationCallEventHandler {
                sensor = handler.initializeSensor(call, result: result)
            }
        }else if call.method == "start" {
            self.start(call, result: result)
        }else if call.method == "sync" {
            self.sync(call, result: result)
        }else if call.method == "stop" {
            self.stop(call, result: result)
        }else if call.method == "enable" {
            self.enable(call, result: result)
        }else if call.method == "disable" {
            self.disable(call, result: result)
        }else if call.method == "is_enable" {
            self.isEnable(call, result: result)
        }
        
        
        if let methodHandler = self.methodEventHandler{
            methodHandler.endMethodHandle(call, result: result)
        }
    }
    
    public func start(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let uwSensor = self.sensor {
            uwSensor.start();
        }
    }
    
    public func stop(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let uwSensor = self.sensor {
            uwSensor.stop();
        }
    }
    
    public func sync(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let uwSensor = self.sensor {
            uwSensor.sync();
        }
    }
    
    public func enable(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let uwSensor = self.sensor {
            uwSensor.enable();
        }
    }
    
    public func disable(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let uwSensor = self.sensor {
            uwSensor.disable();
        }
    }
    
    public func isEnable(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let uwSensor = self.sensor {
            result(uwSensor.isEnabled());
        }
    }
    
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        if let args = arguments as? Array<Any> {
            if args.count > 0 {
                if let eventName = args[0] as? String {
                    let handler = StreamHandler.init(eventName,events)
                    streamHandlers.append(handler)
                }
            }
        }
        return nil;
    }
    
    @objc public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if let args = arguments as? Array<Any> {
            if args.count > 0 {
                if let eventName = args[0] as? String {
                    for handler in self.streamHandlers {
                        if eventName == handler.eventName {
                            handler.isListening = false
                        }
                    }
                }
            }
        }
        return nil;
    }
}

public class StreamHandler{
    public let eventName:String
    public var eventSink:FlutterEventSink
    public var isListening:Bool = false
    init(_ eventName:String, _ eventSink:@escaping FlutterEventSink) {
        self.eventName = eventName
        self.eventSink = eventSink
    }
}
