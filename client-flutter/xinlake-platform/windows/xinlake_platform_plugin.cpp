#include "xinlake_platform_plugin.h"

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

extern void pickFile(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

extern void getAppVersion(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

namespace XinlakePlatform {
    // static
    void XinlakePlatformPlugin::RegisterWithRegistrar(
        flutter::PluginRegistrarWindows* registrar) {
        auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
            registrar->messenger(), "xinlake_platform",
            &flutter::StandardMethodCodec::GetInstance());

        auto plugin = std::make_unique<XinlakePlatformPlugin>();

        channel->SetMethodCallHandler(
            [plugin_pointer = plugin.get()](const auto& call, auto result) {
            plugin_pointer->HandleMethodCall(call, std::move(result));
        });

        registrar->AddPlugin(std::move(plugin));
    }

    XinlakePlatformPlugin::XinlakePlatformPlugin() {}
    XinlakePlatformPlugin::~XinlakePlatformPlugin() {}

    void XinlakePlatformPlugin::HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

        const std::string method_name = method_call.method_name();

        if (method_name == "getPlatformVersion") {
            std::ostringstream version_stream;
            version_stream << "Windows ";
            if (IsWindows10OrGreater()) {
                version_stream << "10+";
            } else if (IsWindows8OrGreater()) {
                version_stream << "8";
            } else if (IsWindows7OrGreater()) {
                version_stream << "7";
            }
            result->Success(flutter::EncodableValue(version_stream.str()));
        } else if (method_name == "pickFile") {
            pickFile(method_call, std::move(result));
        } else if (method_name == "getAppVersion") {
            getAppVersion(std::move(result));
        } else {
            result->NotImplemented();
        }
    }
}  // namespace
