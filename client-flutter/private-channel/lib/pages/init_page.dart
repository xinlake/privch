import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:privch/config.dart' as config;
import 'package:privch/models/hive_shadowsocks.dart';
import 'package:privch/providers/dashboard_provider.dart';
import 'package:privch/providers/init_provider.dart';
import 'package:privch/providers/server_provider.dart';
import 'package:privch/providers/setting_provider.dart';
import 'package:privch/widgets/app_title.dart';
import 'package:provider/provider.dart';

class InitPage extends StatefulWidget {
  const InitPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _State();
  }
}

class _State extends State<InitPage> {
  late double _spacing;

  Future<void> _initialize() async {
    final initProvider = context.read<InitProvider>();
    if (initProvider.initialize != InitState.initialized) {
      final settingProvider = context.read<SettingProvider>();
      final privchServerProvider = context.read<PrivChServerProvider>();
      final publicServerProvider = context.read<PublicServerProvider>();
      final serverTabProvider = context.read<ServerTabProvider>();
      final dashboardProvider = context.read<DashboardProvider>();

      // init local db
      try {
        var dataDir = await path.getApplicationDocumentsDirectory();
        if (Platform.isWindows) {
          dataDir = Directory("${dataDir.path}\\Xinlake\\PrivateChannel")
            ..createSync(recursive: true);
        }

        Hive.init(dataDir.path);
        Hive.registerAdapter(ShadowsocksAdapter());
      } catch (error) {
        initProvider.initialize = InitState.error;
        return;
      }

      // init providers
      await settingProvider.initialize();
      await privchServerProvider.initialize();
      await publicServerProvider.initialize();
      await serverTabProvider.initialize();
      await dashboardProvider.initialize();

      initProvider.initialize = InitState.initialized;
    }

    if (mounted) {
      Navigator.of(context).pushNamed(
        config.AppRoute.home,
      );
    }
  }

  Widget _buildLoading() {
    final mqSize = MediaQuery.of(context).size;
    final iconSize = mqSize.shortestSide * 0.26;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "_assets/Icons/app-192.png",
            width: iconSize,
            height: iconSize,
            filterQuality: FilterQuality.high,
          ),
          Padding(
            padding: EdgeInsets.all(_spacing * 2),
            child: buildAppTitle(
              context,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
        ],
      ),
    );
  }

  // TODO: detail info
  Widget _buildError() {
    return const Center(
      child: Text("Error"),
    );
  }

  @override
  Widget build(BuildContext context) {
    _spacing = config.getSpacing(context);

    return Consumer<InitProvider>(
      builder: (context, initProvider, child) {
        return switch (initProvider.initialize) {
          InitState.uninitialized => _buildLoading(),
          InitState.error => _buildError(),
          InitState.initialized => const SizedBox(),
        };
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }
}
