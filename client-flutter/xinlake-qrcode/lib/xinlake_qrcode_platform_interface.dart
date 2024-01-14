import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'xinlake_qrcode_method_channel.dart';

abstract class XinlakeQrcodePlatform extends PlatformInterface {
  /// Constructs a XinlakeQrcodePlatform.
  XinlakeQrcodePlatform() : super(token: _token);

  static final Object _token = Object();

  static XinlakeQrcodePlatform _instance = MethodChannelXinlakeQrcode();

  /// The default instance of [XinlakeQrcodePlatform] to use.
  ///
  /// Defaults to [MethodChannelXinlakeQrcode].
  static XinlakeQrcodePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [XinlakeQrcodePlatform] when
  /// they register themselves.
  static set instance(XinlakeQrcodePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> fromCamera({
    int? accentColor,
    String? prefix,
    bool? playBeep,
    bool? frontFace,
  }) {
    throw UnimplementedError('Not Implemented.');
  }

  Future<List<String>?> readScreen() {
    throw UnimplementedError('Not Implemented.');
  }

  Future<List<String>?> readImage(List<String>? imageList) {
    throw UnimplementedError('Not Implemented.');
  }
}
