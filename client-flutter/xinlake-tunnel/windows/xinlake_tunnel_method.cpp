#include <Windows.h>

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <variant>
#include <string>
#include <thread>

extern int localProxyPort;

// event 
extern void notifyMessage(std::string message);
extern void notifyServerChanged(int serverId);
extern void notifyStateChanged(int state);

// process
extern void startShadowsocks(
    int port, std::string& address, std::string& password, std::string& encrypt);
extern BOOL stopShadowsocks();
extern void restartShadowsocks(int proxyPort);

// proxy control
extern BOOL EnableProxy(int port);
extern BOOL DisableProxy();


// state
const int STATE_CONNECTING = 1;
const int STATE_CONNECTED = 2;
const int STATE_STOPPING = 3;
const int STATE_STOPPED = 4;

static int _tunnelState = STATE_STOPPED;
static void _setState(int state);


void connect(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

    int port = 0;
    int serverId = 0;
    std::string address;
    std::string password;
    std::string encrypt;

    // check arguments
    const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (arguments) {
        auto serverIdValue = arguments->find(flutter::EncodableValue("serverId"));
        if (serverIdValue != arguments->end()) {
            serverId = std::get<int>(serverIdValue->second);
        }

        auto portValue = arguments->find(flutter::EncodableValue("port"));
        if (portValue != arguments->end()) {
            port = std::get<int>(portValue->second);
        }

        auto addressValue = arguments->find(flutter::EncodableValue("address"));
        if (addressValue != arguments->end()) {
            address = std::get<std::string>(addressValue->second);
        }

        auto passwordValue = arguments->find(flutter::EncodableValue("password"));
        if (passwordValue != arguments->end()) {
            password = std::get<std::string>(passwordValue->second);
        }

        auto encryptValue = arguments->find(flutter::EncodableValue("encrypt"));
        if (encryptValue != arguments->end()) {
            encrypt = std::get<std::string>(encryptValue->second);
        }
    }

    if (serverId == 0 || port == 0 || address.empty() || password.empty() || encrypt.empty()) {
        result->Error("Invalid arguments");
        return;
    }

    // restart shadowsocks
    const int state = _tunnelState;
    _setState(STATE_CONNECTING);

    if (!stopShadowsocks()) {
        result->Error("Invalid state");
        _setState(state);
        return;
    }

    startShadowsocks(port, address, password, encrypt);
    std::this_thread::sleep_for(std::chrono::milliseconds(100));

    EnableProxy(localProxyPort);

    notifyServerChanged(serverId);
    _setState(STATE_CONNECTED);

    // send results
    result->Success(flutter::EncodableValue(nullptr));
}

void stopTunnel(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

    // stop shadowsocks
    const int state = _tunnelState;
    _setState(STATE_STOPPING);

    if (!stopShadowsocks()) {
        result->Error("Invalid state");
        _setState(state);
        return;
    }

    DisableProxy();

    _setState(STATE_STOPPED);
    result->Success(flutter::EncodableValue(nullptr));
}

void updateSettings(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    int proxyPort = -1;

    // check arguments
    const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (arguments) {
        auto proxyPortValue = arguments->find(flutter::EncodableValue("proxyPort"));
        if (proxyPortValue != arguments->end()) {
            proxyPort = std::get<int>(proxyPortValue->second);
        }
    }

    restartShadowsocks(proxyPort);
    result->Success(flutter::EncodableValue(nullptr));
}

static void _setState(int state) {
    _tunnelState = state;
    notifyStateChanged(state);
}
