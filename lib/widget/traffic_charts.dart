import 'package:charts_flutter/flutter.dart' as Charts;
import 'package:flutter/material.dart';
import 'package:privch/data/types.dart';
import 'package:privch/platform/data_event.dart';
import 'package:privch/public.dart';

// TODO clear old points when this widget is brought to the front
class TrafficChart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TrafficChartState();
}

class _TrafficChartState extends State<TrafficChart> {
  static const int maxPoint = 30;
  final List<TrafficBytes> _trafficBytesList = List.generate(
    maxPoint,
    (index) => TrafficBytes(DateTime.now().subtract(Duration(seconds: maxPoint - index)), 0, 0),
  );

  Widget _buildChart(TrafficBytes trafficBytes) {
    _trafficBytesList.add(trafficBytes);
    if (_trafficBytesList.length > maxPoint) {
      _trafficBytesList.removeAt(0);
    }

    return Charts.TimeSeriesChart(
      <Charts.Series<TrafficBytes, DateTime>>[
        Charts.Series<TrafficBytes, DateTime>(
          id: 'tx',
          colorFn: (traffic, index) => Charts.MaterialPalette.blue.shadeDefault,
          domainFn: (traffic, index) => traffic.time,
          measureFn: (traffic, index) => traffic.txBytes,
          data: _trafficBytesList,
        ),
        Charts.Series<TrafficBytes, DateTime>(
          id: 'rx',
          colorFn: (traffic, index) => Charts.MaterialPalette.green.shadeDefault,
          domainFn: (traffic, index) => traffic.time,
          measureFn: (traffic, index) => traffic.rxBytes,
          data: _trafficBytesList,
        ),
      ],

      /// Assign a custom style for the measure axis.
      primaryMeasureAxis: Charts.NumericAxisSpec(
        showAxisLine: false,

        // label format
        tickFormatterSpec: Charts.BasicNumericTickFormatterSpec((num) {
          return formatSize(num.toInt(), 1);
        }),

        // label and line style
        renderSpec: Charts.GridlineRendererSpec(
          labelStyle: Charts.TextStyleSpec(color: Charts.MaterialPalette.gray.shadeDefault),
          lineStyle: Charts.LineStyleSpec(
            color: Charts.MaterialPalette.gray.shade700,
            dashPattern: [4, 6],
          ),
        ),
      ),

      /// Assign a custom style for the domain axis.
      domainAxis: Charts.DateTimeAxisSpec(
        showAxisLine: false,
      ),

      behaviors: [
        Charts.LinePointHighlighter(
          showHorizontalFollowLine: Charts.LinePointHighlighterFollowLineType.none,
          showVerticalFollowLine: Charts.LinePointHighlighterFollowLineType.none,
        ),
      ],
      defaultRenderer: Charts.LineRendererConfig(
        includeArea: true,
        stacked: false,
        strokeWidthPx: 1,
      ),

      /// animation make the line dance in vertical direction
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 4),
      child: AspectRatio(
        aspectRatio: 2.8,
        child: ValueListenableBuilder(
          valueListenable: dataEvent.trafficBytes,
          builder: (context, trafficBytes, child) => _buildChart(trafficBytes as TrafficBytes),
        ),
      ),
    );
  }
}
