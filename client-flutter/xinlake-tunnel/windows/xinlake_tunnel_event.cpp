
#include <flutter/event_channel.h>
#include <flutter/standard_method_codec.h>

static std::unique_ptr<flutter::EventSink<>> _eventSink = nullptr;

void notifyMessage(std::string message) {
    if (_eventSink != nullptr) {
        auto events = flutter::EncodableMap{
            {"message", message},
        };
        _eventSink->Success(events);
    }
}

void notifyServerChanged(int serverId) {
    if (_eventSink != nullptr) {
        auto events = flutter::EncodableMap{
            {"serverId", serverId},
        };
        _eventSink->Success(events);
    }
}

void notifyStateChanged(int state) {
    if (_eventSink != nullptr) {
        auto events = flutter::EncodableMap{
            {"state", state},
        };
        _eventSink->Success(events);
    }
}

void setEventSink(std::unique_ptr<flutter::EventSink<>>& eventSink) {
    _eventSink = std::move(eventSink);
}
