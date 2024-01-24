import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'window_placement.dart';
import 'xinlake_window_platform_interface.dart';

/// An implementation of [XinlakeWindowPlatform] that uses method channels.
class MethodChannelXinlakeWindow extends XinlakeWindowPlatform {
  // platform event subscription
  static const _eventPlacement = 10;

  StreamSubscription? _eventSubscription;

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('xinlake_window_method');
  final eventChannel = const EventChannel('xinlake_window_event');

  @override
  void startListen({
    required void Function(WindowPlacement) onPlacement,
  }) {
    _eventSubscription ??= eventChannel.receiveBroadcastStream().listen((data) {
      if (data is! Map || !data.containsKey('event')) {
        return;
      }

      // placement changed
      if (data['event'] == _eventPlacement) {
        try {
          final placement = WindowPlacement(
            x: data['x'],
            y: data['y'],
            width: data['width'],
            height: data['height'],
          );
          onPlacement.call(placement);
        } catch (exception) {
          // ignored
        }
      }
    });

    _eventSubscription!.resume();
  }

  @override
  Future<void> stopListen() async {
    await _eventSubscription?.cancel();
    _eventSubscription = null;
  }

  @override
  Future<WindowPlacement?> getWindowPlacement() async {
    final map = await methodChannel.invokeMapMethod<String, int>('getWindowPlacement');
    if (map != null) {
      return WindowPlacement(
        x: map['x']!,
        y: map['y']!,
        width: map['width']!,
        height: map['height']!,
      );
    }
    return null;
  }

  @override
  Future<bool> setWindowPlacement(WindowPlacement placement) async {
    try {
      await methodChannel.invokeMethod('setWindowPlacement', {
        'x': placement.x,
        'y': placement.y,
        'width': placement.width,
        'height': placement.height,
      });
      return true;
    } catch (exception) {
      // such as invalid arguments
      return false;
    }
  }

  @override
  Future<bool> getFullScreen() async {
    bool result = await methodChannel.invokeMethod('getFullScreen');
    return result;
  }

  @override
  Future<void> setFullScreen(bool isFullScreen) async {
    await methodChannel.invokeMethod('setFullScreen', {'isFullScreen': isFullScreen});
  }

  @override
  Future<void> toggleFullScreen() async {
    await methodChannel.invokeMethod('toggleFullScreen');
  }

  @override
  Future<(int, int, int, int)?> getWindowLimit() async {
    try {
      final map = await methodChannel.invokeMapMethod<String, int>('getWindowLimit');
      if (map != null) {
        return (
          map['min-width']!,
          map['min-height']!,
          map['max-width']!,
          map['max-height']!,
        );
      }
    } catch (error) {
      // ignored
    }

    return null;
  }

  @override
  Future<bool> setWindowLimit(
    int minWidth,
    int minHeight,
    int maxWidth,
    int maxHeight,
  ) async {
    try {
      await methodChannel.invokeMethod('setWindowLimit', {
        "min-width": minWidth,
        "min-height": minHeight,
        "max-width": maxWidth,
        "max-height": maxHeight,
      });
      return true;
    } catch (exception) {
      return false;
    }
  }

  @override
  Future<void> resetWindowLimit() async {
    await methodChannel.invokeMethod('resetWindowLimit');
  }

  @override
  Future<void> setStayOnTop(bool isStayOnTop) async {
    await methodChannel.invokeMethod('setStayOnTop', {'isStayOnTop': isStayOnTop});
  }
}
