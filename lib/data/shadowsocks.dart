import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:privch/data/preference.dart';
import 'package:privch/platform/data_method.dart';
import 'package:privch/platform/xin_method.dart';
import 'package:privch/public.dart';

/// shadowsocks server manager
final SSManager ssManager = SSManager();

class SSManager extends ChangeNotifier {
  final List<Shadowsocks> _ssList = [];

  // properties
  bool get isNotEmpty => _ssList.isNotEmpty;
  bool get isEmpty => _ssList.isEmpty;
  int get length => _ssList.length;

  Future<void> load() async {
    List<Map>? mapList = await dataMethod.getAllShadowsocks();
    mapList?.forEach((element) {
      _ssList.add(Shadowsocks(map: element));
    });
  }

  Future<void> save() async {
    for (int i = 0; i < _ssList.length; ++i) {
      _ssList[i].order = i;
    }
    await dataMethod.updateAllShadowsocks(_ssList);
  }

  Future<void> generateRandom({int count = 5}) async {
    int count = await dataMethod.devGenerateShadowsocks(5);
    await xinMethod.showToast("$count Shadowsocks generated");
    if (count < 1) {
      // generate fail
      return;
    }

    // reload
    _ssList.clear();
    await load();
    notifyListeners();
  }

  void sort(String method) {
    if (method == ssSortMethods[0]) {
      // last modified
      _ssList.sort((ss1, ss2) {
        return -ss1.modified.compareTo(ss2.modified);
      });
    } else if (method == ssSortMethods[1]) {
      // by name
      _ssList.sort((ss1, ss2) {
        return ss1.name.compareTo(ss2.name);
      });
    } else if (method == ssSortMethods[2]) {
      // by address
      _ssList.sort((ss1, ss2) {
        return ss1.address.compareTo(ss2.address);
      });
    } else if (method == ssSortMethods[3]) {
      // by port
      _ssList.sort((ss1, ss2) {
        return ss1.port.compareTo(ss2.port);
      });
    } else {
      // invalid method
      return;
    }

    notifyListeners();
  }

  bool contains(Shadowsocks ss) {
    return _ssList.contains(ss);
  }

  void add(Shadowsocks ss) {
    _ssList.add(ss);
    notifyListeners();
  }

  void addAll(Iterable<Shadowsocks> iterable) {
    _ssList.addAll(iterable);
    notifyListeners();
  }

  void insert(int index, Shadowsocks ss) {
    _ssList.insert(index, ss);
    notifyListeners();
  }

  Shadowsocks removeAt(int index) {
    Shadowsocks ss = _ssList.removeAt(index);
    notifyListeners();

    return ss;
  }

  void replaceById(Shadowsocks ss) {
    int index = _ssList.indexOf(ss);
    _ssList.removeAt(index);
    _ssList.insert(index, ss);

    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final Shadowsocks ss = _ssList.removeAt(oldIndex);
    _ssList.insert(newIndex, ss);

    notifyListeners();
  }

  Shadowsocks getAt(int index) {
    return _ssList[index];
  }

  void updateGeoLocation() {
    _ssList.forEach((ss) async {
      String? geoLocation = await xinMethod.requestGeoLocation(ss.address);
      ss.geoLocation.value = geoLocation;
    });
  }

  Shadowsocks? getSelection() {
    try {
      return _ssList.firstWhere(
        (element) => element.id == preference.currentServerId.value,
      );
    } catch (exception) {
      return null;
    }
  }
}

/// * 2021-03
class Shadowsocks {
  late int id;

  // server
  late String encrypt;
  late String password;
  late String address;
  late int port;

  // remarks
  late String name;
  late String modified;
  late int order;

  // statistics
  ValueNotifier<int> responseTime = ValueNotifier(0);
  ValueNotifier<String?> geoLocation = ValueNotifier(null);

  Shadowsocks({Map? map}) {
    if (map != null) {
      _readMap(map);
    } else {
      // 0 means auto
      id = 0;

      encrypt = "none";
      password = "";
      address = "";
      port = 0;

      name = "";
      modified = dateFormat.format(DateTime.now());
      order = 0;
    }
  }

  /// batter?
  Shadowsocks copy() {
    return Shadowsocks(map: toMap())..modified = dateFormat.format(DateTime.now());
  }

  /// ss://BASE64-WITHOUT-PADDING["method:password@hostname:port"]
  /// https://shadowsocks.org/en/config/quick-guide.html
  String encodeBase64() {
    List<int> bytes = utf8.encode("$encrypt:$password@$address:$port");
    String code = base64.encode(bytes);
    return "ss://$code";
  }

  void _readMap(Map map) {
    id = map["id"];

    // server
    port = map["port"];
    address = map["address"];
    password = map["password"];
    encrypt = map["encrypt"];

    // remarks
    name = map["name"];
    modified = map["modified"];
    order = map["order"];

    // statistics
    responseTime.value = map["responseTime"];
    geoLocation.value = map["geoLocation"];
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,

      // server
      "port": port,
      "address": address,
      "password": password,
      "encrypt": encrypt,

      // remarks
      "name": name,
      "modified": modified,
      "order": order,

      // statistics
      "responseTime": responseTime.value,
      "geoLocation": geoLocation.value,
    };
  }

  @override
  bool operator ==(ss) => ss is Shadowsocks && ss.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// shadowsocks sort methods
const List<String> ssSortMethods = ["Last Modified", "Name", "Address", "Port"];

/// shadowsocks 1.9.0
const List<String> ssEncryptMethods = [
  "plain",
  "none",
  "table",
  "rc4-md5",
  "rc4",
  "aes-128-ctr",
  "aes-192-ctr",
  "aes-256-ctr",
  "aes-128-cfb",
  "aes-128-cfb1",
  "aes-128-cfb8",
  "aes-128-cfb128",
  "aes-192-cfb",
  "aes-192-cfb1",
  "aes-192-cfb8",
  "aes-192-cfb128",
  "aes-256-cfb",
  "aes-256-cfb1",
  "aes-256-cfb8",
  "aes-256-cfb128",
  "aes-128-ofb",
  "aes-192-ofb",
  "aes-256-ofb",
  "aes-128-gcm",
  "aes-256-gcm",
  "camellia-128-ctr",
  "camellia-192-ctr",
  "camellia-256-ctr",
  "camellia-128-cfb",
  "camellia-128-cfb1",
  "camellia-128-cfb8",
  "camellia-128-cfb128",
  "camellia-192-cfb",
  "camellia-192-cfb1",
  "camellia-192-cfb8",
  "camellia-192-cfb128",
  "camellia-256-cfb",
  "camellia-256-cfb1",
  "camellia-256-cfb8",
  "camellia-256-cfb128",
  "camellia-128-ofb",
  "camellia-192-ofb",
  "camellia-256-ofb",
  "chacha20-ietf",
  "chacha20-ietf-poly1305",
];
