import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:privch/config.dart' as config;
import 'package:privch/pages/privch_server_list.dart';
import 'package:privch/pages/public_server_list.dart';
import 'package:privch/providers/server_provider.dart';
import 'package:provider/provider.dart';

class ShadowsocksList extends StatefulWidget {
  const ShadowsocksList({
    required this.actionBarColor,
    super.key,
  });

  final Color actionBarColor;

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ShadowsocksList> {
  late AppLocalizations _appLocales;
  late ThemeData _themeData;
  late double _spacing;
  late double _borderWidth;

  Widget _buildTabBar({EdgeInsetsGeometry? padding}) {
    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: _spacing),
      decoration: BoxDecoration(
        color: widget.actionBarColor,
        border: Border(
          bottom: BorderSide(
            color: _themeData.dividerColor,
          ),
        ),
      ),
      child: _serverTabs(),
    );
  }

  Widget _serverTabs() {
    return Row(
      children: ServerGroup.values.map<Widget>((serverTab) {
        return Material(
          clipBehavior: Clip.hardEdge,
          color: Colors.transparent,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(_spacing),
          ),
          child: Consumer<ServerTabProvider>(
            builder: (context, serverTabProvider, child) {
              return InkWell(
                onTap: () => serverTabProvider.serverTab = serverTab,
                child: Ink(
                  decoration: serverTab == serverTabProvider.serverTab
                      ? BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: _borderWidth,
                              color: _themeData.colorScheme.primary,
                            ),
                          ),
                        )
                      : null,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                _spacing,
                _spacing,
                _spacing,
                _spacing * 0.6,
              ),
              child: Text(switch (serverTab) {
                ServerGroup.privch => _appLocales.privchServers,
                ServerGroup.public => _appLocales.publicServers,
              }),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _serverList() {
    return Consumer<ServerTabProvider>(
      builder: (context, serverTabProvider, child) {
        return switch (serverTabProvider.serverTab) {
          ServerGroup.privch => PrivChShadowsocksList(actionBarColor: widget.actionBarColor),
          ServerGroup.public => PublicShadowsocksList(actionBarColor: widget.actionBarColor),
        };
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _appLocales = AppLocalizations.of(context);
    _themeData = Theme.of(context);

    _spacing = config.getSpacing(context);
    _borderWidth = _spacing * 0.33;

    return Column(
      children: [
        _buildTabBar(),
        Expanded(
          child: _serverList(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
