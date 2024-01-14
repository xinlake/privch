import 'dart:math';

String formatSize(int bytes, {int decimals = 2, int measure = 1024}) {
  if (bytes <= measure) {
    return "$bytes B";
  }

  const suffixes = [" B", " K", " M", " G", " T", " P", " E", " Z", " Y"];
  var i = (log(bytes) / log(measure)).floor();
  return ((bytes / pow(measure, i)).toStringAsFixed(decimals)) + suffixes[i];
}

String formatIp(int ip) {
  final b1 = (ip) & 0xff;
  final b2 = (ip >> 8) & 0xff;
  final b3 = (ip >> 16) & 0xff;
  final b4 = (ip >> 24) & 0xff;

  return "$b1.$b2.$b3.$b4";
}
