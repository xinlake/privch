#ifndef FLUTTER_PLUGIN_XINLAKE_WINDOW_PLUGIN_H_
#define FLUTTER_PLUGIN_XINLAKE_WINDOW_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace xinlake_window {

class XinlakeWindowPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  XinlakeWindowPlugin();

  virtual ~XinlakeWindowPlugin();

  // Disallow copy and assign.
  XinlakeWindowPlugin(const XinlakeWindowPlugin&) = delete;
  XinlakeWindowPlugin& operator=(const XinlakeWindowPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace xinlake_window

#endif  // FLUTTER_PLUGIN_XINLAKE_WINDOW_PLUGIN_H_
