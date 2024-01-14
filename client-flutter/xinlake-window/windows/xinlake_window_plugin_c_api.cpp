#include "include/xinlake_window/xinlake_window_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "xinlake_window_plugin.h"

void XinlakeWindowPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  xinlake_window::XinlakeWindowPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
