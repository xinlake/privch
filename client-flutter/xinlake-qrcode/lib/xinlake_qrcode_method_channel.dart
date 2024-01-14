import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'xinlake_qrcode_platform_interface.dart';

/// An implementation of [XinlakeQrcodePlatform] that uses method channels.
class MethodChannelXinlakeQrcode extends XinlakeQrcodePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('xinlake_qrcode');

  @override
  Future<String?> fromCamera({
    int? accentColor,
    String? prefix,
    bool? playBeep,
    bool? frontFace,
  }) async {
    try {
      final String? code = await methodChannel.invokeMethod('fromCamera', {
        "accentColor": accentColor,
        "prefix": prefix,
        "playBeep": playBeep,
        "frontFace": frontFace,
      });
      return code;
    } catch (exception) {
      return null;
    }
  }

  @override
  Future<List<String>?> readScreen() async {
    try {
      final List<String>? codeList = await methodChannel.invokeListMethod('readScreen');
      return codeList;
    } catch (exception) {
      return null;
    }
  }

  @override
  Future<List<String>?> readImage(List<String>? imageList) async {
    try {
      final List<String>? codeList = await methodChannel.invokeListMethod('readImage', {
        "imageList": imageList,
      });
      return codeList;
    } catch (exception) {
      return null;
    }
  }
}
