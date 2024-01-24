library xinlake_responsive;

import 'package:flutter/material.dart';

class SplitTwo extends StatefulWidget {
  /// * [dividerInitPosition]. The initial position of the splitter in proportion,
  /// the value must between [dividerPositionMin] and [dividerPositionMax]
  const SplitTwo({
    required this.childA,
    required this.childB,
    this.isPortrait = false,
    this.dividerInitPosition = 0.5,
    this.dividerPositionMin = 0.2,
    this.dividerPositionMax = 0.8,
    this.dividerSize = 5,
    this.dividerColor,
    this.dividerColorActive,
    Key? key,
  })  : assert(dividerPositionMin < dividerPositionMax),
        super(key: key);

  final Widget childA;
  final Widget childB;
  final bool isPortrait;

  final double dividerInitPosition;
  final double dividerPositionMax;
  final double dividerPositionMin;
  final double dividerSize;
  final Color? dividerColor;
  final Color? dividerColorActive;

  @override
  SplitState createState() => SplitState();
}

class SplitState extends State<SplitTwo> {
  late double _dividerPos; // 0-1
  Color? _dividerColor;

  Widget _buildLandscape() {
    return LayoutBuilder(builder: (context, constraints) {
      final dividerX = constraints.maxWidth * _dividerPos - (widget.dividerSize / 2);
      final contentWidth = constraints.maxWidth - 1;
      final widthA = contentWidth * _dividerPos;
      final widthB = contentWidth - widthA;

      final divider = MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: (details) {
            setState(() {
              _dividerColor = widget.dividerColorActive ?? Theme.of(context).colorScheme.secondary;
            });
          },
          onHorizontalDragEnd: (details) {
            setState(() {
              _dividerColor = null;
            });
          },
          onHorizontalDragUpdate: (details) {
            setState(() {
              _dividerPos += details.delta.dx / contentWidth;
              if (_dividerPos > widget.dividerPositionMax) {
                _dividerPos = widget.dividerPositionMax;
              } else if (_dividerPos < widget.dividerPositionMin) {
                _dividerPos = widget.dividerPositionMin;
              }
            });
          },
          child: Container(
            color: _dividerColor,
          ),
        ),
      );

      return Stack(
        children: [
          Row(
            children: <Widget>[
              SizedBox(
                width: widthA,
                child: widget.childA,
              ),
              Container(
                width: 1,
                color: widget.dividerColor ?? Theme.of(context).dividerColor,
              ),
              SizedBox(
                width: widthB,
                child: widget.childB,
              ),
            ],
          ),
          Positioned(
            width: widget.dividerSize,
            height: constraints.maxHeight,
            left: dividerX,
            child: divider,
          ),
        ],
      );
    });
  }

  Widget _buildPortrait() {
    return LayoutBuilder(builder: (context, constraints) {
      final dividerY = constraints.maxHeight * _dividerPos - (widget.dividerSize / 2);
      final contentHeight = constraints.maxHeight - 1;
      final heightA = contentHeight * _dividerPos;
      final heightB = contentHeight - heightA;

      final divider = MouseRegion(
        cursor: SystemMouseCursors.resizeRow,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragStart: (details) {
            setState(() {
              _dividerColor = widget.dividerColorActive ?? Theme.of(context).colorScheme.secondary;
            });
          },
          onVerticalDragEnd: (details) {
            setState(() {
              _dividerColor = null;
            });
          },
          onVerticalDragUpdate: (details) {
            setState(() {
              _dividerPos += details.delta.dy / contentHeight;
              if (_dividerPos > widget.dividerPositionMax) {
                _dividerPos = widget.dividerPositionMax;
              } else if (_dividerPos < widget.dividerPositionMin) {
                _dividerPos = widget.dividerPositionMin;
              }
            });
          },
          child: Container(
            color: _dividerColor,
          ),
        ),
      );

      return Stack(
        children: [
          Column(
            children: <Widget>[
              SizedBox(
                height: heightA,
                child: widget.childA,
              ),
              Container(
                height: 1,
                color: widget.dividerColor ?? Theme.of(context).dividerColor,
              ),
              SizedBox(
                height: heightB,
                child: widget.childB,
              ),
            ],
          ),
          Positioned(
            width: constraints.maxWidth,
            height: widget.dividerSize,
            top: dividerY,
            child: divider,
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.isPortrait ? _buildPortrait() : _buildLandscape();
  }

  @override
  void initState() {
    super.initState();
    _dividerPos = widget.dividerInitPosition;
    if (_dividerPos < widget.dividerPositionMin) {
      _dividerPos = widget.dividerPositionMin;
    } else if (_dividerPos > widget.dividerPositionMax) {
      _dividerPos = widget.dividerPositionMax;
    }
  }
}
