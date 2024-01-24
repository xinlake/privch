import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum HomeTab {
  dashboard,
  servers,
  settings,
}

class HomeProvider with ChangeNotifier {
  final _keyHomeContentIndex = "Home-Tab-Index";

  late final SharedPreferences _preferences;

  // content view
  HomeTab _homeContent = HomeTab.dashboard;
  HomeTab get homeContent => _homeContent;

  Future<void> setHomeContent(HomeTab content) async {
    if (_homeContent != content) {
      _homeContent = content;

      _preferences.setInt(_keyHomeContentIndex, content.index);
      notifyListeners();
    }
  }

  // PROVIDER ---
  bool _initialized = false;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (!_initialized) {
      _preferences = await SharedPreferences.getInstance();

      final homeContentIndex = _preferences.getInt(_keyHomeContentIndex);
      if (homeContentIndex != null) {
        // don't restore the content view
        // _homeContent = HomeContent.values[homeContentIndex];
      }

      _initialized = true;
    }
  }
}
