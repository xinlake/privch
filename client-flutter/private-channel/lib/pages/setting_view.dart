/*
  2023-08-P.T.S
 */

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:xinlake_responsive/xinlake_heading.dart';
import 'package:xinlake_text/validators.dart' as xv;

import '../config.dart' as config;
import '../providers/dashboard_provider.dart';
import '../providers/setting_provider.dart';

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() {
    return _State();
  }
}

class _State extends State<SettingView> {
  final _tunnelProxyPortEditing = TextEditingController();
  final _tunnelDnsLocalPortEditing = TextEditingController();
  final _tunnelDnsRemoteAddressEditing = TextEditingController();

  late AppLocalizations _appLocales;

  Widget _buildLead() {
    final headingPadding = EdgeInsets.only(top: config.spacing * 2);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        config.spacing,
        config.spacing,
        config.spacing,
        config.spacing * 2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // user
          XinHeading(
            title: _appLocales.preference,
            padding: headingPadding,
          ),
          _buildPersonal(),

          // appearance
          XinHeading(
            title: _appLocales.settingAppearance,
            padding: headingPadding,
          ),
          _buildAppearance(),

          // tunnel
          XinHeading(
            title: _appLocales.settingNetwork,
            padding: EdgeInsets.only(top: config.spacing * 2, bottom: config.spacing),
          ),
          _buildTunnel(),
        ],
      ),
    );
  }

  Widget _buildPersonal() {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      textBaseline: TextBaseline.alphabetic,
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      children: [
        TableRow(
          children: [
            _optionLabel(_appLocales.prefShowChart),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.all(config.spacing),
                child: _prefShowChart(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppearance() {
    final selectionColor = Theme.of(context).colorScheme.primary;
    final vertical = MediaQuery.of(context).size.width < 600;

    if (vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ui language
          _optionLabel(_appLocales.language),
          Padding(
            padding: EdgeInsets.all(config.spacing),
            child: _appLanguage(selectionColor),
          ),

          // theme mode
          _optionLabel(_appLocales.themeMode),
          Padding(
            padding: EdgeInsets.all(config.spacing),
            child: _appThemeMode(selectionColor),
          ),

          // theme color
          Tooltip(
            message: _appLocales.themeColorDesc,
            waitDuration: const Duration(seconds: 1),
            child: _optionLabel(_appLocales.themeColor),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(config.spacing),
              child: _appThemeColor(),
            ),
          ),
        ],
      );
    }

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      textBaseline: TextBaseline.alphabetic,
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      children: [
        // ui language
        TableRow(children: [
          _optionLabel(_appLocales.language),
          Padding(
            padding: EdgeInsets.all(config.spacing),
            child: _appLanguage(selectionColor),
          ),
        ]),

        // theme mode
        TableRow(children: [
          _optionLabel(_appLocales.themeMode),
          Padding(
            padding: EdgeInsets.all(config.spacing),
            child: _appThemeMode(selectionColor),
          ),
        ]),

        // theme color
        TableRow(children: [
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.top,
            child: Tooltip(
              message: _appLocales.themeColorDesc,
              waitDuration: const Duration(seconds: 1),
              child: _optionLabel(_appLocales.themeColor),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(config.spacing),
              child: _appThemeColor(),
            ),
          ),
        ])
      ],
    );
  }

  Widget _buildTunnel() {
    final borderColor = Theme.of(context).splashColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.all(config.spacing),
          child: _tunnelProxyPort(borderColor),
        ),
        Padding(
          padding: EdgeInsets.all(config.spacing),
          child: _tunnelDnsLocalPort(borderColor),
        ),
        Padding(
          padding: EdgeInsets.all(config.spacing),
          child: _tunnelDnsRemoteAddress(borderColor),
        ),
      ],
    );
  }

  Widget _prefShowChart() {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        return Switch(
          value: dashboardProvider.showChart,
          onChanged: (value) {
            dashboardProvider.setShowChart(value);
          },
        );
      },
    );
  }

  Widget _appLanguage(Color selectionColor) {
    final borderColor = Theme.of(context).colorScheme.primaryContainer;

    final selectedText = TextStyle(
      color: selectionColor,
    );

    return Consumer<SettingProvider>(
      builder: (BuildContext context, settingState, Widget? child) {
        return PopupMenuButton<Locale>(
          position: PopupMenuPosition.under,
          initialValue: settingState.appLocale,
          onSelected: (locale) async {
            await settingState.setAppLocale(locale);
          },
          child: Container(
            padding: EdgeInsets.all(config.spacing),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              border: Border.all(
                color: borderColor,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    _appLocales.languageBy(_appLocales.localeName),
                    overflow: TextOverflow.ellipsis,
                    style: selectedText,
                  ),
                ),
                SizedBox(width: config.spacing),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
          itemBuilder: (context) {
            return AppLocalizations.supportedLocales.map((locale) {
              return PopupMenuItem<Locale>(
                value: locale,
                child: Text(
                  _appLocales.languageBy(locale.languageCode),
                ),
              );
            }).toList();
          },
        );
      },
    );
  }

  Widget _appThemeMode(Color selectionColor) {
    final showThemeModeIcon = (MediaQuery.of(context).size.width > 500);

    final themes = <(ThemeMode, IconData, String)>[
      (ThemeMode.system, Icons.brightness_6, _appLocales.themeAuto),
      (ThemeMode.light, Icons.brightness_7, _appLocales.themeLight),
      (ThemeMode.dark, Icons.brightness_2, _appLocales.themeDark),
    ];

    return Consumer<SettingProvider>(
      builder: (BuildContext context, settingState, Widget? child) {
        return Wrap(
          spacing: config.spacing,
          runSpacing: config.spacing,
          alignment: WrapAlignment.spaceBetween,
          children: themes.map((theme) {
            return TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.all(config.spacing * 1.5),
                side: (theme.$1 == settingState.appThemeMode)
                    ? BorderSide(
                        width: 1,
                        color: selectionColor,
                      )
                    : null,
              ),
              onPressed: (theme.$1 == settingState.appThemeMode)
                  ? null
                  : () async {
                      await settingState.setAppThemeMode(theme.$1);
                    },
              child: showThemeModeIcon
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(theme.$2),
                        // spacing
                        SizedBox(width: config.spacing),
                        Text(theme.$3),
                      ],
                    )
                  : Text(theme.$3),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _appThemeColor() {
    const colorWidth = 70.0;
    const colorHeight = 35.0;
    final colorBoxRadius = config.spacing * 0.6;
    final iconShadowRadius = config.spacing * 0.6;
    const dividerAlpha = 220;

    return Consumer<SettingProvider>(
      builder: (BuildContext context, settingState, Widget? child) {
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: config.primaryColors.entries.map((color) {
            final isLightColor = (color.value == settingState.appThemeColorLight);
            final isDarkColor = (color.value == settingState.appThemeColorDart);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(colorBoxRadius),
                    bottom: Radius.circular(colorBoxRadius * 0.5),
                  ),
                  onTap: isLightColor
                      ? null
                      : () async {
                          await settingState.setAppThemeColorLight(color.value);
                        },
                  child: Ink(
                    width: colorWidth,
                    height: colorHeight,
                    decoration: BoxDecoration(
                      border: const Border(),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(colorBoxRadius),
                        bottom: Radius.circular(colorBoxRadius * 0.5),
                      ),
                      color: color.value,
                    ),
                    child: isLightColor
                        ? Icon(
                            Icons.check,
                            color: Colors.white,
                            shadows: <Shadow>[
                              Shadow(
                                color: Colors.black,
                                blurRadius: iconShadowRadius,
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
                Container(
                  height: 1.0,
                  width: colorWidth,
                  padding: EdgeInsets.symmetric(horizontal: config.spacing),
                  color: color.value.withAlpha(dividerAlpha),
                ),
                InkWell(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(colorBoxRadius * 0.5),
                    bottom: Radius.circular(colorBoxRadius),
                  ),
                  onTap: isDarkColor
                      ? null
                      : () async {
                          await settingState.setAppThemeColorDark(color.value);
                        },
                  child: Ink(
                    width: colorWidth,
                    height: colorHeight,
                    decoration: BoxDecoration(
                      border: const Border(),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(colorBoxRadius * 0.5),
                        bottom: Radius.circular(colorBoxRadius),
                      ),
                      color: color.value,
                    ),
                    child: isDarkColor
                        ? Icon(
                            Icons.check,
                            color: Colors.white,
                            shadows: <Shadow>[
                              Shadow(
                                color: Colors.black,
                                blurRadius: iconShadowRadius,
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Widget _tunnelProxyPort(Color borderColor) {
    return Consumer<SettingProvider>(
      builder: (context, settingState, child) {
        return _tunnelValue(
          borderColor: borderColor,
          labelText: _appLocales.tunnelProxyPort,
          suffixIcon: (settingState.tunnelProxyPortChange != settingState.tunnelProxyPort)
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // cancel
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        _tunnelProxyPortEditing.clearComposing();
                        _tunnelProxyPortEditing.text = settingState.tunnelProxyPort.toString();
                        settingState.resetTunnelProxyPortChange();
                      },
                      icon: const Icon(Icons.undo),
                    ),

                    // update
                    if (settingState.tunnelProxyPortChange != null)
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          _tunnelProxyPortEditing.clearComposing();

                          await settingState.setTunnelProxyPort(
                            settingState.tunnelProxyPortChange!,
                          );
                        },
                        icon: const Icon(Icons.check),
                      ),
                  ],
                )
              : null,
          controller: _tunnelProxyPortEditing,
          onChanged: (value) {
            settingState.tunnelProxyPortChange = xv.getNumberInRange(
              value,
              min: 1000,
              max: 65536,
            );
          },
        );
      },
    );
  }

  Widget _tunnelDnsLocalPort(Color borderColor) {
    return Consumer<SettingProvider>(
      builder: (context, settingState, child) {
        return _tunnelValue(
          borderColor: borderColor,
          labelText: _appLocales.tunnelDnsLocalPort,
          suffixIcon: (settingState.tunnelDnsLocalPortChange != settingState.tunnelDnsLocalPort)
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // cancel
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        _tunnelDnsLocalPortEditing.clearComposing();
                        _tunnelDnsLocalPortEditing.text =
                            settingState.tunnelDnsLocalPort.toString();
                        settingState.resetTunnelDnsLocalPortChange();
                      },
                      icon: const Icon(Icons.undo),
                    ),

                    // update
                    if (settingState.tunnelDnsLocalPortChange != null)
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          _tunnelDnsLocalPortEditing.clearComposing();

                          await settingState.setTunnelDnsLocalPort(
                            settingState.tunnelDnsLocalPortChange!,
                          );
                        },
                        icon: const Icon(Icons.check),
                      ),
                  ],
                )
              : null,
          controller: _tunnelDnsLocalPortEditing,
          onChanged: (value) {
            settingState.tunnelDnsLocalPortChange = xv.getNumberInRange(
              value,
              min: 1000,
              max: 65536,
            );
          },
        );
      },
    );
  }

  Widget _tunnelDnsRemoteAddress(Color borderColor) {
    return Consumer<SettingProvider>(
      builder: (context, settingState, child) {
        return _tunnelValue(
          borderColor: borderColor,
          labelText: _appLocales.tunnelDnsRemoteAddress,
          suffixIcon: (settingState.tunnelDnsRemoteAddressChange !=
                  settingState.tunnelDnsRemoteAddress)
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // cancel
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        _tunnelDnsRemoteAddressEditing.clearComposing();
                        _tunnelDnsRemoteAddressEditing.text = settingState.tunnelDnsRemoteAddress;
                        settingState.resetTunnelDnsRemoteAddressChange();
                      },
                      icon: const Icon(Icons.undo),
                    ),

                    // update
                    if (settingState.tunnelDnsRemoteAddressChange != null)
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          _tunnelDnsRemoteAddressEditing.clearComposing();

                          await settingState.setTunnelDnsRemoteAddress(
                            settingState.tunnelDnsRemoteAddressChange!,
                          );
                        },
                        icon: const Icon(Icons.check),
                      ),
                  ],
                )
              : null,
          controller: _tunnelDnsRemoteAddressEditing,
          onChanged: (value) {
            value = value.trim();
            if (xv.isURL(value)) {
              settingState.tunnelDnsRemoteAddressChange = value;
            } else {
              settingState.tunnelDnsRemoteAddressChange = null;
            }
          },
        );
      },
    );
  }

  Widget _tunnelValue({
    required Color borderColor,
    String? labelText,
    Widget? suffixIcon,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    final labelColor = Theme.of(context).hintColor;

    return TextFormField(
      magnifierConfiguration: TextMagnifierConfiguration.disabled,
      spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
      enableSuggestions: false,
      autocorrect: false,
      minLines: 1,
      maxLines: 1,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.start,
      decoration: InputDecoration(
        isDense: true,
        // https://github.com/flutter/flutter/issues/18751
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.spacing),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: borderColor,
          ),
          borderRadius: BorderRadius.circular(config.spacing),
        ),
        labelText: labelText,
        labelStyle: TextStyle(color: labelColor),
        suffixIcon: suffixIcon,
      ),
      controller: controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      onChanged: onChanged,
    );
  }

  Widget _optionLabel(
    String label, {
    EdgeInsetsGeometry? padding,
  }) {
    return Padding(
      padding: padding ?? EdgeInsets.all(config.spacing),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _optionValue(
    String value, {
    EdgeInsetsGeometry? padding,
  }) {
    return Padding(
      padding: padding ?? EdgeInsets.all(config.spacing),
      child: Text(
        value,
        textAlign: TextAlign.right,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _appLocales = AppLocalizations.of(context);
    return _buildLead();
  }

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingProvider>();

    settings.resetTunnelEditing();
    _tunnelProxyPortEditing.text = settings.tunnelProxyPort.toString();
    _tunnelDnsLocalPortEditing.text = settings.tunnelDnsLocalPort.toString();
    _tunnelDnsRemoteAddressEditing.text = settings.tunnelDnsRemoteAddress;
  }

  @override
  void dispose() {
    _tunnelProxyPortEditing.dispose();
    _tunnelDnsLocalPortEditing.dispose();
    _tunnelDnsRemoteAddressEditing.dispose();

    super.dispose();
  }
}
