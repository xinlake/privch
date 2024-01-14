// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:http/http.dart' as http;

import 'types.dart';
import 'xinlake_platform_interface.dart';

/// A web implementation of the XinlakePlatformPlatform of the XinlakePlatform plugin.
class XinlakePlatformWeb extends XinlakePlatformInterface {
  /// Constructs a XinlakePlatformWeb
  XinlakePlatformWeb();

  static void registerWith(Registrar registrar) {
    XinlakePlatformInterface.instance = XinlakePlatformWeb();
  }

  Future<Map<String, dynamic>> _getVersionMap() async {
    final cacheBuster = DateTime.now().millisecondsSinceEpoch;
    final baseUri = Uri.parse(html.window.document.baseUri!);

    // Get version.json full url.
    final originPath = '${baseUri.origin}${baseUri.path}';
    final versionJson = 'version.json?cachebuster=$cacheBuster';

    final jsonUrl = Uri.parse(
        originPath.endsWith('/') ? '$originPath$versionJson' : '$originPath/$versionJson');

    final response = await http.get(jsonUrl);
    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body);
      } catch (exception) {
        // ignored
      }
    }

    return <String, dynamic>{};
  }

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
    return null;
  }

  @override
  Future<VersionInfo?> getAppVersion() async {
    final versionMap = await _getVersionMap();

    return VersionInfo(
      version: versionMap['version'] ?? '',
      buildNumber: int.tryParse(versionMap['build_number'] ?? ''),
      appName: versionMap['app_name'],
      packageName: versionMap['package_name'],
    );
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = html.window.navigator.userAgent;
    return version;
  }
}
