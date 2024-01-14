#include "include/xinlake_qrcode/xinlake_qrcode_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "xinlake_qrcode_plugin.h"

void XinlakeQrcodePluginCApiRegisterWithRegistrar(FlutterDesktopPluginRegistrarRef registrar) {
    XinlakeQrcode::XinlakeQrcodePlugin::RegisterWithRegistrar(
        flutter::PluginRegistrarManager::GetInstance()
        ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
