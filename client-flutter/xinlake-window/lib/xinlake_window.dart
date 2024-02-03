import 'window_placement.dart';
import 'xinlake_window_platform_interface.dart';

export 'window_placement.dart';

class XinlakeWindow {
  /// Subscript to window events.
  /// * onPlacement: Callback when the window size or position has changed.
  void startListen({
    required void Function(WindowPlacement) onPlacement,
  }) {
    XinlakeWindowPlatform.instance.startListen(onPlacement: onPlacement);
  }

  /// Cancel window events subscription
  Future<void> stopListen() {
    return XinlakeWindowPlatform.instance.stopListen();
  }

  /// Get window position and size
  Future<WindowPlacement?> getWindowPlacement() {
    return XinlakeWindowPlatform.instance.getWindowPlacement();
  }

  /// Set window position and size, effective immediately
  Future<bool> setWindowPlacement(WindowPlacement placement) {
    return XinlakeWindowPlatform.instance.setWindowPlacement(placement);
  }

  /// Return True if the window is in full-screen mode, else False
  Future<bool> getFullScreen() {
    return XinlakeWindowPlatform.instance.getFullScreen();
  }

  /// Set window full-screen mode, effective immediately
  Future<void> setFullScreen(bool isFullScreen) async {
    return XinlakeWindowPlatform.instance.setFullScreen(isFullScreen);
  }

  /// Toggle window full-screen mode, effective immediately
  Future<void> toggleFullScreen() async {
    return XinlakeWindowPlatform.instance.toggleFullScreen();
  }

  /// Get window minimal and maximal size
  Future<(int, int, int, int)?> getWindowLimit() async {
    return XinlakeWindowPlatform.instance.getWindowLimit();
  }

  /// Set window minimal and maximal size, effective immediately
  Future<bool> setWindowLimit(
    int minWidth,
    int minHeight,
    int maxWidth,
    int maxHeight,
  ) async {
    return XinlakeWindowPlatform.instance.setWindowLimit(
      minWidth,
      minHeight,
      maxWidth,
      maxHeight,
    );
  }

  /// Unset (don't limit) window minimal and maximal size
  Future<void> resetWindowLimit() async {
    return XinlakeWindowPlatform.instance.resetWindowLimit();
  }

  /// Sets the window topmost mode, if set to True the window will appear sticky
  Future<void> setStayOnTop(bool isStayOnTop) async {
    return XinlakeWindowPlatform.instance.setStayOnTop(isStayOnTop);
  }
}
