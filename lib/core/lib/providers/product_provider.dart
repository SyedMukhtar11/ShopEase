import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/api_service.dart';

enum LoadState { loading, loaded, error }

enum SortOption { none, priceLow, priceHigh, rating }

extension SortOptionLabel on SortOption {
  String get label {
    switch (this) {
      case SortOption.none:
        return 'Default';
      case SortOption.priceLow:
        return 'Price: Low to High';
      case SortOption.priceHigh:
        return 'Price: High to Low';
      case SortOption.rating:
        return 'Top Rated';
    }
  }
}

class ProductProvider extends ChangeNotifier {
  ProductProvider(this._api);

  final ApiService _api;

  List<Product> _products = [];
  List<Product> _catalog = []; // unfiltered snapshot used by the dashboard
  List<String> _categories = [];

  LoadState state = LoadState.loading;
  String? errorMessage;
  String query = '';
  String? category;
  SortOption sort = SortOption.none;

  Timer? _debounce;
  int _requestId = 0; // ignores stale responses when the user types quickly

  List<Product> get catalog => _catalog;
  List<String> get categories => _categories;

  /// Filtered products with the current sort applied.
  List<Product> get products {
    final list = [..._products];
    switch (sort) {
      case SortOption.priceLow:
        list.sort((a, b) => a.discountedPrice.compareTo(b.discountedPrice));
      case SortOption.priceHigh:
        list.sort((a, b) => b.discountedPrice.compareTo(a.discountedPrice));
      case SortOption.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case SortOption.none:
        break;
    }
    return list;
  }

  bool get hasFilters => query.isNotEmpty || category != null;

  Future<void> init() async {
    await Future.wait([loadProducts(), _loadCategories()]);
  }

  Future<void> _loadCategories() async {
    try {
      _categories = await _api.fetchCategories();
      notifyListeners();
    } on ApiException {
      // Categories are optional; the product list still works without them.
    }
  }

  Future<void> loadProducts() async {
    final id = ++_requestId;
    state = LoadState.loading;
    errorMessage = null;
    notifyListeners();

    try {
      var result = await _api.fetchProducts(query: query, category: category);
      if (id != _requestId) return;

      // The API supports search OR category, so combine them locally.
      if (query.isNotEmpty && category != null) {
        result = result.where((p) => p.category == category).toList();
      }
      _products = result;
      if (!hasFilters) _catalog = result;
      state = LoadState.loaded;
    } on ApiException catch (e) {
      if (id != _requestId) return;
      errorMessage = e.message;
      state = LoadState.error;
    }
    notifyListeners();
  }

  /// Debounced so we don't hit the API on every keystroke.
  void setQuery(String value) {
    query = value.trim();
    notifyListeners();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), loadProducts);
  }

  void setCategory(String? value) {
    if (category == value) return;
    category = value;
    loadProducts();
  }

  void setSort(SortOption value) {
    sort = value;
    notifyListeners();
  }

  void clearFilters() {
    _debounce?.cancel();
    query = '';
    category = null;
    loadProducts();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
