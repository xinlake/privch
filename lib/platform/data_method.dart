import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:privch/data/shadowsocks.dart';

/// * 2021-04-26
final DataMethod dataMethod = DataMethod();

class DataMethod {
  final MethodChannel _methodChannel = const MethodChannel("data-method");

  static const cameraFacingFront = 0;
  static const cameraFacingBack = 1;
  static const cameraAnalyzerZxing = "zxing";
  static const cameraAnalyzerMlkit = "mlkit";

  // database shadowsocks ------------------------------------------------------
  Future<int> getShadowsocksCount() async {
    int? count = await _methodChannel.invokeMethod("getShadowsocksCount");
    return count ?? 0;
  }

  Future<List<Map>?> getAllShadowsocks() async {
    List<Map>? mapList = await _methodChannel.invokeListMethod("getAllShadowsocks");
    return mapList;
  }

  Future<int> updateAllShadowsocks(List<Shadowsocks> updateList) async {
    List<Map<String, dynamic>> mapList = updateList.map((ss) => ss.toMap()).toList();
    int? count = await _methodChannel.invokeMethod("updateAllShadowsocks", mapList);
    return count ?? 0;
  }

  Future<int?> insertShadowsocks(Shadowsocks ss) async {
    int? id = await _methodChannel.invokeMethod("insertShadowsocks", ss.toMap());
    return id;
  }

  Future<bool> deleteShadowsocks(int id) async {
    bool? deleted = await _methodChannel.invokeMethod("deleteShadowsocks", {
      "id": id,
    });

    return deleted ?? false;
  }

  Future<Map?> importQrCamera({
    int facing = cameraFacingBack,
    String analyzer = cameraAnalyzerZxing,
    String? prefix,
  }) async {
    Map? ssMap = await _methodChannel.invokeMapMethod("importQrCamera", {
      "facing": facing,
      "analyzer": analyzer,
      "prefix": prefix,
    });

    return ssMap;
  }

  // import multi ss qrCode form images
  Future<List?> importQrImage(
    String title,
    Color primaryColor, {
    int maxSelect = 1,
  }) async {
    List? mapList = await _methodChannel.invokeListMethod("importQrImage", {
      "title": title,
      "primaryColor": primaryColor.value,
      "maxSelect": maxSelect,
    });

    return mapList;
  }

  // develop
  Future<int> devGenerateShadowsocks(int count) async {
    int? added = await _methodChannel.invokeMethod("devGenerateShadowsocks", {
      "count": count,
    });

    return added ?? 0;
  }

  // preference --------------------------------------------------------------------------
  Future<Map?> readPreference() async {
    Map? map = await _methodChannel.invokeMapMethod("readPreference");
    return map;
  }

  Future<int> writePreference(Map map) async {
    int? applyCount = await _methodChannel.invokeMethod("writePreference", map);
    return applyCount ?? 0;
  }
}
