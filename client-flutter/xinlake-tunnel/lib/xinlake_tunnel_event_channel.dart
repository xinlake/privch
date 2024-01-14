import 'dart:async';

import 'package:flutter/services.dart';

import 'tunnel_state.dart';

class EventChannelXinlakeTunnel {
  /// broadcast stream
  final onState = StreamController<TunnelState>.broadcast();

  late final StreamSubscription _tunnelSubscription;

  EventChannelXinlakeTunnel() {
    _tunnelSubscription =
        const EventChannel("xinlake_tunnel_event").receiveBroadcastStream().listen(
      (event) {
        if (event is! Map) {
          return;
        }

        // state
        if (event.containsKey("state")) {
          try {
            onState.add(
              switch (event["state"] as int?) {
                1 => TunnelState.connecting,
                2 => TunnelState.connected,
                3 => TunnelState.connecting,
                4 => TunnelState.stopped,
                _ => throw (),
              },
            );
          } catch (exception) {
            // ignored
          }
        }
      },
    );
  }

  void dispose() async {
    await _tunnelSubscription.cancel();
  }
}
