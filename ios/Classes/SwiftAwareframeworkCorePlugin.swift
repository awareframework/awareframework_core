import Flutter
import UIKit
import com_awareframework_ios_sensor_core

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

//////////////////
public protocol AwareFlutterPluginSensorInitializationHandler {
    func initializeSensor(_ call: FlutterMethodCall, result: @escaping FlutterResult) -> AwareSensor?
}

public protocol AwareFlutterPluginMethodHandler{
    func beginMethodHandle(_ call: FlutterMethodCall, result: @escaping FlutterResult)
    func endMethodHandle(_ call: FlutterMethodCall, result: @escaping FlutterResult)
}

open class AwareFlutterPluginCore: NSObject, FlutterStreamHandler {
    
    public static func setMethodChannel(with registrar: FlutterPluginRegistrar,
                                   instance:FlutterPlugin & FlutterStreamHandler,
                                   channelName:String) {
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public static func setEventChannels(with registrar: FlutterPluginRegistrar,
                                        instance:FlutterPlugin & FlutterStreamHandler,
                                        channelNames:[String]){
        for name in channelNames {
            let stream = FlutterEventChannel(name: name,    binaryMessenger: registrar.messenger())
            stream.setStreamHandler(instance)
        }
    }
    
    public var sensor:AwareSensor?
    public var streamHandlers:Array<StreamHandler> = Array<StreamHandler>();
    public var initializationCallEventHandler:AwareFlutterPluginSensorInitializationHandler?
    public var methodEventHandler:AwareFlutterPluginMethodHandler?
    
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
    
    public func cancelStreamHandler(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let args = call.arguments as? Dictionary<String,Any> {
            if let id = args["id"] as? String {
                for (index, handler) in self.streamHandlers.enumerated() {
                    if handler.identifier == id {
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
            if let eventName = args["name"] as? String , let id = args["id"] as? String {
                //// check ID duplication
                for h in streamHandlers {
                    if h.identifier == id {
                        return FlutterError.init(code:    "Duplicate ID Error (awareframework_core/event)",
                                                 message: "Error: Duplicate stream handle ID (\(eventName):\(id)). You can not set duplicate ID into the same sensor.",
                                                 details: nil)
                    }
                }
                let handler = StreamHandler.init(eventName, events, id)
                streamHandlers.append(handler)
                
            }
        }
        return nil;
    }
    
    @objc public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        // all cancel events are handled on Method Channel
        return nil;
    }
    
    public func getStreamHandlers(name: String) -> [StreamHandler]? {
        var handlers = Array<StreamHandler>()
        for handler in self.streamHandlers {
            if handler.eventName == name {
                handlers.append(handler)
            }
        }
        if handlers.count == 0{
            return nil
        }else{
            return handlers
        }
    }
}

public class StreamHandler{
    public let eventName:String
    public var eventSink:FlutterEventSink
    public var identifier:String
    init(_ eventName:String, _ eventSink:@escaping FlutterEventSink, _ identifier:String) {
        self.eventName = eventName
        self.eventSink = eventSink
        self.identifier = identifier;
    }
}
