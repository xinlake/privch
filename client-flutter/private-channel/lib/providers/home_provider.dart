import 'package:flutter/material.dart';

enum HomeTab {
  dashboard,
  servers,
  settings,
}

class HomeTabProvider with ChangeNotifier {
  // content view
  HomeTab _homeTab = HomeTab.dashboard;
  HomeTab get homeTab => _homeTab;
  set homeTab(HomeTab homeTab) {
    if (_homeTab != homeTab) {
      _homeTab = homeTab;

      notifyListeners();
    }
  }
}
