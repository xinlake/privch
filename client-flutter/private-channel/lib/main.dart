import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:provider/provider.dart';
import 'package:xinlake_tunnel/xinlake_tunnel.dart' as xt;

import 'config.dart' as config;
import 'models/hive_shadowsocks.dart';
import 'pages/home_page.dart';
import 'pages/shadowsocks_page.dart';
import 'providers/dashboard_provider.dart';
import 'providers/home_provider.dart';
import 'providers/server_provider.dart';
import 'providers/setting_provider.dart';
import 'providers/shadowsocks_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init local db
  try {
    var dataDir = await path.getApplicationDocumentsDirectory();
    if (Platform.isWindows) {
      dataDir = Directory("${dataDir.path}\\Xinlake\\PrivateChannel")..createSync(recursive: true);
    }

    Hive.init(dataDir.path);
    Hive.registerAdapter(ShadowsocksAdapter());
  } catch (error) {
    // TODO: error page
  }

  runApp(
    MultiProvider(
      providers: [
        Provider(
          create: (context) => ProviderState(),
        ),
        ChangeNotifierProvider<HomeProvider>(
          create: (context) => HomeProvider(),
        ),
        ChangeNotifierProvider<SettingProvider>(
          create: (context) => SettingProvider(),
        ),
        ChangeNotifierProvider<ServerProvider>(
          create: (context) => ServerProvider(),
        ),
        ChangeNotifierProvider<DashboardProvider>(
          create: (context) => DashboardProvider(),
        ),
      ],
      child: const PrivateChannelApp(),
    ),
  );
}

class ProviderState {
  bool initialized = false;
}

class PrivateChannelApp extends StatelessWidget {
  const PrivateChannelApp({super.key});

  Future<void> _initialize(BuildContext context) async {
    if (!context.read<ProviderState>().initialized) {
      context.read<ProviderState>().initialized = true;

      final homeProvider = context.read<HomeProvider>();
      final settingProvider = context.read<SettingProvider>();
      final serverProvider = context.read<ServerProvider>();
      final dashboardProvider = context.read<DashboardProvider>();

      await homeProvider.initialize();
      await settingProvider.initialize();
      await serverProvider.initialize();
      await dashboardProvider.initialize();
    }
  }

  Widget _buildApp() {
    return Consumer<SettingProvider>(
      builder: (BuildContext context, settingProvider, Widget? child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: const [
            Locale("en", "US"),
            Locale("zh", "CN"),
          ],
          locale: settingProvider.appLocale,

          // light theme
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: "NotoSansSC",
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            colorScheme: ColorScheme.fromSeed(
              seedColor: settingProvider.appThemeColorLight,
              error: Colors.deepOrange,
              brightness: Brightness.light,
            ),
            sliderTheme: const SliderThemeData(
              showValueIndicator: ShowValueIndicator.onlyForContinuous,
            ),
          ),

          // dark theme
          darkTheme: ThemeData(
            useMaterial3: true,
            fontFamily: "NotoSansSC",
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            colorScheme: ColorScheme.fromSeed(
              seedColor: settingProvider.appThemeColorDart,
              error: Colors.orange,
              brightness: Brightness.dark,
            ),
            sliderTheme: const SliderThemeData(
              showValueIndicator: ShowValueIndicator.onlyForContinuous,
            ),
          ),

          themeMode: settingProvider.appThemeMode,

          // routers
          initialRoute: config.AppRoute.home,
          routes: {
            config.AppRoute.home: (context) => const HomePage(),
          },
          onGenerateRoute: (route) {
            return switch (route.name) {
              config.AppRoute.shadowsocks => MaterialPageRoute<xt.Shadowsocks>(
                  builder: (context) => ChangeNotifierProvider<ShadowsocksProvider>(
                    create: (BuildContext context) {
                      final args = route.arguments as (xt.Shadowsocks, bool);
                      return ShadowsocksProvider(args.$1, args.$2);
                    },
                    child: const ShadowsocksView(),
                  ),
                ),
              _ => null,
            };
          },
        );
      },
    );
  }

  Widget _buildLoading(BuildContext context) {
    final mqSize = MediaQuery.of(context).size;
    final spacing = mqSize.shortestSide * 0.033;
    final iconSize = mqSize.shortestSide * 0.26;

    final loadingText = Theme.of(context).textTheme.titleLarge;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: "Roboto",
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          background: Colors.blueGrey.shade50,
          brightness: Brightness.light,
        ),
      ),
      home: Material(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "_assets/Icons/app-192.png",
              width: iconSize,
              height: iconSize,
              filterQuality: FilterQuality.high,
            ),
            Padding(
              padding: EdgeInsets.all(spacing),
              child: Text(
                "Private Channel",
                style: loadingText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialize(context),
      builder: (BuildContext context, snapshot) {
        if (!context.read<ProviderState>().initialized &&
            snapshot.connectionState != ConnectionState.done) {
          return _buildLoading(context);
        }
        return _buildApp();
      },
    );
  }
}
