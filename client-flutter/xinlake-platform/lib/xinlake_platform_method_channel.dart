import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'types.dart';
import 'xinlake_platform_interface.dart';

/// An implementation of [XinlakePlatformInterface] that uses method channels.
class MethodChannelXinlakePlatform extends XinlakePlatformInterface {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('xinlake_platform');

  @override
  Future<List<File>?> pickFile(
    bool multiSelection,
    String fileTypes,
    // android
    AndroidAppDir? cacheDir,
    bool cacheOverwrite,
    // windows
    String? openPath,
    String? defaultPath,
    String? fileDescription,
  ) async {
    try {
      final list = await methodChannel.invokeListMethod('pickFile', {
        'multiSelection': multiSelection,
        'fileTypes': fileTypes,
        'cacheDirIndex': cacheDir?.index,
        'cacheOverwrite': cacheOverwrite,
        'openPath': openPath,
        'defaultPath': defaultPath,
        'fileDescription': fileDescription,
      });

      if ((list != null)) {
        return list
            .map((map) => File(
                  map['name'],
                  map['path'],
                  map['length'],
                  map['data'],
                  map['modified-ms'],
                ))
            .toList();
      }
    } catch (error) {
      // ignored
    }

    return null;
  }

  @override
  Future<VersionInfo?> getAppVersion() async {
    try {
      final map = await methodChannel.invokeMapMethod<String, dynamic>('getAppVersion');
      if (map != null) {
        return VersionInfo(
          version: map['version'],
          buildNumber: map['build-number'],
          packageName: map['package-name'],
          lastUpdatedMsUtc: map['updated-utc'],
        );
      }
    } catch (error) {
      // ignored
    }

    return null;
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
