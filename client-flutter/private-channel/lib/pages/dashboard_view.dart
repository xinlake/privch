import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:xinlake_text/readable.dart' as xtr;
import 'package:xinlake_tunnel/xinlake_tunnel.dart' as xt;
import 'package:xready_animations/xready_animations.dart';

import '../api/geo_location.dart';
import '../config.dart' as config;
import '../providers/dashboard_provider.dart';
import '../providers/home_provider.dart';
import '../providers/server_provider.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({
    super.key,
    required this.appBarColor,
  });

  final Color appBarColor;

  @override
  State<DashboardView> createState() {
    return _State();
  }
}

class _State extends State<DashboardView> with TickerProviderStateMixin {
  final _connectModeController = MenuController();

  late Timer _timer;
  late AppLocalizations _appLocales;

  Future<void> _connect() async {
    final dashboardProvider = context.read<DashboardProvider>();
    final serverProvider = context.read<ServerProvider>();
    final homeProvider = context.read<HomeProvider>();

    if (dashboardProvider.tunnelState != xt.TunnelState.stopped) {
      return;
    }

    // manually
    if (dashboardProvider.connectionMode == ConnectionMode.manual) {
      if (serverProvider.selected == null) {
        await homeProvider.setHomeContent(HomeContent.servers);
        return;
      }

      dashboardProvider.tunnelState = xt.TunnelState.connecting;
      final ss = serverProvider.selected!;

      await xt.connect(ss);

      // slight redundancy *1
      var ipLocation = await GeoLocationService.freeIpAip(ss.address).getGeoLocation() ??
          await GeoLocationService.ipApi(ss.address).getGeoLocation() ??
          await GeoLocationService.ipInfo(ss.address).getGeoLocation();
      if (ipLocation != null) {
        if (ipLocation.isNotEmpty) {
          ss.geoLocation = ipLocation;
          await serverProvider.put(ss);
        }

        dashboardProvider.tunnelState = xt.TunnelState.connected;
      } else {
        await xt.stopTunnel();
        dashboardProvider.tunnelState = xt.TunnelState.stopped;
      }
    }
    // automatic
    else {
      if (serverProvider.serverList.isEmpty) {
        await homeProvider.setHomeContent(HomeContent.servers);
        return;
      }

      dashboardProvider.tunnelState = xt.TunnelState.connecting;

      for (final ss in serverProvider.serverList) {
        await xt.connect(ss);

        // slight redundancy *1
        var ipLocation = await GeoLocationService.freeIpAip(ss.address).getGeoLocation() ??
            await GeoLocationService.ipApi(ss.address).getGeoLocation() ??
            await GeoLocationService.ipInfo(ss.address).getGeoLocation();
        if (ipLocation != null) {
          if (ipLocation.isNotEmpty) {
            ss.geoLocation = ipLocation;
            await serverProvider.put(ss);
          }

          serverProvider.setSelected(ss);
          dashboardProvider.tunnelState = xt.TunnelState.connected;
          return;
        } else {
          await xt.stopTunnel();
          dashboardProvider.tunnelState = xt.TunnelState.stopped;
        }
      }

      dashboardProvider.tunnelState = xt.TunnelState.stopped;
    }
  }

  Future<void> _disconnect() async {
    final dashboardProvider = context.read<DashboardProvider>();
    if (dashboardProvider.tunnelState != xt.TunnelState.connected) {
      return;
    }

    dashboardProvider.tunnelState = xt.TunnelState.stopping;
    await xt.stopTunnel();
    dashboardProvider.tunnelState = xt.TunnelState.stopped;
  }

