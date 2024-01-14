#include "xinlake_tunnel_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <sstream>

// method channel
extern void connect(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

extern void stopTunnel(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

extern void updateSettings(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

// event channel
extern void setEventSink(std::unique_ptr<flutter::EventSink<>>& eventSink);


namespace xinlake_tunnel {
    // static
    void XinlakeTunnelPlugin::RegisterWithRegistrar(
        flutter::PluginRegistrarWindows* registrar) {

        // setup channels
        auto plugin = std::make_unique<XinlakeTunnelPlugin>();

        auto eventHandler = std::make_unique<flutter::StreamHandlerFunctions<>>(
            [](const flutter::EncodableValue* arguments, std::unique_ptr<flutter::EventSink<>>&& events)
            -> std::unique_ptr<flutter::StreamHandlerError<>> {
                setEventSink(events);
                return nullptr;
            },
            [](const flutter::EncodableValue* arguments)
                -> std::unique_ptr<flutter::StreamHandlerError<>> {
                std::unique_ptr<flutter::EventSink<>> events = nullptr;
                setEventSink(events);
                return nullptr;
            });

        auto eventChannel = std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
            registrar->messenger(), "xinlake_tunnel_event",
            &flutter::StandardMethodCodec::GetInstance());

        auto methodChannel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
            registrar->messenger(), "xinlake_tunnel_method",
            &flutter::StandardMethodCodec::GetInstance());

        eventChannel->SetStreamHandler(std::move(eventHandler));
        methodChannel->SetMethodCallHandler(
            [plugin_pointer = plugin.get()](const auto& call, auto result) {
            plugin_pointer->HandleMethodCall(call, std::move(result));
        });

        registrar->AddPlugin(std::move(plugin));
    }

    // initialize plugin
    XinlakeTunnelPlugin::XinlakeTunnelPlugin() {
        extern void cacheBinaries();
        cacheBinaries();      // cache binary files
    }

    // dispose plugin
    XinlakeTunnelPlugin::~XinlakeTunnelPlugin() {
        extern BOOL DisableProxy();
        extern BOOL stopShadowsocks();

        DisableProxy();
        stopShadowsocks();
    }

    void XinlakeTunnelPlugin::HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

        const std::string method_name = method_call.method_name();

        if (method_name == "getTrafficBytes") {
            // not implement. use clr or win32
            result->NotImplemented();
        } else if (method_name == "getState") {
            result->NotImplemented();
        } else if (method_name == "connect") {
            connect(method_call, std::move(result));
        } else if (method_name == "stopTunnel") {
            stopTunnel(method_call, std::move(result));
        } else if (method_name == "updateSettings") {
            updateSettings(method_call, std::move(result));
        } else {
            result->NotImplemented();
        }
    }
}  // namespace
