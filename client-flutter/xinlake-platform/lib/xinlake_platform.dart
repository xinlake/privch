import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'mime.dart';
import 'types.dart';
import 'xinlake_platform_interface.dart';

export 'types.dart';

/// Returns a list contains files picked, an empty list if the action was canceled,
/// null if error occurs
/// * **multiSelection**: Multiple selection
/// * **types**: Acceptable file types in MIME format, like "image/jpeg", "audio/\*", "application/xyz".
/// ***
/// **Android**. READ_EXTERNAL_STORAGE permission is required.
/// * **cacheDir**: If set, the file will be copied to the specified directory.
/// * **cacheOverwrite**: This parameter will be ignored if cacheDir is AndroidCacheDir.none
/// ***
/// **Windows**.
/// * **openPath**: Path to open
/// * **defaultPath**: Default open folder for the dialog, if openPath is set
/// then defaultPath will be ignored.
/// * **typesDescription**: Friendly name of the filter such as "JPEG Image"
Future<List<File>?> pickFile({
  bool multiSelection = false,
  required String mimeTypes,
  // android
  AndroidAppDir? cacheDir,
  bool cacheOverwrite = false,
  // windows
  String? openPath,
  String? defaultPath,
  String? typesDescription,
}) {
  String types;
  if (kIsWeb) {
    types = '.${extensionFromMime(mimeTypes).join(', .')}';
  } else if (Platform.isWindows) {
    types = '*.${extensionFromMime(mimeTypes).join('; *.')}';
  } else {
    types = mimeTypes;
  }

  return XinlakePlatformInterface.instance.pickFile(
    multiSelection,
    types,
    cacheDir,
    cacheOverwrite,
    openPath,
    defaultPath,
    typesDescription,
  );
}

/// Get the app version info.
/// The version number is 3 numbers separated by dots, such as 1.2.3.
Future<VersionInfo?> getAppVersion() {
  return XinlakePlatformInterface.instance.getAppVersion();
}

/// Returns a string containing the version of the platform.
Future<String?> getPlatformVersion() {
  return XinlakePlatformInterface.instance.getPlatformVersion();
}
