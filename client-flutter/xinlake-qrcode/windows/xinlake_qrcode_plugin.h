#ifndef FLUTTER_PLUGIN_XINLAKE_QRCODE_PLUGIN_H_
#define FLUTTER_PLUGIN_XINLAKE_QRCODE_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace XinlakeQrcode {

    class XinlakeQrcodePlugin : public flutter::Plugin {
    public:
        static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

        XinlakeQrcodePlugin();
        virtual ~XinlakeQrcodePlugin();

        // Disallow copy and assign.
        XinlakeQrcodePlugin(const XinlakeQrcodePlugin&) = delete;
        XinlakeQrcodePlugin& operator=(const XinlakeQrcodePlugin&) = delete;

    private:
        // Called when a method is called on this plugin's channel from Dart.
        void HandleMethodCall(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    };

}

#endif  // FLUTTER_PLUGIN_XINLAKE_QRCODE_PLUGIN_H_
