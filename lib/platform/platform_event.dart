import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:privch/data/preference.dart';
import 'package:privch/data/types.dart';
import 'package:privch/platform/xin_method.dart';

/// * 2021-04
final DataEvent dataEvent = DataEvent();

class DataEvent {
  ValueNotifier<TrafficBytes> trafficBytes = ValueNotifier(TrafficBytes(DateTime.now(), 0, 0));
  ValueNotifier<bool> isVpnRunning = ValueNotifier(false);
  ValueNotifier<bool> isNightMode = ValueNotifier(false);

  // platform event channel and subscription
  final _eventChannel = const EventChannel("privch-event");
  late StreamSubscription _subscriptionEvent;

  /// subscript to platform events
  void start() {
    _subscriptionEvent = _eventChannel.receiveBroadcastStream().listen(_onPlatformEvent);
  }

  /// cancel the subscription
  void stop() {
    _subscriptionEvent.cancel();
  }

  void _onPlatformEvent(dynamic events) {
    if (events is! Map) {
      return;
    }

    // traffic bytes
    if (events.containsKey("selfRx") && events.containsKey("selfTx")) {
      // traffic bytes
      int rxBytes = events["selfRx"];
      int txBytes = events["selfTx"];

      trafficBytes.value = TrafficBytes(DateTime.now(), rxBytes, txBytes);
    }

    // vpn server id
    if (events.containsKey("vpnServerId")) {
      preference.currentServerId.value = events["vpnServerId"];
    }

    // vpn running
    if (events.containsKey("vpnRunning")) {
      isVpnRunning.value = events["vpnRunning"];
    }

    if (events.containsKey("vpnMessage")) {
      var message = events["vpnMessage"];
      xinMethod.showToast(message);
    }

    // night mode
    if (events.containsKey("platformNightMode")) {
      isNightMode.value = events["platformNightMode"];
    }
  }
}
