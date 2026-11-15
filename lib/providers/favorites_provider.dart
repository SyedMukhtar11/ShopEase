import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/storage_service.dart';

/// Favorites are persisted locally so they survive app restarts.
class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider(this._storage) : _items = _storage.favorites;

  final StorageService _storage;
  final List<Product> _items;

  List<Product> get items => List.unmodifiable(_items);

  bool isFavorite(int id) => _items.any((p) => p.id == id);

  Future<void> toggle(Product product) async {
    if (isFavorite(product.id)) {
      _items.removeWhere((p) => p.id == product.id);
    } else {
      _items.insert(0, product);
    }
    notifyListeners();
    await _storage.saveFavorites(_items);
  }
}
