import 'package:flutter/services.dart';
import 'package:privch/data/types.dart';

/// * 2021-04-26
final XinMethod xinMethod = XinMethod();

class XinMethod {
  final MethodChannel _methodChannel = const MethodChannel("xinlake-method");

  static const toastShort = 0;
  static const toastLong = 1;

  // application ---------------------------------------------------------------
  Future<PackageInfo?> getPackageInfo() async {
    Map? map = await _methodChannel.invokeMapMethod("getPackageInfo");
    if (map != null) {
      return PackageInfo(
        map["versionName"],
        map["versionCode"],
        longVersionCode: map["longVersionCode"],
        // xinlake special
        buildTime: map["buildTime"],
        buildHost: map["buildHost"],
        buildUser: map["buildHost"],
      );
    }

    return null;
  }

  Future<bool> checkSelfPermission(String permission) async {
    bool? granted = await _methodChannel.invokeMethod("checkSelfPermission", {
      "permission": permission,
    });

    return granted ?? false;
  }

  // system --------------------------------------------------------------------
  Future<void> showToast(String message, {int duration = toastShort}) async {
    await _methodChannel.invokeMethod("showToast", {
      "message": message,
      "duration": duration,
    });
  }

  Future<bool> getNightMode() async {
    bool? nightMode = await _methodChannel.invokeMethod("getNightMode");
    return nightMode ?? false;
  }

  Future<void> setNavigationBar(int color, {int? dividerColor, int? animate}) async {
    await _methodChannel.invokeMethod("setNavigationBar", {
      "color": color,
      "dividerColor": dividerColor,
      "animate": animate,
    });
  }

  // networks ------------------------------------------------------------------
  Future<String?> requestGeoLocation(String ip) async {
    String? location = await _methodChannel.invokeMethod("requestGeoLocation", {
      "ip": ip,
    });

    return location;
  }

  Future<TrafficBytes?> getSelfTrafficBytes() async {
    Map? map = await _methodChannel.invokeMapMethod("getSelfTrafficBytes");
    if (map != null) {
      return TrafficBytes(
        DateTime.now(),
        map["rx"],
        map["tx"],
      );
    }

    return null;
  }
}

class PackageInfo {
  String versionName;
  int versionCode;
  int? longVersionCode;

  // xinlake special
  String? buildTime;
  String? buildHost;
  String? buildUser;

  PackageInfo(
    this.versionName,
    this.versionCode, {
    this.longVersionCode,
    this.buildTime,
    this.buildHost,
    this.buildUser,
  });
}
