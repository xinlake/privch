import 'package:flutter/material.dart';
import 'package:privch/page/about.dart';
import 'package:privch/page/settings.dart';
import 'package:privch/platform/xin_method.dart';
import 'package:privch/public.dart';

class HomeDrawer extends StatefulWidget {
  HomeDrawer(this.title);

  final String title;

  @override
  State<StatefulWidget> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  Future<void> _onShadowsocks() async {
    await xinMethod.showToast("Building...");
  }

  Future<void> _onV2Ray() async {
    await xinMethod.showToast("Building...");
  }

  /// navigate to settings
  void _onTapSetting() {
    Navigator.of(context).pop();
    Navigator.of(context).push(createRoute(
      SettingPage(),
    ));
  }

  void _onTapAbout() {
    Navigator.of(context).pop();
    Navigator.of(context).push(createRoute(
      HelpAboutPage(),
    ));
  }

  Widget _buildMenuItem(IconData iconData, String title, void Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Icon(iconData),
            SizedBox(width: 10),
            Text(title),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: 40),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              widget.title,
              style: themeData.textTheme.headline6,
            ),
          ),
          Divider(height: 10),
          _buildMenuItem(Icons.storage, "Shadowsocks", _onShadowsocks),
          _buildMenuItem(Icons.storage, "V2Ray", _onV2Ray),
          // Spacer(),
          Divider(height: 10),
          _buildMenuItem(Icons.settings, "Setting", _onTapSetting),
          _buildMenuItem(Icons.feedback, "About", _onTapAbout),
          //SizedBox(height: 20),
        ],
      ),
    );
  }
}
