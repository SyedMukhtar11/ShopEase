import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._api, this._storage);

  final ApiService _api;
  final StorageService _storage;

  AppUser? _user;
  bool _loading = false;
  String? _error;

  AppUser? get user => _user;
  bool get isLoading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  /// Called from the splash screen to restore a saved session.
  void restoreSession() {
    _user = _storage.user;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _start();
    try {
      // Accounts created via sign-up are checked first, then the remote API.
      final u = _storage.localLogin(username, password) ?? await _api.login(username, password);
      await _storage.saveUser(u);
      _user = u;
      _finish();
      return true;
    } on ApiException catch (e) {
      _finish(e.message);
      return false;
    }
  }

  Future<bool> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
  }) async {
    _start();
    if (_storage.hasAccount(username)) {
      _finish('That username is already taken');
      return false;
    }
    final u = AppUser(
      id: DateTime.now().millisecondsSinceEpoch,
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      image: '',
      token: 'local-session',
    );
    await _storage.registerAccount(u, password);
    await _storage.saveUser(u);
    _user = u;
    _finish();
    return true;
  }

  Future<void> logout() async {
    await _storage.clearUser();
    _user = null;
    notifyListeners();
  }

  void _start() {
    _loading = true;
    _error = null;
    notifyListeners();
  }

  void _finish([String? error]) {
    _loading = false;
    _error = error;
    notifyListeners();
  }
}
