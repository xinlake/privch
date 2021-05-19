import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:privch/data/types.dart';
import 'package:privch/platform/platform_event.dart';

class TrafficChart extends StatefulWidget {
  @override
  _TrafficChartState createState() => _TrafficChartState();
}

class _TrafficChartState extends State<TrafficChart> {
  static const int maxPoint = 20;
  final List<TrafficBytes> _trafficBytesList = List.generate(
    maxPoint,
    (index) => TrafficBytes(DateTime.now().subtract(Duration(seconds: maxPoint - index)), 0, 0),
  );

  Widget _buildChart(TrafficBytes trafficBytes) {
    final ThemeData themeData = Theme.of(context);
    final Color colorRx = themeData.accentColor;
    final Color colorTx =
        (themeData.brightness == Brightness.light) ? Colors.purple : Colors.purpleAccent;

    _trafficBytesList.add(trafficBytes);
    if (_trafficBytesList.length > maxPoint) {
      _trafficBytesList.removeAt(0);
    }

    final List<FlSpot> rxList = List.generate(maxPoint, (index) {
      return FlSpot(index.toDouble(), _trafficBytesList[index].rxBytes.toDouble());
    });
    final List<FlSpot> txList = List.generate(maxPoint, (index) {
      return FlSpot(index.toDouble(), _trafficBytesList[index].txBytes.toDouble());
    });

    final FlSpot maxRx = rxList.reduce((value, element) => value.y > element.y ? value : element);
    final FlSpot maxTx = txList.reduce((value, element) => value.y > element.y ? value : element);
    final double maxY = max(max(maxRx.y, maxTx.y) * 1.1, 10000);
    final double horizontalInterval = maxY / 2;

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(enabled: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        backgroundColor: themeData.cardColor,
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          horizontalInterval: horizontalInterval,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: themeData.dividerColor.withOpacity(0.04),
              strokeWidth: 1,
            );
          },
        ),
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            barWidth: 1,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            colors: [colorRx],
            spots: rxList,
            belowBarData: BarAreaData(
              show: true,
              cutOffY: 0,
              applyCutOffY: true,
              colors: [colorRx.withOpacity(0.6)],
            ),
          ),
          LineChartBarData(
            barWidth: 1,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            colors: [colorTx],
            spots: txList,
            belowBarData: BarAreaData(
              show: true,
              cutOffY: 0,
              applyCutOffY: true,
              colors: [colorTx.withOpacity(0.1)],
            ),
          ),
        ],
      ),
      swapAnimationDuration: Duration.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO necessary?
    return Container(
      //padding: const EdgeInsets.all(5),
      child: AspectRatio(
        aspectRatio: 4.5,
        child: ValueListenableBuilder(
          valueListenable: dataEvent.trafficBytes,
          builder: (context, trafficBytes, child) => _buildChart(trafficBytes as TrafficBytes),
        ),
      ),
    );
  }
}
