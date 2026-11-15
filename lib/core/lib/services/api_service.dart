import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants.dart';
import '../models/app_user.dart';
import '../models/product.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

/// Thin wrapper around the DummyJSON REST API (https://dummyjson.com).
class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _timeout = Duration(seconds: 15);

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$path').replace(queryParameters: query);
    try {
      final http.Response res = method == 'POST'
          ? await _client
              .post(
                uri,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(body),
              )
              .timeout(_timeout)
          : await _client.get(uri).timeout(_timeout);

      final decoded = res.body.isEmpty ? null : jsonDecode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) return decoded;

      final message = decoded is Map && decoded['message'] is String
          ? decoded['message'] as String
          : 'Server error (${res.statusCode})';
      throw ApiException(message);
    } on SocketException {
      throw ApiException('No internet connection. Check your network and try again.');
    } on TimeoutException {
      throw ApiException('The request timed out. Please try again.');
    } on FormatException {
      throw ApiException('Received an unexpected response from the server.');
    } on http.ClientException {
      throw ApiException('Could not reach the server.');
    }
  }

  /// POST /auth/login
  Future<AppUser> login(String username, String password) async {
    final data = await _request('POST', '/auth/login', body: {
      'username': username,
      'password': password,
      'expiresInMins': 60,
    });
    return AppUser.fromJson(data as Map<String, dynamic>);
  }

  /// GET /products, /products/search?q=, or /products/category/{slug}
  Future<List<Product>> fetchProducts({String query = '', String? category}) async {
    final String path;
    final query0 = <String, String>{'limit': '100'};
    if (query.isNotEmpty) {
      path = '/products/search';
      query0['q'] = query;
    } else if (category != null) {
      path = '/products/category/$category';
    } else {
      path = '/products';
    }
    final data = await _request('GET', path, query: query0) as Map<String, dynamic>;
    return (data['products'] as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /products/category-list
  Future<List<String>> fetchCategories() async {
    final data = await _request('GET', '/products/category-list');
    return (data as List).map((e) => e.toString()).toList();
  }
}
