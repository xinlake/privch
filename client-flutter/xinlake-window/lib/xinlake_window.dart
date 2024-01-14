import 'package:flutter/services.dart';

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

  /// Get window minimal size
  @Deprecated("Not working on Windows 11")
  Future<Size?> getWindowMinSize() async {
    return XinlakeWindowPlatform.instance.getWindowMinSize();
  }

  /// Set window minimal size, effective immediately
  @Deprecated("Not working on Windows 11")
  Future<bool> setWindowMinSize(int width, int height) async {
    return XinlakeWindowPlatform.instance.setWindowMinSize(width, height);
  }

  /// Unset (don't limit) window minimal size
  @Deprecated("Not working on Windows 11")
  Future<void> resetWindowMinSize() async {
    return XinlakeWindowPlatform.instance.resetWindowMinSize();
  }

  /// Get window maximal size
  @Deprecated("Not working on Windows 11")
  Future<Size?> getWindowMaxSize() async {
    return XinlakeWindowPlatform.instance.getWindowMaxSize();
  }

  /// Set window maximal size, effective immediately
  @Deprecated("Not working on Windows 11")
  Future<bool> setWindowMaxSize(int width, int height) async {
    return XinlakeWindowPlatform.instance.setWindowMaxSize(width, height);
  }

  /// Unset (don't limit) window maximal size
  @Deprecated("Not working on Windows 11")
  Future<void> resetWindowMaxSize() async {
    return XinlakeWindowPlatform.instance.resetWindowMinSize();
  }

  /// Sets the window topmost mode, if set to True the window will appear sticky
  Future<void> setStayOnTop(bool isStayOnTop) async {
    return XinlakeWindowPlatform.instance.setStayOnTop(isStayOnTop);
  }
}
