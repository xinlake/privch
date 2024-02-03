import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:privch/pages/about_page.dart';
import 'package:privch/pages/dashboard_view.dart';
import 'package:privch/pages/server_list.dart';
import 'package:privch/pages/setting_view.dart';
import 'package:privch/providers/home_provider.dart';
import 'package:privch/widgets/app_title.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _State();
  }
}

class _State extends State<HomePage> {
  late AppLocalizations _appLocales;
  late ThemeData _themeData;

  SystemUiOverlayStyle _getSystemOverlayStyle() {
    final brightness = _themeData.brightness;
    final colorSurface = _themeData.colorScheme.surface;

    return switch (brightness) {
      Brightness.light => SystemUiOverlayStyle(
          statusBarColor: const Color(0x20ffffff),
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: colorSurface,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarContrastEnforced: false,
        ),
      Brightness.dark => SystemUiOverlayStyle(
          statusBarColor: const Color(0x20000000),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: colorSurface,
          systemNavigationBarIconBrightness: Brightness.light,
          systemNavigationBarContrastEnforced: false,
        ),
    };
  }

  Widget _buildLead() {
    final appBarColor = _themeData.colorScheme.inversePrimary;

    return Scaffold(
      appBar: _appBar(appBarColor),
      body: _content(appBarColor),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  AppBar _appBar(Color appBarColor) {
    return AppBar(
      systemOverlayStyle: _getSystemOverlayStyle(),
      automaticallyImplyLeading: false,
      backgroundColor: appBarColor,
      centerTitle: true,
      title: switch (context.select<HomeTabProvider, HomeTab>(
        (homeTabProvider) => homeTabProvider.homeTab,
      )) {
        HomeTab.dashboard => buildAppTitle(context),
        HomeTab.servers => Text(_appLocales.servers),
        HomeTab.settings => Text(_appLocales.settings),
      },
      actions: switch (context.select<HomeTabProvider, HomeTab>(
        (homeProvider) => homeProvider.homeTab,
      )) {
        HomeTab.dashboard => null,
        HomeTab.servers => null,
        HomeTab.settings => [
            MenuAnchor(
              builder: (context, controller, child) {
                return IconButton(
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  icon: const Icon(Icons.more_vert),
                );
              },
              menuChildren: [
                MenuItemButton(
                  onPressed: () async {
                    await showAbout(context: context);
                  },
                  child: Text(
                    _appLocales.about,
                  ),
                ),
              ],
            ),
          ],
      },
    );
  }

  Widget _content(Color appBarColor) {
    return Consumer<HomeTabProvider>(
      builder: (context, homeProvider, child) {
        return switch (homeProvider.homeTab) {
          HomeTab.dashboard => DashboardView(appBarColor: appBarColor),
          HomeTab.servers => ShadowsocksList(actionBarColor: appBarColor),
          HomeTab.settings => const SettingView(),
        };
      },
    );
  }

  Widget _bottomNavigationBar() {
    const iconSize = 32.0;
    final bgColor = _themeData.colorScheme.surface;
    final activeColor = _themeData.colorScheme.primary;
    final buttonText = _themeData.textTheme.labelSmall;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(
          color: _themeData.splashColor,
          height: 1,
          thickness: 1,
        ),
        Consumer<HomeTabProvider>(
          builder: (context, homeProvider, child) {
            return Container(
              color: bgColor,
              child: Row(
                children: [
                  Expanded(
                    child: IconButton(
                      onPressed: homeProvider.homeTab != HomeTab.dashboard
                          ? () => homeProvider.homeTab = HomeTab.dashboard
                          : () {},
                      style: IconButton.styleFrom(
                        foregroundColor:
                            homeProvider.homeTab == HomeTab.dashboard ? activeColor : null,
                      ),
                      iconSize: iconSize,
                      icon: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          homeProvider.homeTab == HomeTab.dashboard
                              ? const Icon(Icons.dashboard)
                              : const Icon(Icons.dashboard_outlined),
                          Text(
                            _appLocales.home,
                            style: buttonText,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: homeProvider.homeTab != HomeTab.servers
                          ? () => homeProvider.homeTab = HomeTab.servers
                          : () {},
                      style: IconButton.styleFrom(
                        foregroundColor:
                            (homeProvider.homeTab == HomeTab.servers) ? activeColor : null,
                      ),
                      iconSize: iconSize,
                      icon: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          (homeProvider.homeTab == HomeTab.servers)
                              ? const Icon(Icons.view_list)
                              : const Icon(Icons.view_list_outlined),
                          Text(
                            _appLocales.servers,
                            style: buttonText,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: homeProvider.homeTab != HomeTab.settings
                          ? () => homeProvider.homeTab = HomeTab.settings
                          : () {},
                      style: IconButton.styleFrom(
                        foregroundColor:
                            homeProvider.homeTab == HomeTab.settings ? activeColor : null,
                      ),
                      iconSize: iconSize,
                      icon: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          homeProvider.homeTab == HomeTab.settings
                              ? const Icon(Icons.settings)
                              : const Icon(Icons.settings_outlined),
                          Text(
                            _appLocales.settings,
                            style: buttonText,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _appLocales = AppLocalizations.of(context);
    _themeData = Theme.of(context);

    // TODO lead2
    final mq = MediaQuery.of(context);

    return _buildLead();
  }

  @override
  void initState() {
    super.initState();
  }
}
