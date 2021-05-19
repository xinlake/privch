import 'package:flutter/material.dart';
import 'package:privch/data/shadowsocks.dart';
import 'package:privch/data/types.dart';
import 'package:privch/platform/platform_event.dart';
import 'package:privch/platform/vpn_method.dart';
import 'package:privch/platform/xin_method.dart';
import 'package:privch/public.dart';

class ServiceButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ServiceState();
}

class ServiceState extends State<ServiceButton> {
  Future<void> _onServiceButton() async {
    // empty
    if (ssManager.isEmpty) {
      await xinMethod.showToast("Please add servers");
      return;
    }

    if (dataEvent.isVpnRunning.value) {
      await vpnMethod.stopService();
    } else {
      Shadowsocks? selection = ssManager.getSelection();
      if (selection != null) {
        await vpnMethod.updateShadowsocks(selection);
      } else {
        await xinMethod.showToast("Please select a server");
      }
    }
  }

  Widget _buildIcon() {
    return ValueListenableBuilder(
      valueListenable: dataEvent.isVpnRunning,
      builder: (context, running, widget) {
        return Icon(
          Icons.security,
          color: (running ?? false) as bool ? Theme.of(context).accentColor : null,
          size: 45,
        );
      },
    );
  }

  Widget _buildTraffic() {
    return ValueListenableBuilder(
      valueListenable: dataEvent.trafficBytes,
      builder: (context, value, widget) {
        TrafficBytes trafficBytes = value as TrafficBytes;
        String rxSpeed = formatSize(trafficBytes.rxBytes);
        String txSpeed = formatSize(trafficBytes.txBytes);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              rxSpeed,
              textScaleFactor: 2.0,
            ),
            Text(txSpeed),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: _onServiceButton,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: _buildIcon(),
            ),
            Expanded(
              child: _buildTraffic(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
