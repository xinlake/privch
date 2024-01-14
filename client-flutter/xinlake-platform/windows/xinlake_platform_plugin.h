#ifndef FLUTTER_PLUGIN_XINLAKE_PLATFORM_PLUGIN_H_
#define FLUTTER_PLUGIN_XINLAKE_PLATFORM_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace XinlakePlatform {

    class XinlakePlatformPlugin : public flutter::Plugin {
    public:
        static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

        XinlakePlatformPlugin();
        virtual ~XinlakePlatformPlugin();

        // Disallow copy and assign.
        XinlakePlatformPlugin(const XinlakePlatformPlugin&) = delete;
        XinlakePlatformPlugin& operator=(const XinlakePlatformPlugin&) = delete;

    private:
        // Called when a method is called on this plugin's channel from Dart.
        void HandleMethodCall(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    };

}

#endif  // FLUTTER_PLUGIN_XINLAKE_PLATFORM_PLUGIN_H_
