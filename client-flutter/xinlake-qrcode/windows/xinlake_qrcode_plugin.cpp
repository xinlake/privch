#include "xinlake_qrcode_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <sstream>

extern void readImage(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

extern void readScreen(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

namespace XinlakeQrcode {

    // static
    void XinlakeQrcodePlugin::RegisterWithRegistrar(
        flutter::PluginRegistrarWindows* registrar) {
        auto plugin = std::make_unique<XinlakeQrcodePlugin>();

        auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
            registrar->messenger(), "xinlake_qrcode",
            &flutter::StandardMethodCodec::GetInstance());

        channel->SetMethodCallHandler(
            [plugin_pointer = plugin.get()](const auto& call, auto result) {
            plugin_pointer->HandleMethodCall(call, std::move(result));
        });

        registrar->AddPlugin(std::move(plugin));
    }

    XinlakeQrcodePlugin::XinlakeQrcodePlugin() {}
    XinlakeQrcodePlugin::~XinlakeQrcodePlugin() {}

    void XinlakeQrcodePlugin::HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

        const std::string method_name = method_call.method_name();

        if (method_name == "readImage") {
            readImage(method_call, std::move(result));
        } else if (method_name == "readScreen") {
            readScreen(method_call, std::move(result));
        } else {
            result->NotImplemented();
        }
    }
}  // namespace
