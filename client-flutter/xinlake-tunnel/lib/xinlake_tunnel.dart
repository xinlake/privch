import 'shadowsocks.dart';
import 'tunnel_state.dart';
import 'xinlake_tunnel_platform_interface.dart';

export 'shadowsocks.dart';
export 'tunnel_state.dart';

Stream<TunnelState> get onState => XinlakeTunnelPlatform.eventInstance.onState.stream;

Future<void> connect(Shadowsocks shadowsocks) {
  return XinlakeTunnelPlatform.instance.connect(
    shadowsocks.port,
    shadowsocks.address,
    shadowsocks.password,
    shadowsocks.encryption,
  );
}

Future<void> stopTunnel() {
  return XinlakeTunnelPlatform.instance.stopTunnel();
}

Future<TunnelState?> getState() async {
  return switch (await XinlakeTunnelPlatform.instance.getState()) {
    1 => TunnelState.connecting,
    2 => TunnelState.connected,
    3 => TunnelState.stopping,
    4 => TunnelState.stopped,
    _ => null,
  };
}

/// element 0: tx bytes, element 1: rx bytes
Future<List<int>?> getTrafficBytes() {
  return XinlakeTunnelPlatform.instance.getTrafficBytes();
}

/// This must be called once before connectTunnel
/// * [socksPort] local socks client listen port
///
/// Android
/// * [dnsLocalPort], [dnsRemoteAddress] dns settings
///
/// Windows
/// * [proxyPort] local http proxy listen port
///
/// [proxyPort] parameter used on Windows only
Future<void> updateSettings({
  int? proxyPort,
  int? dnsLocalPort,
  String? dnsRemoteAddress,
}) {
  return XinlakeTunnelPlatform.instance.updateSettings(
    proxyPort: proxyPort,
    dnsLocalPort: dnsLocalPort,
    dnsRemoteAddress: dnsRemoteAddress,
  );
}
