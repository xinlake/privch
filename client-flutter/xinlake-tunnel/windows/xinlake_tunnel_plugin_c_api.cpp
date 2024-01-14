#include "include/xinlake_tunnel/xinlake_tunnel_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "xinlake_tunnel_plugin.h"

void XinlakeTunnelPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
    xinlake_tunnel::XinlakeTunnelPlugin::RegisterWithRegistrar(
        flutter::PluginRegistrarManager::GetInstance()
        ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
