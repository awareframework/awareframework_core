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
        // your code here
        super.handle(call, result: result)
    }
    
    open override func start(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // your code here
        super.start(call, result: result)
    }
    
    open override func sync(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // your code here
        super.start(call, result: result)
    }
    
    // /** handling sample */
    //    func opnSomeChanged(){
    //        for handler in self.streamHandlers {
    //            if handler.eventName == "eventName" {
    //                handler.eventSink(nil)
    //            }
    //        }
    //    }
}

open class AwareFlutterPluginCore: NSObject, FlutterStreamHandler {
    
    public static func setChannels(with registrar: FlutterPluginRegistrar, methodChannelName:String, eventChannelName:String) {
        // add own channel
        let channel = FlutterMethodChannel(name: methodChannelName, binaryMessenger: registrar.messenger())
        let stream = FlutterEventChannel(name: eventChannelName,    binaryMessenger: registrar.messenger())
        let instance = SwiftAwareframeworkCorePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        stream.setStreamHandler(instance)
    }
    
    //////////////////
    
    public var sensor:AwareSensor?
    public var streamHandlers:Array<StreamHandler> = Array<StreamHandler>();
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if(call.method == "start"){
            self.start(call, result: result)
        }else if(call.method == "stop"){
            self.stop(call, result: result)
        }else if(call.method == "sync"){
            self.sync(call, result: result)
        }else if(call.method == "enable"){
            self.enable(call, result: result)
        }else if(call.method == "disable"){
            self.disable(call, result: result)
        }else if(call.method == "is_enable"){
            self.isEnable(call, result: result)
        }
    }
    
    open func start(_ call: FlutterMethodCall, result: @escaping FlutterResult){
        if let uwSensor = sensor {
            uwSensor.start()
        }
    }
    
    open func stop(_ call: FlutterMethodCall, result: @escaping FlutterResult){
        if let uwSensor = sensor {
            uwSensor.stop()
        }
    }
    
    open func sync(_ call: FlutterMethodCall, result: @escaping FlutterResult){
        if let uwSensor = sensor {
            uwSensor.sync()
        }
    }
    
    ////////////////////////////
    open func enable(_ call: FlutterMethodCall, result: @escaping FlutterResult){
        if let uwSensor = sensor {
            uwSensor.enable()
        }
    }
    
    open func disable(_ call: FlutterMethodCall, result: @escaping FlutterResult){
        if let uwSensor = sensor {
            uwSensor.disable()
        }
    }
    
    open func isEnable(_ call: FlutterMethodCall, result: @escaping FlutterResult){
        if let uwSensor = sensor {
            result(uwSensor.isEnabled())
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

