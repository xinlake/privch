#include <windows.h>

#include <flutter/event_channel.h>
#include <flutter/standard_method_codec.h>

static const int _eventPlacement = 10;
static std::unique_ptr<flutter::EventSink<>> _eventSink = nullptr;

void notifyPlacementChanged(RECT& rect) {
    if (_eventSink != nullptr) {
        auto events = flutter::EncodableMap{
            {"event", _eventPlacement},
            {"x", rect.left},
            {"y", rect.top},
            {"width", rect.right - rect.left},
            {"height", rect.bottom - rect.top},
        };
        _eventSink->Success(events);
    }
}

void setEventSink(std::unique_ptr<flutter::EventSink<>>& eventSink) {
    _eventSink = std::move(eventSink);
}
