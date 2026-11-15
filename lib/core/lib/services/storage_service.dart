import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../models/product.dart';

/// All local persistence (SharedPreferences) lives here.
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static const _kUser = 'session_user';
  static const _kFavorites = 'favorites';
  static const _kDark = 'dark_mode';
  static const _kAccounts = 'local_accounts';

  static Future<StorageService> create() async =>
      StorageService(await SharedPreferences.getInstance());

  // ---- Session ----
  AppUser? get user {
    final raw = _prefs.getString(_kUser);
    if (raw == null) return null;
    try {
      return AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(AppUser user) => _prefs.setString(_kUser, jsonEncode(user.toJson()));

  Future<void> clearUser() => _prefs.remove(_kUser);

  // ---- Favorites ----
  List<Product> get favorites {
    final raw = _prefs.getString(_kFavorites);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveFavorites(List<Product> items) =>
      _prefs.setString(_kFavorites, jsonEncode(items.map((p) => p.toJson()).toList()));

  // ---- Theme ----
  bool get isDark => _prefs.getBool(_kDark) ?? false;

  Future<void> setDark(bool value) => _prefs.setBool(_kDark, value);

  // ---- Local accounts (for sign-up; DummyJSON has no real registration) ----
  Map<String, dynamic> get _accounts {
    final raw = _prefs.getString(_kAccounts);
    if (raw == null) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return {};
    }
  }

  bool hasAccount(String username) => _accounts.containsKey(username.toLowerCase());

  Future<void> registerAccount(AppUser user, String password) {
    final accounts = _accounts;
    accounts[user.username.toLowerCase()] = {
      'hash': _hash(user.username, password),
      'user': user.toJson(),
    };
    return _prefs.setString(_kAccounts, jsonEncode(accounts));
  }

  AppUser? localLogin(String username, String password) {
    final entry = _accounts[username.toLowerCase()];
    if (entry == null) return null;
    if (entry['hash'] != _hash(username, password)) return null;
    return AppUser.fromJson(Map<String, dynamic>.from(entry['user'] as Map));
  }

  String _hash(String username, String password) =>
      sha256.convert(utf8.encode('${username.toLowerCase()}:$password')).toString();
}
