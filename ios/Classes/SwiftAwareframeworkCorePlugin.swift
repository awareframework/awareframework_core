import Flutter
import UIKit

import com_awareframework_ios_sensor_core

/// A protocol for handling a sensor initialization call
///
/// This method is called when Flutter executes `-start()` method on AwareSensor and if AwareSensor instance is null.
public protocol AwareFlutterPluginSensorInitializationHandler {
    func initializeSensor(_ call: FlutterMethodCall, result: @escaping FlutterResult) -> AwareSensor?
}

/// A protocol for handling method calls
///
/// This methods are called when begin and end of a method handle event.
/// By using this protocol, you can add any operation before and after the event.
public protocol AwareFlutterPluginMethodHandler{
    func beginMethodHandle(_ call: FlutterMethodCall, result: @escaping FlutterResult)
    func endMethodHandle(_ call: FlutterMethodCall, result: @escaping FlutterResult)
}


/// The fundation call of Aware Sensor Module for Flutter
///
/// `AwareFlutterPluginCore` is the fundation class of Aware Sensor Module for Flutter.
/// This class wrapped `method calls` from Aware Sensors on Flutter, and `broadcast streams`.
///
/// ## How to use
/// You need four steps to use this class.
/// 1. Create a sub class of this class with `FlutterPlugin` and `AwareFlutterPluginSensorInitializationHandler`.
/// 2. Add method and event (stream) channels when `-register(with)` is called.
/// 3. Inialize an AwareSensor instance on `-initializeSensor(:result:)` and set the instance into `sensor` on `AwareFlutterPluginCore`.
/// 4. Handling sensor events and broad cast its via event (stream) channels. You can get the channel by `-getStreamHandler()`.
///
/// ## Handling method calls
/// In general, Aware Sensor on Flutter has eight `method calls` as follows:
/// * `start`
/// * `stop`
/// * `sync`
/// * `enable`
/// * `disable`
/// * `is_enable`
/// * `set_label`
/// * `cancel_broadcast_stream`
///
/// The methods are the same methods on Aware Framework Swift and Kotlin library (expect `cancel_broadcast_stream`).
/// This class takes over the method calls at the core library level. In the other word, all of sub-class of AwareFlutterPluginCore
/// does not need to manage the eight method call yourself. If you need to add additional method call on you sensor,
/// you can handle the method call using `AwareFlutterPluginMethodHandler` protocol.
///
/// For using the function, you need to set an event channel name which is the same name on Flutter side of the event channel name
/// using `-setMethodChannel(with:instance:channelName)` when -`register(with:)` is called.
/// In addition, you need to set your AwareSensor instance into `sensor` variable on this class.
///
/// ## Handling stream channels
/// The `broadcast stream` allows us to asynchronized communication between front-end(Flutter) and back-end(iOS and Android).
/// For example, you can send sensor events from back-end to front-end through the stream with the sensor event.
///
/// For using the function, you need to set a stream channel name(s) which is (or are) the same name on Flutter side of the stream channel name(s).
/// using `-setEventChannel(with:instance:channelName)` when -`register(with:)` is called.
///
///
/// ## Initializing a sensor instance
/// You may want to set some sensor configurations at sensor initialization phase.
/// In that case, you can handle the sensor initialize event by using `AwareFlutterPluginSensorInitializationHandler` protocol.
///
open class AwareFlutterPluginCore: NSObject, FlutterStreamHandler {
    
    /// An AwareSensor instance
    /// - note
    /// For handling method calls inside `AwareFlutterPluginCore`, this instance should be initialized when this class is initialized or `-initializeSensor(:result:)` is called initialization method is called.
    public var sensor:AwareSensor?
    
    /// Stream channel handlers
    public var streamHandlers:Array<StreamHandler> = Array<StreamHandler>();
    
    /// A delegate of initialization call event
    public var initializationCallEventHandler:AwareFlutterPluginSensorInitializationHandler?
    
    /// A delegate of method events
    public var methodEventHandler:AwareFlutterPluginMethodHandler?
    
