// lib/providers/products_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class ProductsProvider extends ChangeNotifier {
  // Private variables
  List<Product> _products = [];
  List<Product> _favorites = [];
  bool _isLoading = false;
  String _error = '';

  // SSP API URL
  static const String _baseUrl = 'https://pearlprestige.shop/api';

  // Getters
  List<Product> get products => _products;
  List<Product> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Filtered products by category
  List<Product> get womenProducts => _products
      .where((product) => product.category.toLowerCase().contains('women'))
      .toList();

  List<Product> get menProducts => _products
      .where((product) => product.category.toLowerCase().contains('men'))
      .toList();

  List<Product> get accessoriesProducts => _products
      .where(
          (product) => product.category.toLowerCase().contains('accessories'))
      .toList();

  // Constructor - load favorites and fetch products when created
  ProductsProvider() {
    _loadFavorites();
    fetchProducts();
  }

  // Get authentication token from storage
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fetch products from your SSP API
  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final token = await _getToken();
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      // Add authentication header if user is logged in
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/products'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle both paginated and direct array responses
        List<dynamic> productsJson;
        if (data is Map && data.containsKey('data')) {
          productsJson = data['data']; // Paginated response
        } else if (data is List) {
          productsJson = data; // Direct array
        } else {
          productsJson = data['products'] ?? []; // Other format
        }

        _products = productsJson.map((json) => Product.fromJson(json)).toList();
        _error = '';
      } else {
        _error = 'Failed to load products: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Network error: Please check your connection';
      print('Error fetching products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search products
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      fetchProducts();
      return;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final token = await _getToken();
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/products?search=$query'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<dynamic> productsJson;
        if (data is Map && data.containsKey('data')) {
          productsJson = data['data'];
        } else if (data is List) {
          productsJson = data;
        } else {
          productsJson = data['products'] ?? [];
        }

        _products = productsJson.map((json) => Product.fromJson(json)).toList();
        _error = '';
      } else {
        _error = 'Search failed: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Network error: Please check your connection';
      print('Error searching products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get products by category
  Future<void> fetchProductsByCategory(String categoryName) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final token = await _getToken();
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/products?category=$categoryName'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<dynamic> productsJson;
        if (data is Map && data.containsKey('data')) {
          productsJson = data['data'];
        } else if (data is List) {
          productsJson = data;
        } else {
          productsJson = data['products'] ?? [];
        }

        _products = productsJson.map((json) => Product.fromJson(json)).toList();
        _error = '';
      } else {
        _error = 'Failed to load category products: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Network error: Please check your connection';
      print('Error fetching category products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle favorite
  void toggleFavorite(Product product) {
    if (_favorites.any((fav) => fav.id == product.id)) {
      _favorites.removeWhere((fav) => fav.id == product.id);
    } else {
      _favorites.add(product);
    }
    _saveFavorites();
    notifyListeners();
  }

  // Check if product is favorite
  bool isFavorite(Product product) {
    return _favorites.any((fav) => fav.id == product.id);
  }

  // Save favorites to local storage
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = _favorites
        .map((product) => {
              'id': product.id,
              'name': product.name,
              'price': product.price,
              'category': product.category,
              'imageUrl': product.imageUrl,
              'description': product.description,
              'stockQuantity': product.stockQuantity,
            })
        .toList();

    await prefs.setString('favorites', jsonEncode(favoritesJson));
  }

  // Load favorites from local storage
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesString = prefs.getString('favorites');

      if (favoritesString != null) {
        final List<dynamic> favoritesJson = jsonDecode(favoritesString);
        _favorites =
            favoritesJson.map((json) => Product.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Refresh products
  Future<void> refreshProducts() async {
    await fetchProducts();
  }
}
