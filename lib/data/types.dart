import 'package:flutter/material.dart';

/// Network traffic
/// * 2021-03
class TrafficBytes {
  final DateTime time;
  final int rxBytes;
  final int txBytes;

  const TrafficBytes(this.time, this.rxBytes, this.txBytes);

  @override
  bool operator ==(trafficBytes) => trafficBytes is TrafficBytes && trafficBytes.time == time;

  @override
  int get hashCode => time.hashCode;
}

// Option
enum Options {
  ImportQrCamera,
  ImportQrImage,
  NewShadowsocks,
}

class OptionView {
  final IconData icon;
  final String text;
  final Options option;

  const OptionView(this.icon, this.text, this.option);
}