    /// Set a method channel
    ///
    /// - Parameters:
    ///   - registrar: A helper providing application context and methods for registering callbacks.
    ///   - instance: The receiving object, such as the plugin's main class
    ///   - channelName: A channel name of this method channel
    public static func setMethodChannel(with registrar: FlutterPluginRegistrar,
                                   instance:FlutterPlugin & FlutterStreamHandler,
                                   channelName:String) {
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    
    /// Set event (stream) channels
    ///
    /// - Parameters:
    ///   - registrar: A helper providing application context and methods for registering callbacks.
    ///   - instance: The receiving object, such as the plugin's main class
    ///   - channelNames: The names of event channels
    public static func setEventChannels(with registrar: FlutterPluginRegistrar,
                                        instance:FlutterPlugin & FlutterStreamHandler,
                                        channelNames:[String]){
        for name in channelNames {
            let stream = FlutterEventChannel(name: name,    binaryMessenger: registrar.messenger())
            stream.setStreamHandler(instance)
        }
    }
    
    
    @objc(handleMethodCall:result:) public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        if let methodHandler = self.methodEventHandler{
            methodHandler.beginMethodHandle(call, result: result)
        }
        
        if self.sensor == nil {
            if let handler = self.initializationCallEventHandler {
                sensor = handler.initializeSensor(call, result: result)
            }
        }
        
        if call.method == "start" {
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
        }else if call.method == "cancel_broadcast_stream" {
            self.cancelStreamHandler(call, result:result)
        }else if call.method == "set_label"{
            self.setLabel(call, result: result)
        }
        
        if let methodHandler = self.methodEventHandler{
            methodHandler.endMethodHandle(call, result: result)
        }
    }
    
    open func start(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let uwSensor = self.sensor {
            uwSensor.start();
        }
    }
    
    open func stop(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let uwSensor = self.sensor {
            uwSensor.stop();
        }
    }
    
    open func sync(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let uwSensor = self.sensor {
            if let args = call.arguments as? Dictionary<String, Any> {
                if let force = args["force"] as? Bool {
                    uwSensor.sync(force: force)
                    return
                }
            }
            uwSensor.sync();
        }
    }
    
    open func enable(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let uwSensor = self.sensor {
            uwSensor.enable();
        }
    }
    
    open func disable(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let uwSensor = self.sensor {
            uwSensor.disable();
        }
    }
    
    open func isEnable(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let uwSensor = self.sensor {
            result(uwSensor.isEnabled());
        }
    }
    
    open func setLabel(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let uwSensor = self.sensor {
            if let args = call.arguments as? Dictionary<String, Any> {
                if let label = args["label"] as? String {
                    uwSensor.set(label: label)
                }
            }
        }
    }
    
    public func cancelStreamHandler(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let args = call.arguments as? Dictionary<String,Any> {
            if let eventName = args["name"] as? String {
                for (index, handler) in self.streamHandlers.enumerated() {
                    if handler.eventName == eventName {
                        self.streamHandlers.remove(at: index)
                        self.cancelStreamHandler(call, result: result)
                    }
                }
            }
        }
        result(nil)
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        if let args = arguments as? Dictionary<String,Any> {
            if let eventName = args["name"] as? String {
                //// check duplicate names and remove these
                self.removeDuplicateEventNames(with: eventName)
                let handler = StreamHandler.init(eventName, events)
                streamHandlers.append(handler)
            }
        }
        return nil;
    }
    
    func removeDuplicateEventNames(with eventName:String){
        for (index,handler) in streamHandlers.enumerated() {
            if handler.eventName == eventName {
                // print("[NOTE] \(eventName) is duplicate. The current event channel is overwritten by the new event channel.")
                // remove the duplicate evnet name here
                self.streamHandlers.remove(at: index)
                // check the duplicate event name again
                self.removeDuplicateEventNames(with: eventName)
            }
        }
        return
    }
    
    @objc public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        // all cancel events are handled on Method Channel
        return nil;
    }
    
    public func getStreamHandlers(name: String) -> [StreamHandler]? {
        if let hander = self.getStreamHandler(name: name){
            return [hander]
        }
        return nil
    }
    
    public func getStreamHandler(name: String) -> StreamHandler? {
        for handler in self.streamHandlers {
            if handler.eventName == name {
                return handler
            }
        }
        return nil
    }
}

public class StreamHandler{
    public let eventName:String
    public var eventSink:FlutterEventSink
    init(_ eventName:String, _ eventSink:@escaping FlutterEventSink) {
        self.eventName = eventName
        self.eventSink = eventSink
    }
}

public class SwiftAwareframeworkCorePlugin: AwareFlutterPluginCore, FlutterPlugin, AwareFlutterPluginSensorInitializationHandler {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftAwareframeworkCorePlugin()
        
        super.setMethodChannel(with: registrar,
                               instance: instance,
                               channelName: "awareframework_core/method")
        
        super.setEventChannels(with: registrar,
                               instance: instance,
                               channelNames: ["awareframework_core/event"])
        
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

