/*
  Xinlake Liu
  2023-07B
 */

library xinlake_responsive;

import 'package:flutter/material.dart';

class XinHeading extends StatelessWidget {
  const XinHeading({
    super.key,
    required this.title,
    this.child,
    this.padding = const EdgeInsets.only(top: 20, bottom: 10),
    this.textColor = Colors.grey,
    this.dividerColor,
  });

  final String title;
  final Widget? child;

  final EdgeInsetsGeometry padding;
  final Color textColor;
  final Color? dividerColor;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        );

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: textStyle,
              ),
              if (child != null) child!,
            ],
          ),
          Divider(
            thickness: 1,
            color: dividerColor,
          ),
        ],
      ),
    );
  }
}
