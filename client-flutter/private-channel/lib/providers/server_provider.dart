import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xinlake_tunnel/xinlake_tunnel.dart' as xt;

enum ServerAddingMethod {
  scanScreen,
  scanQrcode,
  importImage,
  create,
}

enum ServerSortMode {
  updated,
  name,
  encrypt,
}

enum ServerGroup {
  privch,
  public,
}

class ServerTabProvider with ChangeNotifier {
  final _keySelectedGroupIndex = "Server-Selected-Group-Index";
  final _keySelectedId = "Server-Selected-Id";
  final _keyServerTabIndex = "Server-Tab-Index";

  late final SharedPreferences _preferences;

  // selected server
  ServerGroup _selectedGroup = ServerGroup.privch;
  ServerGroup get selectedGroup => _selectedGroup;

  xt.Shadowsocks? _selected;
  xt.Shadowsocks? get selected => _selected;

  Future<void> setSelected(ServerGroup group, xt.Shadowsocks shadowsocks) async {
    if (_selectedGroup != group || _selected != shadowsocks) {
      _selectedGroup = group;
      _selected = shadowsocks;

      await _preferences.setInt(_keySelectedGroupIndex, _selectedGroup.index);
      await _preferences.setString(_keySelectedId, shadowsocks.id);
      notifyListeners();
    }
  }

  // server tab
  ServerGroup _serverTab = ServerGroup.privch;
  ServerGroup get serverTab => _serverTab;
  set serverTab(ServerGroup serverPage) {
    if (_serverTab != serverPage) {
      _serverTab = serverPage;

      _preferences.setInt(_keyServerTabIndex, _serverTab.index);
      notifyListeners();
    }
  }

  // PROVIDER ---
  bool _initialized = false;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (!_initialized) {
      _preferences = await SharedPreferences.getInstance();

      final selectedGroupIndex = _preferences.getInt(_keySelectedGroupIndex);
      final selectedId = _preferences.getString(_keySelectedId);
      if (selectedGroupIndex != null && selectedId != null) {
        try {
          final box = await Hive.openBox<xt.Shadowsocks>(
            switch (selectedGroup) {
              ServerGroup.privch => PrivChServerProvider.boxName,
              ServerGroup.public => PublicServerProvider.boxName,
            },
          );
          _selected = box.get(selectedId);
        } catch (error) {
          if (kDebugMode) {
            print(error);
          }
        }
      }

      final serverTabIndex = _preferences.getInt(_keyServerTabIndex);
      if (serverTabIndex != null &&
          serverTabIndex >= 0 &&
          serverTabIndex < ServerGroup.values.length) {
        _serverTab = ServerGroup.values[serverTabIndex];
      }

      _initialized = true;
    }
  }
}

class PrivChServerProvider with ChangeNotifier {
  static const boxName = "privch-shadowsocks";
  final _keySortModeIndex = "PrivChServer-SortMode-Index";

  late final SharedPreferences _preferences;
  late final Box<xt.Shadowsocks> _serverBox;

  bool get serverEmpty => _serverBox.isEmpty;
  List<xt.Shadowsocks> get serverList => _serverBox.values.toList();

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
  bool _dismissToView = false;
  bool get dismissToView => _dismissToView;
  set dismissToView(bool view) {
    if (_dismissToView != view) {
      _dismissToView = view;
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

  // list servers
  bool _processList = false;
  bool get processList => _processList;
  set processList(bool list) {
    if (_processList != list) {
      _processList = list;
      notifyListeners();
    }
  }

  // SERVERS ---
  // get server by id
  xt.Shadowsocks? getServer(String id) {
    return _serverBox.get(id);
  }

  /// onOverWrite: return true to continue overwrite, return else to cancel overwrite
  Future<void> put(xt.Shadowsocks shadowsocks, {bool Function()? onOverWrite}) async {
    if (onOverWrite != null && _serverBox.containsKey(shadowsocks.id)) {
      if (onOverWrite.call() == false) {
        return;
      }
    }

    await _serverBox.put(shadowsocks.id, shadowsocks);
    notifyListeners();
  }

  // TODO more control
  Future<void> putAll(List<xt.Shadowsocks> ssList) async {
    for (final shadowsocks in ssList) {
      await _serverBox.put(shadowsocks.id, shadowsocks);
    }

    await _serverBox.flush();
    notifyListeners();
  }

  Future<void> delete(xt.Shadowsocks shadowsocks) async {
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
      _serverBox = await Hive.openBox(boxName);

      final sortModeIndex = _preferences.getInt(_keySortModeIndex);
      if (sortModeIndex != null &&
          sortModeIndex >= 0 &&
          sortModeIndex < ServerSortMode.values.length) {
        _sortMode = ServerSortMode.values[sortModeIndex];
      }

      _initialized = true;
    }
  }
}

class PublicServerProvider with ChangeNotifier {
  static const boxName = "public-shadowsocks";

  final _keyImportMethodIndex = "PublicServer-ImportMethod-Index";
  final _keySortModeIndex = "PublicServer-SortMode-Index";

  late final SharedPreferences _preferences;
  late final Box<xt.Shadowsocks> _serverBox;

  bool get serverEmpty => _serverBox.isEmpty;
  List<xt.Shadowsocks> get serverList => _serverBox.values.toList();

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
  xt.Shadowsocks? getServer(String id) {
    return _serverBox.get(id);
  }

  /// onOverWrite: return true to continue overwrite, return else to cancel overwrite
  Future<void> put(xt.Shadowsocks shadowsocks, {bool Function()? onOverWrite}) async {
    if (onOverWrite != null && _serverBox.containsKey(shadowsocks.id)) {
      if (onOverWrite.call() == false) {
        return;
      }
    }

    await _serverBox.put(shadowsocks.id, shadowsocks);
    notifyListeners();
  }

  Future<void> putAll(List<xt.Shadowsocks> ssList) async {
    for (final shadowsocks in ssList) {
      await _serverBox.put(shadowsocks.id, shadowsocks);
    }

    await _serverBox.flush();
    notifyListeners();
  }

  Future<void> delete(xt.Shadowsocks shadowsocks) async {
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
      _serverBox = await Hive.openBox(boxName);

      final importMethodIndex = _preferences.getInt(_keyImportMethodIndex);
      if (importMethodIndex != null &&
          importMethodIndex >= 0 &&
          importMethodIndex < ServerAddingMethod.values.length) {
        _importMethod = ServerAddingMethod.values[importMethodIndex];
      }

      final sortModeIndex = _preferences.getInt(_keySortModeIndex);
      if (sortModeIndex != null &&
          sortModeIndex >= 0 &&
          sortModeIndex < ServerSortMode.values.length) {
        _sortMode = ServerSortMode.values[sortModeIndex];
      }

      _initialized = true;
    }
  }
}
