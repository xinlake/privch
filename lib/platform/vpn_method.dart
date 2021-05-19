import 'package:flutter/services.dart';
import 'package:privch/data/shadowsocks.dart';

/// * 2021-04-26
final VpnMethod vpnMethod = VpnMethod();

class VpnMethod {
  final MethodChannel _methodChannel = const MethodChannel("vpn-method");

  Future<void> stopService() async {
    await _methodChannel.invokeMethod("stopService");
  }

  Future<void> updateShadowsocks(Shadowsocks shadowsocks) async {
    await _methodChannel.invokeMethod("updateShadowsocks", {
      "id": shadowsocks.id,
      "port": shadowsocks.port,
      "address": shadowsocks.address,
      "password": shadowsocks.password,
      "encrypt": shadowsocks.encrypt,
    });
  }

  Future<void> updateSettings({
    int? proxyPort,
    int? localDnsPort,
    String? remoteDnsAddress,
  }) async {
    await _methodChannel.invokeMethod("updateSettings", <String, Object?>{
      "proxyPort": proxyPort,
      "localDnsPort": localDnsPort,
      "remoteDnsAddress": remoteDnsAddress,
    });
  }
}
