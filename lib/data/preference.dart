import 'package:flutter/material.dart';
import 'package:privch/platform/data_method.dart';

/// global preference
final Preference preference = Preference();

Future<void> loadPreference() async {
  Map? map = await dataMethod.readPreference();
  if (map != null) {
    preference.loadMap(map);
  }
}

Future<void> savePreference() async {
  Map map = preference.toMap();
  await dataMethod.writePreference(map);
}

/// * When value is replaced with something that is not equal to the old value
/// as evaluated by the equality operator ==, this class notifies its listeners.
/// * 2021-03
class Preference {
  int proxyPort = -1;
  int localDnsPort = -1;
  String remoteDnsAddress = "NULL";

  /// current server's id
  ValueNotifier<int> currentServerId = ValueNotifier(-1);

  /// 0: system, 1: light, 2: dark.
  ValueNotifier<int> themeSetting = ValueNotifier(0);

  ThemeMode get themeMode {
    if (themeSetting.value == 1) {
      return ThemeMode.light;
    } else if (themeSetting.value == 2) {
      return ThemeMode.dark;
    } else {
      return ThemeMode.system;
    }
  }

  void loadMap(Map map) {
    currentServerId.value = map["current-server-id"];
    themeSetting.value = map["theme-setting"];
    // network
    proxyPort = map["proxy-port"];
    localDnsPort = map["local-dns-port"];
    remoteDnsAddress = map["remote-dns-address"];
  }

  Map<String, Object> toMap() {
    return {
      "current-server-id": currentServerId.value,
      "theme-setting": themeSetting.value,
      // network
      "proxy-port": proxyPort,
      "local-dns-port": localDnsPort,
      "remote-dns-address": remoteDnsAddress,
    };
  }

  /// theme mode names
  static final themeList = <String>[
    "System",
    "Light",
    "Dark",
  ];
}
