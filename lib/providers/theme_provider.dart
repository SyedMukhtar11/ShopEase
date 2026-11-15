import 'package:flutter/foundation.dart';

import '../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._storage) : _isDark = _storage.isDark;

  final StorageService _storage;
  bool _isDark;

  bool get isDark => _isDark;

  Future<void> setDark(bool value) async {
    _isDark = value;
    notifyListeners();
    await _storage.setDark(value);
  }
}
