import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xinlake_tunnel/xinlake_tunnel.dart' as xt;

class SettingProvider with ChangeNotifier {
  final _keyAppLocaleLanguageCode = "App-Locale-LanguageCode";
  final _keyAppThemeModeIndex = "App-ThemeMode-Index";
  final _keyAppThemeColorLight = "App-ThemeColorLight";
  final _keyAppThemeColorDark = "App-ThemeColorDark";

  final _keyTunnelProxyPort = "Tunnel-ProxyPort";
  final _keyTunnelDnsLocalPort = "Tunnel-DnsLocalPort";
  final _keyTunnelDnsRemoteAddress = "Tunnel-DnsRemoteAddress";

  late final SharedPreferences _preferences;

  // APPLICATION ---
  // language
  Locale? _appLocale;
  Locale? get appLocale => _appLocale;

  Future<void> setAppLocale(Locale locale) async {
    if (_appLocale != locale) {
      _appLocale = locale;

      await _preferences.setString(_keyAppLocaleLanguageCode, locale.languageCode);
      notifyListeners();
    }
  }

  // theme model
  ThemeMode _appThemeMode = ThemeMode.system;
  ThemeMode get appThemeMode => _appThemeMode;

  Future<void> setAppThemeMode(ThemeMode themeMode) async {
    if (_appThemeMode != themeMode) {
      _appThemeMode = themeMode;

      await _preferences.setInt(_keyAppThemeModeIndex, themeMode.index);
      notifyListeners();
    }
  }

  // light color
  Color _appThemeColorLight = const Color(0xff6750a4);
  Color get appThemeColorLight => _appThemeColorLight;

  Future<void> setAppThemeColorLight(Color color) async {
    if (_appThemeColorLight != color) {
      _appThemeColorLight = color;

      await _preferences.setInt(_keyAppThemeColorLight, color.value);
      notifyListeners();
    }
  }

  // dark color
  Color _appThemeColorDark = const Color(0xff00cc6a);
  Color get appThemeColorDart => _appThemeColorDark;

  Future<void> setAppThemeColorDark(Color color) async {
    if (_appThemeColorDark != color) {
      _appThemeColorDark = color;

      await _preferences.setInt(_keyAppThemeColorDark, color.value);
      notifyListeners();
    }
  }

  // TUNNEL ---
  void resetTunnelEditing() {
    _tunnelProxyPortChange = _tunnelProxyPort;
    _tunnelDnsLocalPortChange = _tunnelDnsLocalPort;
    _tunnelDnsRemoteAddressChange = _tunnelDnsRemoteAddress;
  }

  // proxy port
  int _tunnelProxyPort = 1090;
  int get tunnelProxyPort => _tunnelProxyPort;

  int? _tunnelProxyPortChange;
  int? get tunnelProxyPortChange => _tunnelProxyPortChange;
  set tunnelProxyPortChange(int? value) {
    if (_tunnelProxyPortChange != value) {
      _tunnelProxyPortChange = value;
      notifyListeners();
    }
  }

  void resetTunnelProxyPortChange() {
    if (_tunnelProxyPortChange != _tunnelProxyPort) {
      _tunnelProxyPortChange = _tunnelProxyPort;
      notifyListeners();
    }
  }

  Future<void> setTunnelProxyPort(int port) async {
    if (_tunnelProxyPort != port) {
      _tunnelProxyPort = port;
      _tunnelProxyPortChange = port;

      await _preferences.setInt(_keyTunnelProxyPort, port);
      notifyListeners();

      // async
      xt.updateSettings(
        proxyPort: _tunnelProxyPort,
        dnsLocalPort: _tunnelDnsLocalPort,
        dnsRemoteAddress: _tunnelDnsRemoteAddress,
      );
    }
  }

  // dns local port
  int _tunnelDnsLocalPort = 5450;
  int get tunnelDnsLocalPort => _tunnelDnsLocalPort;

  int? _tunnelDnsLocalPortChange;
  int? get tunnelDnsLocalPortChange => _tunnelDnsLocalPortChange;
  set tunnelDnsLocalPortChange(int? value) {
    if (_tunnelDnsLocalPortChange != value) {
      _tunnelDnsLocalPortChange = value;
      notifyListeners();
    }
  }

  void resetTunnelDnsLocalPortChange() {
    if (_tunnelDnsLocalPortChange != _tunnelDnsLocalPort) {
      _tunnelDnsLocalPortChange = _tunnelDnsLocalPort;
      notifyListeners();
    }
  }

