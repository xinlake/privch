import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xinlake_tunnel/xinlake_tunnel.dart';

enum ServerAddingMethod { scanScreen, scanQrcode, importImage, create }

enum ServerSortMode { updated, name, encrypt }

class ServerProvider with ChangeNotifier {
  final _keySelectedId = "Server-Selected-Id";
  final _keyImportMethodIndex = "Server-ImportMethod-Index";
  final _keySortModeIndex = "Server-SortMode-Index";

  late final SharedPreferences _preferences;
  late final Box<Shadowsocks> _serverBox;

  bool get serverEmpty => _serverBox.isEmpty;
  List<Shadowsocks> get serverList => _serverBox.values.toList();

  // selected server
  Shadowsocks? _selected;
  Shadowsocks? get selected => _selected;

  Future<void> setSelected(Shadowsocks shadowsocks) async {
    if (_selected != shadowsocks) {
      _selected = shadowsocks;

      await _preferences.setString(_keySelectedId, shadowsocks.id);
      notifyListeners();
    }
  }

  // import server
  ServerAddingMethod? _importMethod;
  ServerAddingMethod? get importMethod => _importMethod;

  Future<void> setImportMethod(ServerAddingMethod importMethod) async {
    if (_importMethod != importMethod) {
      _importMethod = importMethod;

      await _preferences.setInt(_keyImportMethodIndex, importMethod.index);
      notifyListeners();
    }
  }

  // sort
  ServerSortMode _sortMode = ServerSortMode.updated;
  ServerSortMode get sortMode => _sortMode;

  Future<void> setSortMode(ServerSortMode sortMode) async {
    if (_sortMode != sortMode) {
      _sortMode = sortMode;

      await _preferences.setInt(_keySortModeIndex, sortMode.index);
      notifyListeners();
    }
  }

  // dismiss to edit
  bool _dismissToEdit = false;
  bool get dismissToEdit => _dismissToEdit;
  set dismissToEdit(bool edit) {
    if (_dismissToEdit != edit) {
      _dismissToEdit = edit;
      notifyListeners();
    }
  }

  // dismiss to delete
  bool _dismissToDelete = false;
  bool get dismissToDelete => _dismissToDelete;
  set dismissToDelete(bool delete) {
    if (_dismissToDelete != delete) {
      _dismissToDelete = delete;
      notifyListeners();
    }
  }

  // SERVERS ---
  // get server by id
  Shadowsocks? getServer(String id) {
    return _serverBox.get(id);
  }

  /// onOverWrite: return true to continue overwrite, return else to cancel overwrite
  Future<void> put(Shadowsocks shadowsocks, {bool Function()? onOverWrite}) async {
    if (onOverWrite != null && _serverBox.containsKey(shadowsocks.id)) {
      if (onOverWrite.call() == false) {
        return;
      }
    }

    await _serverBox.put(shadowsocks.id, shadowsocks);
    notifyListeners();
  }

  Future<void> putAll(List<Shadowsocks> ssList) async {
    for (var shadowsocks in ssList) {
      await _serverBox.put(shadowsocks.id, shadowsocks);
    }

    await _serverBox.flush();
    notifyListeners();
  }

  Future<void> delete(Shadowsocks shadowsocks) async {
    await _serverBox.delete(shadowsocks.id);
    notifyListeners();
  }

  Future<void> deleteAll() async {
    await _serverBox.clear();
    notifyListeners();
  }

  // PROVIDER ---
  bool _initialized = false;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (!_initialized) {
      _preferences = await SharedPreferences.getInstance();
      _serverBox = await Hive.openBox("shadowsocks");

      final selectedId = _preferences.getString(_keySelectedId);
      if (selectedId != null) {
        _selected = _serverBox.get(selectedId);
      }

      final importMethodIndex = _preferences.getInt(_keyImportMethodIndex);
      if (importMethodIndex != null) {
        _importMethod = ServerAddingMethod.values[importMethodIndex];
      }

      final sortModeIndex = _preferences.getInt(_keySortModeIndex);
      if (sortModeIndex != null) {
        _sortMode = ServerSortMode.values[sortModeIndex];
      }

      _initialized = true;
    }
  }
}
