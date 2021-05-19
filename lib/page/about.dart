import 'package:flutter/material.dart';
import 'package:privch/platform/xin_method.dart';

class HelpAboutPage extends StatefulWidget {
  @override
  _HelpAboutState createState() => _HelpAboutState();
}

class _HelpAboutState extends State<HelpAboutPage> {
  Widget _buildTitle() {
    Brightness brightness = Theme.of(context).brightness;
    return Column(
      //mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(20),
          alignment: Alignment.center,
          child: Icon(
            Icons.security,
            color: brightness == Brightness.light ? Colors.purple : Colors.lime,
            size: 64,
          ),
        ),
        Text(
          "PrivCh",
          style: Theme.of(context).textTheme.headline5,
        ),
      ],
    );
  }

  Widget _buildVersion() {
    return FutureBuilder(
      future: xinMethod.getPackageInfo(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          PackageInfo info = snapshot.data as PackageInfo;
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: Text("Version:", textAlign: TextAlign.right)),
                  SizedBox(width: 10),
                  Expanded(child: Text(info.versionName)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: Text("Build Time:", textAlign: TextAlign.right)),
                  SizedBox(width: 10),
                  Expanded(child: Text("${info.buildTime}")),
                ],
              ),
            ],
          );
        }
        // loading
        return Text("...");
      },
    );
  }

  Widget _buildButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () async => await xinMethod.showToast("Building..."),
            child: Text("Check for update"),
          ),
          ElevatedButton(
            onPressed: () async => await xinMethod.showToast("Building..."),
            child: Text("Send feedback"),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthor(EdgeInsetsGeometry? padding) {
    return Container(
      padding: padding,
      alignment: Alignment.center,
      child: Text(
        "https://privch.com (building...)",
        style: Theme.of(context).textTheme.caption,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text("About"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTitle(),
                SizedBox(height: 20),
                _buildVersion(),
                SizedBox(height: 30),
                _buildButton(),
                SizedBox(height: 30),
              ],
            ),
          ),
          _buildAuthor(EdgeInsets.all(10)),
        ],
      ),
    );
  }
}
