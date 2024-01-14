#include "include/xinlake_platform/xinlake_platform_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "xinlake_platform_plugin.h"

void XinlakePlatformPluginCApiRegisterWithRegistrar(FlutterDesktopPluginRegistrarRef registrar) {
    XinlakePlatform::XinlakePlatformPlugin::RegisterWithRegistrar(
        flutter::PluginRegistrarManager::GetInstance()
        ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
