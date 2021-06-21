import 'dart:async';

import 'package:flutter/material.dart';
import 'package:privch/platform/vpn_method.dart';
import 'package:privch/public.dart';
import 'package:privch/data/preference.dart';
import 'package:privch/data/shadowsocks.dart';
import 'package:privch/data/types.dart';
import 'package:privch/page/home_drawer.dart';
import 'package:privch/page/shadowsocks_detail.dart';
import 'package:privch/platform/data_method.dart';
import 'package:privch/platform/xin_method.dart';
import 'package:privch/widget/shadowsocks_list.dart';
import 'package:privch/widget/service_button.dart';
import 'package:privch/widget/traffic_flchart.dart';

/// home option menu items
final List<OptionView> _actionList = <OptionView>[
  // 0-2 items are also used as empty list actions
  OptionView(Icons.camera_alt, "Scan QRCode ...", Options.ImportQrCamera),
  OptionView(Icons.image, "Import form image ...", Options.ImportQrImage),
  OptionView(Icons.code, "Create new ...", Options.NewShadowsocks),
  OptionView(Icons.add_location, "Update GeoLocation ...", Options.AddGeoLocation),
];

class HomePage extends StatefulWidget {
  HomePage(this.title);

  // Fields in a Widget subclass are always marked "final".
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // import ss by the qrCode from camera scan
  void _actionImportQrCamera() async {
    Map? ssMap = await dataMethod.importQrCamera(
      prefix: "ss://",
    );

    if (ssMap != null) {
      Shadowsocks ss = Shadowsocks(map: ssMap);
      if (ssManager.contains(ss)) {
        ssManager.replaceById(ss);
        await xinMethod.showToast("${ss.name} updated");
      } else {
        ssManager.add(ss);
      }
    }
  }

  // import multi ss by the qrCode images from image pick
  void _actionImportQrImage() async {
    List? imageList = await dataMethod.importQrImage(
      "Select QRCode image",
      Theme.of(context).primaryColor,
      maxSelect: 20,
    );

    if (imageList != null) {
      List<Shadowsocks> addList = [];

      imageList.forEach((ssMap) async {
        Shadowsocks ss = Shadowsocks(map: ssMap);
        if (ssManager.contains(ss)) {
          ssManager.replaceById(ss);
          await xinMethod.showToast("${ss.name} updated");
        } else {
          // avoid duplicate items in addList
          if (!addList.contains(ss)) {
            addList.add(ss);
          }
        }
      });

      ssManager.addAll(addList);
      String servers = addList.length > 1 ? "servers" : "server";
      await xinMethod.showToast("${addList.length} $servers imported");
    }
  }

  void _actionNewShadowsocks() {
    Navigator.of(context).push(createRoute(
      ShadowsocksDetailPage(
        Shadowsocks(),
        (shadowsocks) async {
          final int? id = await dataMethod.insertShadowsocks(shadowsocks);
          if (id != null) {
            shadowsocks.id = id;
            ssManager.add(shadowsocks);
          }
        },
      ),
      begin: Offset(1.0, 0.0),
    ));
  }

  void _actionAddGeoLocation() async {}

  Future<void> _onShadowsocksTap(Shadowsocks shadowsocks) async {
    if (shadowsocks.id == preference.currentServerId.value) {
      return;
    }

    // change remote server
    await vpnMethod.updateShadowsocks(shadowsocks);
  }

  void _onShadowsocksDetail(Shadowsocks shadowsocks) {
    // navigate to shadowsocks details
    Navigator.of(context).push(createRoute(
      ShadowsocksDetailPage(
        shadowsocks.copy(),
        (ss) => ssManager.replaceById(ss),
      ),
      begin: Offset(1.0, 0.0),
    ));
  }

  Future<void> _onShadowsocksRemove(int index, Shadowsocks shadowsocks) async {
    if (await dataMethod.deleteShadowsocks(shadowsocks.id)) {
      // show snackbar message when the deletion is successful
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 2),
        content: Text("${shadowsocks.name} removed"),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () async {
            final int? id = await dataMethod.insertShadowsocks(shadowsocks);
            if (id != null) {
              shadowsocks.id = id;
              ssManager.insert(index, shadowsocks);
            }
          },
        ),
      ));
    }
  }

  void _onSortMenuSelected(String sortMethod) {
    ssManager.sort(sortMethod);
  }

  void _onMoreMenuSelected(OptionView optionView) {
    switch (optionView.option) {
      case Options.ImportQrCamera:
        _actionImportQrCamera();
        break;
      case Options.ImportQrImage:
        _actionImportQrImage();
        break;
      case Options.NewShadowsocks:
        _actionNewShadowsocks();
        break;
      case Options.AddGeoLocation:
        _actionAddGeoLocation();
        break;
    }
  }

  Widget _buildSortMenu() {
    return PopupMenuButton<String>(
      onSelected: _onSortMenuSelected,
      icon: Icon(Icons.sort_sharp),
      itemBuilder: (context) {
        return ssSortMethods.map((item) {
          return PopupMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList();
      },
    );
  }

  Widget _buildMoreMenu() {
    return PopupMenuButton<OptionView>(
      onSelected: _onMoreMenuSelected,
      icon: Icon(Icons.more_vert_sharp),
      itemBuilder: (context) {
        return _actionList.map((item) {
          return PopupMenuItem<OptionView>(
            value: item,
            child: Row(
              children: [
                Icon(item.icon, color: Theme.of(context).textTheme.caption!.color),
                SizedBox(width: 10),
                Text(item.text),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          _buildSortMenu(),
          _buildMoreMenu(),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: ShadowsocksList(
              _onShadowsocksTap,
              _onShadowsocksDetail,
              _onShadowsocksRemove,
              _actionList.sublist(0, 3),
              _onMoreMenuSelected,
            ),
          ),
          Stack(
            children: [
              TrafficChart(),
              Positioned.fill(
                //padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: ServiceButton(),
              ),
            ],
          ),
        ],
      ),
      drawer: HomeDrawer(widget.title),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  // fixme - not invoked
  @override
  void dispose() {
    super.dispose();
  }
}
