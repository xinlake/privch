import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppRoute {
  static const initialize = "/initialize";
  static const home = "/home";
  static const shadowsocks = "/home/shadowsocks";
}

final dateFormatTime = DateFormat("HH:mm:ss");
final dateFormatDay = DateFormat("yyyy-MM-dd");
final dateFormatShort = DateFormat("MM/dd HH:mm");
final dateFormatLong = DateFormat("yyyy-MM-dd HH:mm:ss");

final primaryColors = {
  "Gold": const Color(0xffff8c00),
  "Rust": const Color(0xffda3b01),
  "Orchid": const Color(0xff9a0089),
  "Navy Blue": const Color(0xff0063b1),
  "Purple Shadow Dark": const Color(0xff6b69d6),
  "Moderate Violet": const Color(0xff6750a4),
  "Violet Red": const Color(0xff881798),
  "Cool Blue": const Color(0xff2d7d9a),
  "Sea Foam Teal": const Color(0xff038387),
  "Mint Dark": const Color(0xff018574),
  "Turf Green": const Color(0xff00cc6a),
  "Sport Green": const Color(0xff10893e),
  "Metal Blue": const Color(0xff515c6b),
  "Moss": const Color(0xff486860),
  "Meadow Green": const Color(0xff498205),
  "Storm": const Color(0xff4c4a48),
  "Liddy Green": const Color(0xff647c64),
  "Camouflage Desert": const Color(0xff847545),
};

/// Mobile OS, or Mobile Web
final isMobile = kIsWeb
    ? (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.fuchsia)
    : (Platform.isAndroid || Platform.isIOS || Platform.isFuchsia);

const lead2Width = 1050.0;
const leadWidth = 770.0;

final spacing = isMobile ? 8.0 : 10.0;
double getSpacing(BuildContext context) {
  return MediaQuery.of(context).size.shortestSide * 0.03;
}
