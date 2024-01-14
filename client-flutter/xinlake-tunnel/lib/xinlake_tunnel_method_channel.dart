import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'xinlake_tunnel_platform_interface.dart';

/// An implementation of [XinlakeTunnelPlatform] that uses method channels.
class MethodChannelXinlakeTunnel extends XinlakeTunnelPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('xinlake_tunnel_method');

  @override
  Future<void> connect(
    int port,
    String address,
    String password,
    String encrypt,
  ) async {
    await methodChannel.invokeMethod("connect", {
      "port": port,
      "address": address,
      "password": password,
      "encrypt": encrypt,
    });
  }

  @override
  Future<void> stopTunnel() async {
    await methodChannel.invokeMethod("stopTunnel");
  }

  @override
  Future<int?> getState() async {
    try {
      final state = await methodChannel.invokeMethod<int>("getState");
      return state;
    } catch (exception) {
      return null;
    }
  }

  @override
  Future<List<int>?> getTrafficBytes() async {
    try {
      final trafficTxRx = await methodChannel.invokeListMethod<int>("getTrafficBytes");
      return trafficTxRx;
    } catch (exception) {
      return null;
    }
  }

  @override
  Future<void> updateSettings({
    int? proxyPort,
    int? dnsLocalPort,
    String? dnsRemoteAddress,
  }) async {
    await methodChannel.invokeMethod("updateSettings", {
      "proxyPort": proxyPort,
      "dnsLocalPort": dnsLocalPort,
      "dnsRemoteAddress": dnsRemoteAddress,
    });
  }
}
