import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:privch/config.dart' as config;
import 'package:privch/pages/home_page.dart';
import 'package:privch/pages/init_page.dart';
import 'package:privch/pages/shadowsocks_page.dart';
import 'package:privch/providers/dashboard_provider.dart';
import 'package:privch/providers/home_provider.dart';
import 'package:privch/providers/init_provider.dart';
import 'package:privch/providers/server_provider.dart';
import 'package:privch/providers/setting_provider.dart';
import 'package:privch/providers/shadowsocks_provider.dart';
import 'package:provider/provider.dart';
import 'package:xinlake_tunnel/xinlake_tunnel.dart' as xt;

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => InitProvider(),
        ),
        ChangeNotifierProvider<SettingProvider>(
          create: (context) => SettingProvider(),
        ),
        ChangeNotifierProvider<PrivChServerProvider>(
          create: (context) => PrivChServerProvider(),
        ),
        ChangeNotifierProvider<PublicServerProvider>(
          create: (context) => PublicServerProvider(),
        ),
        ChangeNotifierProvider<ServerTabProvider>(
          create: (context) => ServerTabProvider(),
        ),
        ChangeNotifierProvider<DashboardProvider>(
          create: (context) => DashboardProvider(),
        ),
      ],
      child: const PrivateChannelApp(),
    ),
  );
}

class PrivateChannelApp extends StatelessWidget {
  const PrivateChannelApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      locale: context.select<SettingProvider, Locale?>(
        (settingProvider) => settingProvider.appLocale,
      ),

      // light theme
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: "NotoSansSC",
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        colorScheme: ColorScheme.fromSeed(
          seedColor: context.select<SettingProvider, Color>(
            (settingProvider) => settingProvider.appThemeColorLight,
          ),
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
          seedColor: context.select<SettingProvider, Color>(
            (settingProvider) => settingProvider.appThemeColorDart,
          ),
          error: Colors.orange,
          brightness: Brightness.dark,
        ),
        sliderTheme: const SliderThemeData(
          showValueIndicator: ShowValueIndicator.onlyForContinuous,
        ),
      ),

      themeMode: context.select<SettingProvider, ThemeMode>(
        (settingProvider) => settingProvider.appThemeMode,
      ),

      // routers
      initialRoute: context.read<InitProvider>().initialize == InitState.initialized
          ? config.AppRoute.home
          : config.AppRoute.initialize,
      routes: {
        config.AppRoute.initialize: (context) => const InitPage(),
        config.AppRoute.home: (context) {
          return ChangeNotifierProvider<HomeTabProvider>(
            create: (context) => HomeTabProvider(),
            child: const HomePage(),
          );
        },
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
  }
}
