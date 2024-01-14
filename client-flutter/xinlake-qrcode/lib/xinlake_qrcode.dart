import 'xinlake_qrcode_platform_interface.dart';

/// android only
Future<String?> fromCamera({
  int? accentColor,
  String? prefix,
  bool? playBeep,
  bool? frontFace,
}) {
  return XinlakeQrcodePlatform.instance.fromCamera(
    accentColor: accentColor,
    prefix: prefix,
    playBeep: playBeep,
    frontFace: frontFace,
  );
}

/// windows only
Future<List<String>?> readScreen() {
  return XinlakeQrcodePlatform.instance.readScreen();
}

Future<List<String>?> readImage(List<String>? imageList) {
  return XinlakeQrcodePlatform.instance.readImage(imageList);
}
