package com.awareframework.core.awareframework_core

import android.util.Log
import androidx.annotation.NonNull
import com.awareframework.android.core.model.ISensorController

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.StreamHandler

/** AwareframeworkCorePlugin */
class AwareframeworkCorePlugin: AwareFlutterPluginCore(), FlutterPlugin {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.setMethodChannel(flutterPluginBinding, this, "awareframework_core/method")
        this.setEventChannels(flutterPluginBinding, this, listOf("awareframework_core/event"))
    }


    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        this.resetMethodChannel()
        this.resetEventChannels()
    }

}

/// A protocol for handling a sensor initialization call
///
/// This method is called when Flutter executes `-start()` method on AwareSensor and if AwareSensor instance is null.
//interface AwareFlutterPluginSensorInitializationHandler {
//    fun initializeSensor(call: MethodCall, result: Result): AwareSensor?
//}

/// A protocol for handling method calls
///
/// This methods are called when begin and end of a method handle event.
/// By using this protocol, you can add any operation before and after the event.
interface AwareFlutterPluginMethodHandler{
    fun beginMethodHandle(call: MethodCall, result: Result)
    fun endMethodHandle(call: MethodCall, result: Result)
}


open class AwareFlutterPluginCore: StreamHandler, MethodCallHandler {

    /// An AwareSensor instance
    /// - note
    /// For handling method calls inside `AwareFlutterPluginCore`, this instance should be initialized when this class is initialized or `-initializeSensor(:result:)` is called initialization method is called.
    // public var sensor:AwareSensor? = null

    var sensorController:ISensorController? = null

    /// Stream channel handlers
    var streamHandlers: ArrayList<MyStreamHandler> = ArrayList()

    /// A delegate of initialization call event
    // public var initializationCallEventHandler:AwareFlutterPluginSensorInitializationHandler? = null

    /// A delegate of method events
    var methodEventHandler:AwareFlutterPluginMethodHandler? = null

    var methodChannel : MethodChannel? = null
    var eventChannels = ArrayList<EventChannel>()

    var binding:FlutterPlugin.FlutterPluginBinding? = null
    /// Set a method channel
    ///
    /// - Parameters:
    ///   - registrar: A helper providing application context and methods for registering callbacks.
    ///   - instance: The receiving object, such as the plugin's main class
    ///   - channelName: A channel name of this method channel
    public fun setMethodChannel(binding: FlutterPlugin.FlutterPluginBinding,
                                instance:MethodCallHandler,
                                channelName:String) {
        this.binding = binding
        this.methodChannel = MethodChannel(binding.binaryMessenger, channelName)
        this.methodChannel?.setMethodCallHandler(instance)
    }


    /// Set event (stream) channels
    ///
    /// - Parameters:
    ///   - registrar: A helper providing application context and methods for registering callbacks.
    ///   - instance: The receiving object, such as the plugin's main class
    ///   - channelNames: The names of event channels
    public fun setEventChannels(binding: FlutterPlugin.FlutterPluginBinding,
                                instance:StreamHandler,
                                channelNames:List<String>){
        this.binding = binding
        for (name in channelNames) {
            val stream = EventChannel(binding.binaryMessenger, name)
            stream.setStreamHandler(instance)
            eventChannels.add(stream)
        }
    }

    public fun resetMethodChannel(){
        this.methodChannel?.setMethodCallHandler(null)
        this.methodChannel = null
    }

    public fun resetEventChannels(){
        this.eventChannels.forEach {
            it.setStreamHandler(null)
        }
        this.eventChannels.clear()
    }


    override fun onMethodCall(call: MethodCall, result: Result) {
        this.methodEventHandler?.beginMethodHandle(call, result)

        Log.d(this.toString(), call.method)

        when (call.method) {
            "start" -> {
                this.start(call, result)
            }
            "sync" -> {
                this.sync(call, result)
            }
            "stop" -> {
                this.stop(call, result)
            }
            "enable" -> {
                this.enable(call, result)
            }
            "disable" -> {
                this.disable(call, result)
            }
            "is_enable" -> {
                this.isEnable(call, result)
            }
            "cancel_broadcast_stream" -> {
                this.cancelStreamHandler(call, result)
            }
            "set_label" -> {
                this.setLabel(call, result)
            }
            else -> {
                result.notImplemented()
            }
        }

        this.methodEventHandler?.endMethodHandle(call, result)
    }


    open fun start(call: MethodCall, result: Result) {
        sensorController?.start()
    }

    open fun stop(call: MethodCall, result: Result) {
        sensorController?.stop()
    }

    open fun sync(call: MethodCall, result: Result) {
        if (call.arguments != null) {
            call.arguments.let { args ->
                if (args is Map<*, *>) args["force"].let { state ->
                    if (state is Boolean) {
                        val sync = sensorController?.sync(state)
                        return
                    }
                }
            }
        }
        sensorController?.sync(false)
    }

    open fun enable(call: MethodCall, result: Result) {
        sensorController?.enable()
    }

    open fun disable(call: MethodCall, result: Result) {
        sensorController?.disable()
    }

    open fun isEnable(call: MethodCall, result: Result) {
        if (sensorController != null) {
            result.success(sensorController?.isEnabled())
        }
    }

    open fun setLabel(call: MethodCall, result: Result) {

    }

    public fun cancelStreamHandler(call: MethodCall, result: Result) {
        call.arguments.let { args ->
            when(args) {
                is Map<*, *> -> {
                    when(val eventName = args["name"]){
                        is String -> removeDuplicateEventNames(eventName)
                        else -> {}
                    }
                }
                else -> {}
            }
        }
    }


    private fun removeDuplicateEventNames(eventName:String){
        val events = ArrayList<MyStreamHandler>()
        this.streamHandlers.forEach { myStreamHandler ->
            if (myStreamHandler.eventName == eventName) {
                Log.d("[NOTE]",
                    "($eventName) is duplicate. The current event channel is overwritten by the new event channel."
                )
                events.add(myStreamHandler)
            }
        }
        this.streamHandlers.removeAll(events)
    }

    public fun getStreamHandlers(name: String): List<MyStreamHandler>? {
        this.getStreamHandler(name)?.let {
            return mutableListOf(it)
        }
        return null
    }

    private fun getStreamHandler(name: String):MyStreamHandler? {
        for (handler in this.streamHandlers){
            if (handler.eventName == name) {
                return handler
            }
        }
        return null
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        arguments?.let { args ->
            when (args) {
                is Map<*, *> -> {
                    when (val eventName = args["name"]) {
                        is String -> {
                            this.removeDuplicateEventNames(eventName)
                            val handler = MyStreamHandler(eventName, events)
                            streamHandlers.add(handler)
                        }
                        else -> {}
                    }
                }
                else -> {}
            }
        }
    }

    override fun onCancel(arguments: Any?) {

    }

}


class MyStreamHandler(val eventName: String, var eventSink: EventChannel.EventSink?){}