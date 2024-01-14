import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'xinlake_tunnel_event_channel.dart';
import 'xinlake_tunnel_method_channel.dart';

abstract class XinlakeTunnelPlatform extends PlatformInterface {
  /// Constructs a XinlakeTunnelPlatform.
  XinlakeTunnelPlatform() : super(token: _token);

  static final Object _token = Object();

  static final EventChannelXinlakeTunnel _eventInstance = EventChannelXinlakeTunnel();
  static EventChannelXinlakeTunnel get eventInstance => _eventInstance;

  // Method Channel ---
  static XinlakeTunnelPlatform _instance = MethodChannelXinlakeTunnel();

  /// The default instance of [XinlakeTunnelPlatform] to use.
  /// Defaults to [MethodChannelXinlakeTunnel].
  static XinlakeTunnelPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [XinlakeTunnelPlatform] when
  /// they register themselves.
  static set instance(XinlakeTunnelPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> connect(
    int port,
    String address,
    String password,
    String encrypt,
  ) {
    throw UnimplementedError('Not Implemented');
  }

  Future<void> stopTunnel() {
    throw UnimplementedError('Not Implemented');
  }

  Future<int?> getState() {
    throw UnimplementedError('Not Implemented');
  }

  Future<List<int>?> getTrafficBytes() {
    throw UnimplementedError('Not Implemented');
  }

  Future<void> updateSettings({
    int? proxyPort,
    int? dnsLocalPort,
    String? dnsRemoteAddress,
  }) {
    throw UnimplementedError('Not Implemented');
  }
}
