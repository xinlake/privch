import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

Route createRoute(
  Widget newPage, {
  Offset begin = const Offset(-1.0, 0.0),
  Curve curve = Curves.ease,
}) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => newPage,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var tween = Tween(begin: begin, end: Offset.zero).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

String formatSize(int bytes, {int decimals = 1}) {
  if (bytes <= 1024) {
    return "$bytes B";
  }

  const suffixes = ["", " K", " M", " G", " T", " P", " E", " Z", " Y"];
  var i = (log(bytes) / log(1024)).floor();
  return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
}
