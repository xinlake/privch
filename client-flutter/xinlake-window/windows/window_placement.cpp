#include <windows.h>

#include <flutter/standard_method_codec.h>

extern void notifyPlacementChanged(RECT& rect);

/* internal
 */
static void updateWindowSize();
static LRESULT windowProc(HWND hWnd, UINT iMessage, WPARAM wParam, LPARAM lParam);//CALLBACK
static WNDPROC defWindowProc;

static int maxWidth = 0;
static int maxHeight = 0;
static int minWidth = 0;
static int minHeight = 0;

/* full screen
 */
void getFullScreen(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    HWND handle = GetActiveWindow();

    WINDOWPLACEMENT placement;
    GetWindowPlacement(handle, &placement);

    bool isFullScreen = (placement.showCmd == SW_MAXIMIZE);
    result->Success(flutter::EncodableValue(isFullScreen));
}

void setFullScreen(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

    bool isFullScreen = false;
    const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (arguments) {
        auto fs_it = arguments->find(flutter::EncodableValue("isFullScreen"));
        if (fs_it != arguments->end()) {
            isFullScreen = std::get<bool>(fs_it->second);
        }
    }

    HWND handle = GetActiveWindow();
    WINDOWPLACEMENT placement;
    GetWindowPlacement(handle, &placement);

    if (isFullScreen) {
        placement.showCmd = SW_MAXIMIZE;
        SetWindowPlacement(handle, &placement);
    } else {
        placement.showCmd = SW_NORMAL;
        SetWindowPlacement(handle, &placement);
    }

    result->Success(flutter::EncodableValue(nullptr));
}

void toggleFullScreen(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    HWND handle = GetActiveWindow();

    WINDOWPLACEMENT placement;
    GetWindowPlacement(handle, &placement);

    if (placement.showCmd == SW_MAXIMIZE) {
        placement.showCmd = SW_NORMAL;
        SetWindowPlacement(handle, &placement);
    } else {
        placement.showCmd = SW_MAXIMIZE;
        SetWindowPlacement(handle, &placement);
    }

    result->Success(flutter::EncodableValue(nullptr));
}

/* window placement
 */
void getWindowPlacement(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    HWND handle = GetActiveWindow();

    RECT rect;
    GetWindowRect(handle, &rect);
    LONG width = rect.right - rect.left;
    LONG height = rect.bottom - rect.top;

    flutter::EncodableMap map;
    map[flutter::EncodableValue("x")] = rect.left;
    map[flutter::EncodableValue("y")] = rect.top;
    map[flutter::EncodableValue("width")] = width;
    map[flutter::EncodableValue("height")] = height;

    result->Success(flutter::EncodableValue(map));
}

void setWindowPlacement(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

    int offsetX = 0;
    int offsetY = 0;
    int width = 0;
    int height = 0;
    const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (arguments) {
        auto offsetX_it = arguments->find(flutter::EncodableValue("x"));
        if (offsetX_it != arguments->end()) {
            offsetX = std::get<int>(offsetX_it->second);
        }

        auto offsetY_it = arguments->find(flutter::EncodableValue("y"));
        if (offsetY_it != arguments->end()) {
            offsetY = std::get<int>(offsetY_it->second);
        }

        auto width_it = arguments->find(flutter::EncodableValue("width"));
        if (width_it != arguments->end()) {
            width = std::get<int>(width_it->second);
        }

        auto height_it = arguments->find(flutter::EncodableValue("height"));
        if (height_it != arguments->end()) {
            height = std::get<int>(height_it->second);
        }
    }

    if (offsetX < 0 || offsetY < 0 || width < 1 || height < 1) {
        result->Error("Invalid argument", "width or height not provided");
        return;
    }

    HWND handle = GetActiveWindow();
    SetWindowPos(handle, HWND_TOP, offsetX, offsetY, width, height, SWP_SHOWWINDOW);

    result->Success(flutter::EncodableValue(nullptr));
}

/* min size
 */
