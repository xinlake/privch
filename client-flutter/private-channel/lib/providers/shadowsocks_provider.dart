import 'package:flutter/material.dart';
import 'package:xinlake_tunnel/shadowsocks.dart';

class ShadowsocksProvider extends Shadowsocks with ChangeNotifier {
  ShadowsocksProvider(Shadowsocks shadowsocks, bool create)
      : _enableRestore = !create,
        _passwordInvisible = !create,
        _nameChange = shadowsocks.name,
        _addressChange = shadowsocks.address,
        _portChange = shadowsocks.port,
        _passwordChange = shadowsocks.password,
        super.fromMap(shadowsocks.toMap());

  // restore
  bool _enableRestore;
  bool get enableRestore => _enableRestore;
  set enableRestore(bool enableRestore) {
    if (_enableRestore != enableRestore) {
      _enableRestore = enableRestore;

      notifyListeners();
    }
  }

  // name
  String? _nameChange;
  String? get nameChange => _nameChange;
  set nameChange(String? value) {
    if (_nameChange != value) {
      _nameChange = value;

      notifyListeners();
    }
  }

  void resetNameChange() {
    if (_nameChange != name) {
      _nameChange = name;

      notifyListeners();
    }
  }

  void setName(String name) {
    if (this.name != name) {
      this.name = name;
      _nameChange = name;

      notifyListeners();
    }
  }

  // address
  String? _addressChange;
  String? get addressChange => _addressChange;
  set addressChange(String? value) {
    if (_addressChange != value) {
      _addressChange = value;

      notifyListeners();
    }
  }

  void resetAddressChange() {
    if (_addressChange != address) {
      _addressChange = address;

      notifyListeners();
    }
  }

  void setAddress(String address) {
    if (this.address != address) {
      this.address = address;
      _addressChange = address;

      notifyListeners();
    }
  }

  // port
  int? _portChange;
  int? get portChange => _portChange;
  set portChange(int? value) {
    if (_portChange != value) {
      _portChange = value;

      notifyListeners();
    }
  }

  void resetPortChange() {
    if (_portChange != port) {
      _portChange = port;

      notifyListeners();
    }
  }

  void setPort(int port) {
    if (this.port != port) {
      this.port = port;
      _portChange = port;

      notifyListeners();
    }
  }

  // password
  bool _passwordInvisible;
  bool get passwordInvisible => _passwordInvisible;
  set passwordInvisible(bool value) {
    if (_passwordInvisible != value) {
      _passwordInvisible = value;

      notifyListeners();
    }
  }

  String? _passwordChange;
  String? get passwordChange => _passwordChange;
  set passwordChange(String? value) {
    if (_passwordChange != value) {
      _passwordChange = value;

      notifyListeners();
    }
  }

  void resetPasswordChange() {
    if (_passwordChange != password) {
      _passwordChange = password;

      notifyListeners();
    }
  }

  void setPassword(String password) {
    if (this.password != password) {
      this.password = password;
      _passwordChange = password;

      notifyListeners();
    }
  }

  // encrypt
  void setEncrypt(String encrypt) {
    if (this.encrypt != encrypt) {
      this.encrypt = encrypt;

      notifyListeners();
    }
  }
}
