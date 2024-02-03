import 'package:flutter/material.dart';

Widget buildAppTitle(
  BuildContext context, {
  TextStyle? style,
  Color? primaryColor,
  Color? onSurface,
}) {
  return Text.rich(
    TextSpan(
      style: style ?? Theme.of(context).textTheme.titleLarge,
      children: [
        TextSpan(
          text: "Private",
          style: TextStyle(
            color: primaryColor ?? Theme.of(context).colorScheme.primary,
          ),
        ),
        TextSpan(
          text: " Channel",
          style: TextStyle(
            color: onSurface ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    ),
    maxLines: 2,
    textAlign: TextAlign.center,
  );
}