void getWindowLimit(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

    flutter::EncodableMap map;
    map[flutter::EncodableValue("min-width")] = minWidth;
    map[flutter::EncodableValue("min-height")] = minHeight;
    map[flutter::EncodableValue("max-width")] = maxWidth;
    map[flutter::EncodableValue("max-height")] = maxHeight;

    result->Success(flutter::EncodableValue(map));
}

void setWindowLimit(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    int minW = 0;
    int minH = 0;
    int maxW = 0;
    int maxH = 0;

    const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (arguments) {
        auto minWidthIt = arguments->find(flutter::EncodableValue("min-width"));
        if (minWidthIt != arguments->end()) {
            minW = std::get<int>(minWidthIt->second);
        }
        auto minHeightIt = arguments->find(flutter::EncodableValue("min-height"));
        if (minHeightIt != arguments->end()) {
            minH = std::get<int>(minHeightIt->second);
        }
        auto maxWidthIt = arguments->find(flutter::EncodableValue("max-width"));
        if (maxWidthIt != arguments->end()) {
            maxW = std::get<int>(maxWidthIt->second);
        }
        auto maxHeightIt = arguments->find(flutter::EncodableValue("max-height"));
        if (maxHeightIt != arguments->end()) {
            maxH = std::get<int>(maxHeightIt->second);
        }
    }
    if (minW < 1 || minH < 1 || maxW < 1 || maxH < 1) {
        result->Error("Invalid argument", "width or height not provided");
        return;
    }

    minWidth = minW;
    minHeight = minH;
    maxWidth = maxW;
    maxHeight = maxH;

    HWND handle = GetActiveWindow();
    // before default window proc
    defWindowProc = reinterpret_cast<WNDPROC>(GetWindowLongPtr(handle, GWLP_WNDPROC));
    SetWindowLongPtr(handle, GWLP_WNDPROC, (LONG_PTR)windowProc);

    updateWindowSize();
    result->Success(flutter::EncodableValue(nullptr));
}

void resetWindowLimit(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    minWidth = 0;
    minHeight = 0;
    maxWidth = 0;
    maxHeight = 0;

    updateWindowSize();
    result->Success(flutter::EncodableValue(nullptr));
}

/* stay on top
 */
void setStayOnTop(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    bool stayOnTop = false;

    const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (arguments) {
        auto fs_it = arguments->find(flutter::EncodableValue("isStayOnTop"));
        if (fs_it != arguments->end()) {
            stayOnTop = std::get<bool>(fs_it->second);
        }
    }

    HWND hWnd = GetActiveWindow();

    RECT rect;
    GetWindowRect(hWnd, &rect);
    SetWindowPos(hWnd, stayOnTop ? HWND_TOPMOST : HWND_NOTOPMOST, rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top, SWP_SHOWWINDOW);

    result->Success(flutter::EncodableValue(nullptr));
}

/* internal
 */
static LRESULT windowProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam) {
    if (message == WM_GETMINMAXINFO) {
        bool changed = false;
        if (maxWidth > 0 && maxHeight > 0) {
            ((MINMAXINFO*)lParam)->ptMaxTrackSize.x = maxWidth;
            ((MINMAXINFO*)lParam)->ptMaxTrackSize.y = maxHeight;
            changed = true;
        }
        if (minWidth > 0 && minHeight > 0) {
            ((MINMAXINFO*)lParam)->ptMinTrackSize.x = minWidth;
            ((MINMAXINFO*)lParam)->ptMinTrackSize.y = minHeight;
            changed = true;
        }
        if (changed) {
            return FALSE;
        }
    } else if (message == WM_EXITSIZEMOVE) {
        RECT rect;
        GetWindowRect(hWnd, &rect);
        notifyPlacementChanged(rect);
    }

    return defWindowProc(hWnd, message, wParam, lParam);
}

// active size settings
static void updateWindowSize() {
    RECT rect;
    HWND handle = GetActiveWindow();
    GetWindowRect(handle, &rect);
    MoveWindow(handle, rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top, FALSE);
}