  Future<void> setTunnelDnsLocalPort(int port) async {
    if (_tunnelDnsLocalPort != port) {
      _tunnelDnsLocalPort = port;
      _tunnelDnsLocalPortChange = port;

      await _preferences.setInt(_keyTunnelDnsLocalPort, port);
      notifyListeners();

      // async
      xt.updateSettings(
        proxyPort: _tunnelProxyPort,
        dnsLocalPort: _tunnelDnsLocalPort,
        dnsRemoteAddress: _tunnelDnsRemoteAddress,
      );
    }
  }

  // dns server
  String _tunnelDnsRemoteAddress = "8.8.8.8";
  String get tunnelDnsRemoteAddress => _tunnelDnsRemoteAddress;

  String? _tunnelDnsRemoteAddressChange;
  String? get tunnelDnsRemoteAddressChange => _tunnelDnsRemoteAddressChange;
  set tunnelDnsRemoteAddressChange(String? value) {
    if (_tunnelDnsRemoteAddressChange != value) {
      _tunnelDnsRemoteAddressChange = value;
      notifyListeners();
    }
  }

  void resetTunnelDnsRemoteAddressChange() {
    if (_tunnelDnsRemoteAddressChange != _tunnelDnsRemoteAddress) {
      _tunnelDnsRemoteAddressChange = _tunnelDnsRemoteAddress;
      notifyListeners();
    }
  }

  Future<void> setTunnelDnsRemoteAddress(String address) async {
    if (_tunnelDnsRemoteAddress != address) {
      _tunnelDnsRemoteAddress = address;
      _tunnelDnsRemoteAddressChange = address;

      await _preferences.setString(_keyTunnelDnsRemoteAddress, address);
      notifyListeners();

      // async
      xt.updateSettings(
        proxyPort: _tunnelProxyPort,
        dnsLocalPort: _tunnelDnsLocalPort,
        dnsRemoteAddress: _tunnelDnsRemoteAddress,
      );
    }
  }

  // PROVIDER ---
  bool _initialized = false;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (!_initialized) {
      _preferences = await SharedPreferences.getInstance();

      // app locale
      final localeLanguageCode = _preferences.getString(_keyAppLocaleLanguageCode);
      if (localeLanguageCode != null) {
        _appLocale = Locale(localeLanguageCode);
      }

      // app theme mode
      final themeModeIndex = _preferences.getInt(_keyAppThemeModeIndex);
      if (themeModeIndex != null &&
          themeModeIndex >= 0 &&
          themeModeIndex < ThemeMode.values.length) {
        _appThemeMode = ThemeMode.values[themeModeIndex];
      }

      // app light color
      final themeColorLight = _preferences.getInt(_keyAppThemeColorLight);
      if (themeColorLight != null) {
        _appThemeColorLight = Color(themeColorLight);
      }
      // app dark color
      final themeColorDark = _preferences.getInt(_keyAppThemeColorDark);
      if (themeColorDark != null) {
        _appThemeColorDark = Color(themeColorDark);
      }

      // tunnel proxy port
      final proxyPort = _preferences.getInt(_keyTunnelProxyPort);
      if (proxyPort != null) {
        _tunnelProxyPort = proxyPort;
      }
      _tunnelProxyPortChange = _tunnelProxyPort;

      // tunnel dns local port
      final dnsLocalPort = _preferences.getInt(_keyTunnelDnsLocalPort);
      if (dnsLocalPort != null) {
        _tunnelDnsLocalPort = dnsLocalPort;
      }
      _tunnelDnsLocalPortChange = _tunnelDnsLocalPort;

      // tunnel dns address
      final dnsRemoteAddress = _preferences.getString(_keyTunnelDnsRemoteAddress);
      if (dnsRemoteAddress != null) {
        _tunnelDnsRemoteAddress = dnsRemoteAddress;
      }
      _tunnelDnsRemoteAddressChange = _tunnelDnsRemoteAddress;

      // init tunnel settings
      await xt.updateSettings(
        proxyPort: _tunnelProxyPort,
        dnsLocalPort: _tunnelDnsLocalPort,
        dnsRemoteAddress: _tunnelDnsRemoteAddress,
      );

      // TODO: x internal
      notifyListeners();
      _initialized = true;
    }
  }
}
