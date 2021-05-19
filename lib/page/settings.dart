import 'package:flutter/material.dart';
import 'package:privch/data/preference.dart';
import 'package:privch/data/shadowsocks.dart';
import 'package:privch/library/validator/validators.dart';
import 'package:privch/platform/vpn_method.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<SettingPage> {
  final _formKey = GlobalKey<FormState>();

  Future<bool> _onBackPressed() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // update vpn settings
      await vpnMethod.updateSettings(
        proxyPort: preference.proxyPort,
        localDnsPort: preference.localDnsPort,
        remoteDnsAddress: preference.remoteDnsAddress,
      );
    }

    return true;
  }

  void _setTheme(int? value) {
    if (value != null) {
      preference.themeSetting.value = value;
      // when the theme is not actually changed the framework won't refresh app
      // e.g change theme mode from Light to System when the system theme mode is already Light
      setState(() {});
    }
  }

  Widget _buildCategory(String category) {
    ThemeData themeData = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 30),
        Text(
          category,
          style: themeData.textTheme.headline6,
        ),
        Divider(height: 15),
      ],
    );
  }

  Widget _buildNetworkSettings() {
    InputDecoration inputDecoration = InputDecoration(
      hintStyle: TextStyle(fontStyle: FontStyle.italic),
      contentPadding: EdgeInsets.symmetric(vertical: 5),
    );

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: TextFormField(
                  decoration: inputDecoration.copyWith(labelText: "Proxy Port"),
                  autovalidateMode: AutovalidateMode.always,
                  textAlignVertical: TextAlignVertical.bottom,
                  keyboardType: TextInputType.number,
                  initialValue: "${preference.proxyPort}",
                  validator: (value) {
                    return (value != null && isPort(value)) ? null : "Invalid port number";
                  },
                  onSaved: (value) {
                    if (value != null) {
                      preference.proxyPort = int.parse(value);
                    }
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: TextFormField(
                  decoration: inputDecoration.copyWith(labelText: "Local DNS Port"),
                  autovalidateMode: AutovalidateMode.always,
                  textAlignVertical: TextAlignVertical.bottom,
                  keyboardType: TextInputType.number,
                  initialValue: "${preference.localDnsPort}",
                  validator: (value) {
                    return (value != null && isPort(value)) ? null : "Invalid port number";
                  },
                  onSaved: (value) {
                    if (value != null) {
                      preference.localDnsPort = int.parse(value);
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          // remote dns address
          TextFormField(
            decoration: inputDecoration.copyWith(labelText: "Remote DNS Address"),
            autovalidateMode: AutovalidateMode.always,
            textAlignVertical: TextAlignVertical.bottom,
            keyboardType: TextInputType.url,
            initialValue: "${preference.remoteDnsAddress}",
            validator: (value) {
              return (value != null && isURL(value)) ? null : "Invalid url";
            },
            onSaved: (value) {
              if (value != null) {
                preference.remoteDnsAddress = value;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSetting() {
    return Row(
      children: [
        Column(
          children: <Widget>[
            Text(Preference.themeList[0]),
            Radio(
              value: 0,
              groupValue: preference.themeSetting.value,
              onChanged: _setTheme,
            ),
          ],
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: <Widget>[
              Text(Preference.themeList[1]),
              Radio(
                value: 1,
                groupValue: preference.themeSetting.value,
                onChanged: _setTheme,
              ),
            ],
          ),
        ),
        Column(
          children: <Widget>[
            Text(Preference.themeList[2]),
            Radio(
              value: 2,
              groupValue: preference.themeSetting.value,
              onChanged: _setTheme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDebug() {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.code),
            TextButton(
              onPressed: () async {
                await ssManager.generateRandom();
              },
              child: Text("Generate Shadowsocks"),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: Text("Settings"),
        ),
        body: Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 10),
          child: ListView(
            children: <Widget>[
              // theme settings
              _buildCategory("Theme"),
              _buildThemeSetting(),
              // network settings
              _buildCategory("Network"),
              _buildNetworkSettings(),
              // develop debug only
              _buildCategory("Develop options"),
              _buildDebug(),
            ],
          ),
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
