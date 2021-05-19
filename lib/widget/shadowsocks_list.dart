import 'dart:async';

import 'package:flutter/material.dart';
import 'package:privch/data/preference.dart';
import 'package:privch/data/shadowsocks.dart';
import 'package:privch/data/types.dart';

class ShadowsocksList extends StatefulWidget {
  ShadowsocksList(
    this.onItemTap,
    this.onItemDetail,
    this.onItemRemove,
    this.emptyActions,
    this.onEmptyAction,
  );

  final void Function(Shadowsocks) onItemTap;
  final void Function(Shadowsocks) onItemDetail;
  final void Function(int, Shadowsocks) onItemRemove;
  final List<OptionView> emptyActions;
  final void Function(OptionView) onEmptyAction;

  @override
  State<StatefulWidget> createState() => ShadowsocksListState();
}

class ShadowsocksListState extends State<ShadowsocksList> {
  Future<bool> _onItemSwipe(direction, index) async {
    if (direction == DismissDirection.endToStart) {
      widget.onItemDetail(ssManager.getAt(index));
      return false;
    } else if (direction == DismissDirection.startToEnd) {
      // delete action
      return true;
    }

    return false;
  }

  void _onItemDismissed(direction, index) {
    Shadowsocks ssDeleted = ssManager.removeAt(index);
    widget.onItemRemove(index, ssDeleted);
  }

  /// item left background on swipe
  Widget _buildItemBgLeft() {
    final ThemeData themeData = Theme.of(context);

    return Container(
      color: themeData.focusColor,
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.delete_forever,
            color: themeData.backgroundColor,
          ),
          SizedBox(width: 8),
          Text(
            "Delete",
            style: TextStyle(color: themeData.backgroundColor),
          ),
        ],
      ),
    );
  }

  /// item right background on swipe
  Widget _buildItemBgRight() {
    final ThemeData themeData = Theme.of(context);

    return Container(
      color: themeData.selectedRowColor,
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "Edit",
            style: TextStyle(color: themeData.backgroundColor),
          ),
          SizedBox(width: 8),
          Icon(
            Icons.arrow_back,
            color: themeData.backgroundColor,
          ),
        ],
      ),
    );
  }

  /// item content with selection indicate
  Widget _buildItemContent(Shadowsocks ss) {
    return ValueListenableBuilder(
      valueListenable: preference.currentServerId,
      builder: (context, value, child) {
        final ThemeData themeData = Theme.of(context);
        final bool isSelected = ss.id == (value as int);
        return Container(
          color: isSelected ? themeData.secondaryHeaderColor : Colors.transparent,
          child: InkWell(
            onTap: () => widget.onItemTap(ss),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // selection indicator
                Container(
                  height: 45,
                  width: 8,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  color: isSelected ? themeData.accentColor : Colors.transparent,
                ),
                // shadowsocks info
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(ss.name, textScaleFactor: 1.4),
                        SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // TODO, too long ...
                            Text(
                              ss.geoLocation.value ?? ss.modified,
                              style: themeData.textTheme.caption,
                            ),
                            //TODO "${ss.responseTime.value}ms",
                            Text(
                              "",
                              style: isSelected
                                  ? themeData.accentTextTheme.caption
                                  : themeData.textTheme.caption,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItem(context, index) {
    final Shadowsocks ss = ssManager.getAt(index);

    return Dismissible(
      key: Key("${ss.id}"),
      dismissThresholds: {
        DismissDirection.startToEnd: 0.6,
        DismissDirection.endToStart: 0.2,
      },
      confirmDismiss: (direction) => _onItemSwipe(direction, index),
      onDismissed: (direction) => _onItemDismissed(direction, index),
      child: _buildItemContent(ss),
      background: _buildItemBgLeft(),
      secondaryBackground: _buildItemBgRight(),
    );
  }

  /// the display content when the list is empty
  Widget _buildEmpty() {
    final ThemeData themeData = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          "Nothing in list",
          style: themeData.textTheme.headline5,
        ),
        Padding(
          padding: EdgeInsets.only(top: 10, bottom: 20),
          child: Text(
            "Add servers now ?",
            style: themeData.textTheme.subtitle2,
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 50),
          padding: EdgeInsets.only(bottom: 50),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            // empty action buttons
            children: widget.emptyActions.map((item) {
              return ElevatedButton(
                child: Text(item.text),
                onPressed: () => widget.onEmptyAction(item),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _onShadowsocksListChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ssManager.isNotEmpty
        ? ReorderableListView(
            scrollDirection: Axis.vertical,
            onReorder: (oldIndex, newIndex) => ssManager.reorder(oldIndex, newIndex),
            children: List.generate(ssManager.length, (index) {
              return _buildItem(context, index);
            }),
          )
        : _buildEmpty();
  }

  @override
  void initState() {
    super.initState();
    ssManager.addListener(_onShadowsocksListChanged);
  }

  @override
  void dispose() {
    ssManager.removeListener(_onShadowsocksListChanged);
    super.dispose();
  }
}
