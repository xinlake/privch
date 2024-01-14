#ifndef FLUTTER_PLUGIN_XINLAKE_TUNNEL_PLUGIN_H_
#define FLUTTER_PLUGIN_XINLAKE_TUNNEL_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace xinlake_tunnel {

    class XinlakeTunnelPlugin : public flutter::Plugin {
    public:
        static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

        XinlakeTunnelPlugin();
        virtual ~XinlakeTunnelPlugin();

        // Disallow copy and assign.
        XinlakeTunnelPlugin(const XinlakeTunnelPlugin&) = delete;
        XinlakeTunnelPlugin& operator=(const XinlakeTunnelPlugin&) = delete;

    private:
        // Called when a method is called on this plugin's channel from Dart.
        void HandleMethodCall(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    };

}  // namespace xinlake_tunnel

#endif  // FLUTTER_PLUGIN_XINLAKE_TUNNEL_PLUGIN_H_
