import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../pages/about_page.dart';
import '../providers/home_provider.dart';
import '../providers/server_provider.dart';
import 'dashboard_view.dart';
import 'server_list.dart';
import 'setting_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _State();
  }
}

class _State extends State<HomePage> {
  late AppLocalizations _appLocales;

  SystemUiOverlayStyle _getSystemOverlayStyle() {
    final brightness = Theme.of(context).brightness;
    final colorSurface = Theme.of(context).colorScheme.surface;

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
    final appBarColor = Theme.of(context).colorScheme.inversePrimary;

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
      title: switch (context.select<HomeProvider, HomeTab>((homeProvider) {
        return homeProvider.homeContent;
      })) {
        HomeTab.dashboard => const SizedBox(),
        HomeTab.servers => Text(
            "${_appLocales.servers} (${context.read<ServerProvider>().serverList.length})",
          ),
        HomeTab.settings => Text(_appLocales.settings),
      },
      actions: switch (context.select<HomeProvider, HomeTab>((homeProvider) {
        return homeProvider.homeContent;
      })) {
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
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        return switch (homeProvider.homeContent) {
          HomeTab.dashboard => DashboardView(appBarColor: appBarColor),
          HomeTab.servers => ShadowsocksList(appBarColor: appBarColor),
          HomeTab.settings => const SettingView(),
        };
      },
    );
  }

  Widget _bottomNavigationBar() {
    const iconSize = 32.0;
    final bgColor = Theme.of(context).colorScheme.surface;
    final activeColor = Theme.of(context).colorScheme.primary;
    final buttonText = Theme.of(context).textTheme.labelSmall;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(
          color: Theme.of(context).splashColor,
          height: 1,
          thickness: 1,
        ),
        Consumer<HomeProvider>(
          builder: (context, homeProvider, child) {
            return Container(
              color: bgColor,
              child: Row(
                children: [
                  Expanded(
                    child: IconButton(
                      onPressed: homeProvider.homeContent != HomeTab.dashboard
                          ? () => homeProvider.setHomeContent(HomeTab.dashboard)
                          : () {},
                      style: IconButton.styleFrom(
                        foregroundColor:
                            homeProvider.homeContent == HomeTab.dashboard ? activeColor : null,
                      ),
                      iconSize: iconSize,
                      icon: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          homeProvider.homeContent == HomeTab.dashboard
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
                      onPressed: homeProvider.homeContent != HomeTab.servers
                          ? () => homeProvider.setHomeContent(HomeTab.servers)
                          : () {},
                      style: IconButton.styleFrom(
                        foregroundColor:
                            (homeProvider.homeContent == HomeTab.servers) ? activeColor : null,
                      ),
                      iconSize: iconSize,
                      icon: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          (homeProvider.homeContent == HomeTab.servers)
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
                      onPressed: homeProvider.homeContent != HomeTab.settings
                          ? () => homeProvider.setHomeContent(HomeTab.settings)
                          : () {},
                      style: IconButton.styleFrom(
                        foregroundColor:
                            homeProvider.homeContent == HomeTab.settings ? activeColor : null,
                      ),
                      iconSize: iconSize,
                      icon: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          homeProvider.homeContent == HomeTab.settings
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
    // TODO lead2
    _appLocales = AppLocalizations.of(context);
    final mq = MediaQuery.of(context);

    return _buildLead();
  }

  @override
  void initState() {
    super.initState();
  }
}
