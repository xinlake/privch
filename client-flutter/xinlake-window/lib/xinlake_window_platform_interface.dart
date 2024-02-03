import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'window_placement.dart';
import 'xinlake_window_method_channel.dart';

abstract class XinlakeWindowPlatform extends PlatformInterface {
  /// Constructs a XinlakeWindowPlatform.
  XinlakeWindowPlatform() : super(token: _token);

  static final Object _token = Object();

  static XinlakeWindowPlatform _instance = MethodChannelXinlakeWindow();

  /// The default instance of [XinlakeWindowPlatform] to use.
  /// Defaults to [MethodChannelXinlakeWindow].
  static XinlakeWindowPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [XinlakeWindowPlatform] when
  /// they register themselves.
  static set instance(XinlakeWindowPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  void startListen({
    required void Function(WindowPlacement) onPlacement,
  }) {
    throw UnimplementedError('Not Implemented.');
  }

  Future<void> stopListen() {
    throw UnimplementedError('Not Implemented.');
  }

  Future<WindowPlacement?> getWindowPlacement() {
    throw UnimplementedError('Not Implemented.');
  }

  Future<bool> setWindowPlacement(WindowPlacement placement) {
    throw UnimplementedError('Not Implemented.');
  }

  Future<bool> getFullScreen() {
    throw UnimplementedError('Not Implemented.');
  }

  Future<void> setFullScreen(bool isFullScreen) {
    throw UnimplementedError('Not Implemented.');
  }

  Future<void> toggleFullScreen() {
    throw UnimplementedError('Not Implemented.');
  }

  Future<(int, int, int, int)?> getWindowLimit() {
    throw UnimplementedError('Not Implemented.');
  }

  Future<bool> setWindowLimit(int minWidth, int minHeight, int maxWidth, int maxHeight) {
    throw UnimplementedError('Not Implemented.');
  }

  Future<void> resetWindowLimit() {
    throw UnimplementedError('Not Implemented.');
  }

  Future<void> setStayOnTop(bool isStayOnTop) {
    throw UnimplementedError('Not Implemented.');
  }
}
