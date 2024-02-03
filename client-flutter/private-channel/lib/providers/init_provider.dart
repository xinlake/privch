import 'package:flutter/material.dart';

enum InitState { uninitialized, error, initialized }

class InitProvider with ChangeNotifier {
  // init state
  InitState _initialize = InitState.uninitialized;
  InitState get initialize => _initialize;
  set initialize(InitState state) {
    if (_initialize != state) {
      _initialize = state;
      notifyListeners();
    }
  }
}
