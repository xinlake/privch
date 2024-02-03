import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xinlake_tunnel/xinlake_tunnel.dart' as xt;

// item name also used as the key of @connectBy in the arb file
enum ConnectionMode {
  auto,
  manual,
}

class DashboardProvider with ChangeNotifier {
  final _keyShowChart = "Dashboard-ShowChart";
  final _keyConnectionModeIndex = "Dashboard-ConnectionMode-Index";

  late final SharedPreferences _preferences;

  // show chart
  bool _showChart = false;
  bool get showChart => _showChart;

  Future<void> setShowChart(bool showChart) async {
    if (_showChart != showChart) {
      _showChart = showChart;

      await _preferences.setBool(_keyShowChart, showChart);
      notifyListeners();
    }
  }

  // connect mode
  ConnectionMode _connectionMode = ConnectionMode.auto;
  ConnectionMode get connectionMode => _connectionMode;

  Future<void> setConnectionMode(ConnectionMode connectMode) async {
    if (_connectionMode != connectMode) {
      _connectionMode = connectMode;

      await _preferences.setInt(_keyConnectionModeIndex, connectMode.index);
      notifyListeners();
    }
  }

  // connect state
  xt.TunnelState _tunnelState = xt.TunnelState.stopped;
  xt.TunnelState get tunnelState => _tunnelState;
  set tunnelState(xt.TunnelState tunnelState) {
    if (_tunnelState != tunnelState) {
      _tunnelState = tunnelState;
      notifyListeners();
    }
  }

  // traffic trace
  static const _trafficTraceLength = 20;
  static const trafficIntervalSeconds = 1;

  // tx, rx
  List<FlSpot> _trafficTxTrace = [];
  List<FlSpot> _trafficRxTrace = [];
  List<FlSpot> get trafficTxTrace => _trafficTxTrace;
  List<FlSpot> get trafficRxTrace => _trafficRxTrace;

  void resetTrafficTxTrace() => _trafficTxTrace = [];
  void resetTrafficRxTrace() => _trafficRxTrace = [];

  void pushTrace(double tx, double rx) {
    if (_trafficTxTrace.isEmpty) {
      _trafficTxTrace = List<FlSpot>.generate(
        _trafficTraceLength,
        (index) => FlSpot(index.toDouble(), tx),
      );
    } else {
      _trafficTxTrace.removeAt(0);
      _trafficTxTrace.add(
        FlSpot(
          _trafficTxTrace.last.x + 1,
          tx,
        ),
      );
    }

    if (_trafficRxTrace.isEmpty) {
      _trafficRxTrace = List<FlSpot>.generate(
        _trafficTraceLength,
        (index) => FlSpot(index.toDouble(), rx),
      );
    } else {
      _trafficRxTrace.removeAt(0);
      _trafficRxTrace.add(
        FlSpot(
          _trafficRxTrace.last.x + 1,
          rx,
        ),
      );
    }

    notifyListeners();
  }

  // PROVIDER ---
  bool _initialized = false;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (!_initialized) {
      _preferences = await SharedPreferences.getInstance();

      final showChart = _preferences.getBool(_keyShowChart);
      if (showChart != null) {
        _showChart = showChart;
      }

      final connectModeIndex = _preferences.getInt(_keyConnectionModeIndex);
      if (connectModeIndex != null &&
          connectModeIndex >= 0 &&
          connectModeIndex < ConnectionMode.values.length) {
        _connectionMode = ConnectionMode.values[connectModeIndex];
      }

      _initialized = true;
    }
  }
}
