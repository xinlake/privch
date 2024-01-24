#include "xinlake_window_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <sstream>

/* full screen
 */
extern void getFullScreen(const flutter::MethodCall<flutter::EncodableValue>& method_call,
	std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

extern void setFullScreen(const flutter::MethodCall<flutter::EncodableValue>& method_call,
	std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

extern void toggleFullScreen(const flutter::MethodCall<flutter::EncodableValue>& method_call,
	std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

/* window placement
 */
extern void getWindowPlacement(const flutter::MethodCall<flutter::EncodableValue>& method_call,
	std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

extern void setWindowPlacement(const flutter::MethodCall<flutter::EncodableValue>& method_call,
	std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

/* window limit
 */
extern void getWindowLimit(const flutter::MethodCall<flutter::EncodableValue>& method_call,
	std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

extern void setWindowLimit(const flutter::MethodCall<flutter::EncodableValue>& method_call,
	std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

extern void resetWindowLimit(const flutter::MethodCall<flutter::EncodableValue>& method_call,
	std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

/* stay on top
 */
extern void setStayOnTop(const flutter::MethodCall<flutter::EncodableValue>& method_call,
	std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

extern void initPlacement();

// event channel
extern void setEventSink(std::unique_ptr<flutter::EventSink<>>& eventSink);


namespace xinlake_window {

	// static
	void XinlakeWindowPlugin::RegisterWithRegistrar(
		flutter::PluginRegistrarWindows* registrar) {
		auto plugin = std::make_unique<XinlakeWindowPlugin>();

		auto eventHandler = std::make_unique<flutter::StreamHandlerFunctions<>>(
			[](const flutter::EncodableValue* arguments, std::unique_ptr<flutter::EventSink<>>&& events)
			-> std::unique_ptr<flutter::StreamHandlerError<>> {
				setEventSink(events);
				return nullptr;
			},
			[](const flutter::EncodableValue* arguments)
			-> std::unique_ptr<flutter::StreamHandlerError<>> {
				std::unique_ptr<flutter::EventSink<>> events = nullptr;
				setEventSink(events);
				return nullptr;
			});

		auto eventChannel = std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
			registrar->messenger(), "xinlake_window_event",
			&flutter::StandardMethodCodec::GetInstance());

		auto methodChannel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
			registrar->messenger(), "xinlake_window_method",
			&flutter::StandardMethodCodec::GetInstance());

		eventChannel->SetStreamHandler(std::move(eventHandler));
		methodChannel->SetMethodCallHandler(
			[plugin_pointer = plugin.get()](const auto& call, auto result) {
				plugin_pointer->HandleMethodCall(call, std::move(result));
			});

		registrar->AddPlugin(std::move(plugin));
	}

	XinlakeWindowPlugin::XinlakeWindowPlugin() {}

	XinlakeWindowPlugin::~XinlakeWindowPlugin() {}

	void XinlakeWindowPlugin::HandleMethodCall(
		const flutter::MethodCall<flutter::EncodableValue>& method_call,
		std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

		const std::string method_name = method_call.method_name();
		if (method_name == "getFullScreen") {
			getFullScreen(method_call, std::move(result));
		}
		else if (method_name == "setFullScreen") {
			setFullScreen(method_call, std::move(result));
		}
		else if (method_name == "toggleFullScreen") {
			toggleFullScreen(method_call, std::move(result));
		}
		else if (method_name == "getWindowPlacement") {
			getWindowPlacement(method_call, std::move(result));
		}
		else if (method_name == "setWindowPlacement") {
			setWindowPlacement(method_call, std::move(result));
		}
		else if (method_name == "getWindowLimit") {
			getWindowLimit(method_call, std::move(result));
		}
		else if (method_name == "setWindowLimit") {
			setWindowLimit(method_call, std::move(result));
		}
		else if (method_name == "resetWindowLimit") {
			resetWindowLimit(method_call, std::move(result));
		}
		else if (method_name == "setStayOnTop") {
			setStayOnTop(method_call, std::move(result));
		}
		else {
			result->NotImplemented();
		}
	}

}  // namespace xinlake_window