  Widget _serverInfo({EdgeInsetsGeometry? margin}) {
    const labelColor = Color.fromARGB(255, 128, 128, 128);

    return Card(
      margin: margin,
      child: Padding(
        padding: EdgeInsets.all(config.spacing),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: labelColor,
            ),
            Expanded(
              child: Consumer<ServerProvider>(
                builder: (context, serverProvider, child) {
                  // not connected
                  if (serverProvider.selected == null) {
                    return Text(
                      _appLocales.notConnected,
                      textAlign: TextAlign.center,
                    );
                  }

                  return SelectionArea(
                    magnifierConfiguration: TextMagnifierConfiguration.disabled,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          serverProvider.selected!.address,
                          textAlign: TextAlign.center,
                        ),
                        if (serverProvider.selected!.geoLocation != null)
                          Text(
                            serverProvider.selected!.geoLocation!,
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _connectionInfo({EdgeInsetsGeometry? margin}) {
    const minMaxY = 100000.0;
    const gridColor = Color.fromARGB(33, 128, 128, 128);
    const labelColor = Color.fromARGB(255, 128, 128, 128);
    final lineColor = Theme.of(context).colorScheme.primary;
    final areaColor = Theme.of(context).colorScheme.inversePrimary;

    return Card(
      margin: margin,
      child: Padding(
        padding: EdgeInsets.all(config.spacing),
        child: Consumer<DashboardProvider>(
          builder: (context, dashboardState, child) {
            Row speed() => Row(
                  children: [
                    const Icon(
                      Icons.download_outlined,
                      color: labelColor,
                    ),
                    Expanded(
                      child: dashboardState.trafficRxTrace.isNotEmpty
                          ? Text(
                              xtr.formatSize(dashboardState.trafficRxTrace.last.y.toInt()),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Center(
                              child: SpinKitDualRing(
                                size: 20,
                                color: lineColor,
                                lineWidth: 4,
                              ),
                            ),
                    ),
                    const Icon(
                      Icons.upload_outlined,
                      color: labelColor,
                    ),
                    Expanded(
                      child: dashboardState.trafficTxTrace.isNotEmpty
                          ? Text(
                              xtr.formatSize(dashboardState.trafficTxTrace.last.y.toInt()),
                              textAlign: TextAlign.center,
                            )
                          : Center(
                              child: SpinKitDualRing(
                                size: 20,
                                color: lineColor,
                                lineWidth: 4,
                              ),
                            ),
                    ),
                  ],
                );

            // text only
            if (!dashboardState.showChart) {
              return speed();
            }

            final mqSize = MediaQuery.of(context).size;

            return Column(
              children: [
                // speed
                speed(),
                SizedBox(height: config.spacing),

                // chart
                SizedBox(
                  width: double.maxFinite,
                  height: mqSize.shortestSide * 0.2,
                  child: Builder(builder: (context) {
                    if (dashboardState.trafficRxTrace.isEmpty ||
                        dashboardState.trafficTxTrace.isEmpty) {
                      return SpinKitDualRing(
                        color: lineColor,
                        size: mqSize.shortestSide * 0.12,
                      );
                    }

                    final rxMaxBytes = dashboardState.trafficRxTrace.reduce((value, element) {
                      return (value.y > element.y) ? value : element;
                    }).y;

                    final txMaxBytes = dashboardState.trafficTxTrace.reduce((value, element) {
                      return (value.y > element.y) ? value : element;
                    }).y;

                    // max y, at least 10k
                    final maxY = math.max(math.max(rxMaxBytes, txMaxBytes), minMaxY);

                    return LineChart(
                      LineChartData(
                        lineTouchData: const LineTouchData(enabled: false),
                        gridData: FlGridData(
                          show: true,
                          drawHorizontalLine: true,
                          drawVerticalLine: true,
                          horizontalInterval: maxY * 0.249,
                          getDrawingHorizontalLine: (value) => const FlLine(
                            color: gridColor,
                            strokeWidth: 1,
                          ),
                          getDrawingVerticalLine: (value) => const FlLine(
                            color: gridColor,
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        clipData: const FlClipData.all(),
                        minX: dashboardState.trafficTxTrace.first.x,
                        maxX: dashboardState.trafficTxTrace.last.x,
                        minY: 0,
                        maxY: maxY,
                        lineBarsData: [
                          // tx
                          LineChartBarData(
                            isCurved: true,
                            preventCurveOverShooting: true,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            spots: dashboardState.trafficTxTrace,
                            barWidth: 1,
                            color: lineColor,
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                lineColor,
                                lineColor,
                                Colors.transparent,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              stops: const [0.0, 0.05, 0.95, 1.0],
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  lineColor,
                                  areaColor,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      duration: Duration.zero,
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _connectButton({EdgeInsetsGeometry? padding}) {
    const borderWidth = 2.0;
    const indicatorWidth = 5.0;

    final mqSize = MediaQuery.of(context).size;
    final buttonSize = mqSize.shortestSide * 0.39;

    final borderColor = Theme.of(context).splashColor;

    return Padding(
      padding: padding != null
          ? const EdgeInsets.all(indicatorWidth).add(padding)
          : const EdgeInsets.all(indicatorWidth),
      child: Stack(
        children: [
          SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: Consumer<DashboardProvider>(
              builder: (context, dashboardProvider, child) {
                return CircularProgressIndicator(
                  strokeCap: StrokeCap.round,
                  strokeAlign: BorderSide.strokeAlignOutside,
                  strokeWidth: indicatorWidth,
                  value: switch (dashboardProvider.tunnelState) {
                    (xt.TunnelState.connecting || xt.TunnelState.stopping) => null,
                    _ => 0.0,
                  },
                );
              },
            ),
          ),
          SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: Consumer<DashboardProvider>(
              builder: (context, dashboardProvider, child) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(
                      side: BorderSide(
                        strokeAlign: BorderSide.strokeAlignOutside,
                        color: borderColor,
                        width: borderWidth,
                      ),
                    ),
                  ),
                  onPressed: switch (dashboardProvider.tunnelState) {
                    (xt.TunnelState.connecting || xt.TunnelState.stopping) => null,
                    xt.TunnelState.connected => () async => await _disconnect(),
                    xt.TunnelState.stopped => () async => await _connect(),
                  },
                  child: Text(
                    switch (dashboardProvider.tunnelState) {
                      (xt.TunnelState.connected || xt.TunnelState.stopping) =>
                        _appLocales.disconnect,
                      (xt.TunnelState.stopped || xt.TunnelState.connecting) => _appLocales.connect,
                    },
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _connectMode() {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardState, child) {
        return MenuAnchor(
          controller: _connectModeController,
          builder: (context, controller, child) {
            return ElevatedButton(
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // selected sort mode
                  Text(
                    _appLocales.connectBy(dashboardState.connectionMode.name),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(width: config.spacing),
                  const Icon(Icons.keyboard_arrow_up),
                ],
              ),
            );
          },
          menuChildren: ConnectionMode.values.map(
            (connectMode) {
              return MenuItemButton(
                onPressed: connectMode != dashboardState.connectionMode
                    ? () {
                        dashboardState.setConnectionMode(connectMode);
                        _connectModeController.close();
                      }
                    : null,
                child: Text(
                  _appLocales.connectBy(connectMode.name),
                ),
              );
            },
          ).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _appLocales = AppLocalizations.of(context);
    final mqSize = MediaQuery.of(context).size;
    var isLight = Theme.of(context).brightness == Brightness.light;

    final colors = [
      Theme.of(context).colorScheme.surface,
      Theme.of(context).colorScheme.onPrimary,
      Theme.of(context).colorScheme.primaryContainer,
      widget.appBarColor,
    ];

    const gradientFrom = 0.58;
    const gradientTo = 1.0;
    final gradientStops = [gradientFrom];
    for (int i = 0; i < colors.length - 1; ++i) {
      gradientStops.addAll([
        gradientStops.last,
        gradientStops.last + (gradientTo - gradientFrom) / colors.length,
      ]);
    }
    gradientStops.add(gradientTo);

    final gradientColors = [colors.first];
    for (int i = 0; i < colors.length - 1; ++i) {
      gradientColors.addAll([
        colors[i + 1].withOpacity(0.98),
        colors[i + 1],
      ]);
    }
    gradientColors.add(colors.last);

    return Container(
      color: isLight ? const Color(0xff000000) : const Color(0xffffffff),
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            // bottom
            center: const Alignment(0, 4),
            // 0 is the center of the box. 4+1 = 5
            radius: 5,
            stops: gradientStops,
            colors: gradientColors,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _serverInfo(
                    margin: EdgeInsets.symmetric(
                      horizontal: mqSize.shortestSide * 0.07,
                      vertical: config.spacing,
                    ),
                  ),
                  _connectionInfo(
                    margin: EdgeInsets.symmetric(
                      horizontal: mqSize.shortestSide * 0.07,
                      vertical: config.spacing,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _connectButton(
                    padding: EdgeInsets.all(config.spacing),
                  ),
                  Padding(
                    padding: EdgeInsets.all(config.spacing),
                    child: _connectMode(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    List<int>? lastTxRx;
    _timer = Timer.periodic(
      const Duration(seconds: DashboardProvider.trafficIntervalSeconds),
      (timer) async {
        final trafficTxRx = await xt.getTrafficBytes();
        if (trafficTxRx != null) {
          if (lastTxRx == null) {
            lastTxRx = trafficTxRx;
          } else {
            if (mounted) {
              context.read<DashboardProvider>().pushTrace(
                    (trafficTxRx.elementAt(0) - lastTxRx!.elementAt(0)).toDouble(),
                    (trafficTxRx.elementAt(1) - lastTxRx!.elementAt(1)).toDouble(),
                  );
            }
            lastTxRx = trafficTxRx;
          }
        } else {
          lastTxRx = null;
        }
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
