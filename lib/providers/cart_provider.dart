// lib/providers/cart_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class CartItem {
  final int id;
  final Product product;
  int quantity;
  final String? size;
  final String? color;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    this.size,
    this.color,
  });

  double get totalPrice {
    // You can implement sale price logic here later
    final price = double.tryParse(product.price.replaceAll('\$', '')) ?? 0.0;
    return price * quantity;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': {
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'category': product.category,
        'imageUrl': product.imageUrl,
        'description': product.description,
        'stockQuantity': product.stockQuantity,
      },
      'quantity': quantity,
      'size': size,
      'color': color,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      size: json['size'],
      color: json['color'],
    );
  }
}

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;
  String _error = '';

  static const String _baseUrl = 'https://pearlprestige.shop/api';

  // Getters
  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String get error => _error;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  // Constructor - load cart from local storage
  CartProvider() {
    _loadCartFromLocal();
  }

  // Get authentication token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Add item to cart
  Future<void> addToCart(Product product,
      {int quantity = 1, String? size, String? color}) async {
    final token = await _getToken();

    if (token != null) {
      // If user is logged in, add to server cart
      await _addToServerCart(product,
          quantity: quantity, size: size, color: color);
    } else {
      // If user is not logged in, add to local cart
      _addToLocalCart(product, quantity: quantity, size: size, color: color);
    }
  }

  // Add to server cart (when user is logged in)
  Future<void> _addToServerCart(Product product,
      {int quantity = 1, String? size, String? color}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/cart/add'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'product_id': product.id,
          'quantity': quantity,
          'size': size,
          'color': color,
        }),
      );

      if (response.statusCode == 201) {
        // Refresh cart from server
        await fetchCartFromServer();
      } else {
        final errorData = jsonDecode(response.body);
        _error = errorData['message'] ?? 'Failed to add to cart';
      }
    } catch (e) {
      _error = 'Network error: Please check your connection';
      print('Error adding to server cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add to local cart (when user is not logged in)
  void _addToLocalCart(Product product,
      {int quantity = 1, String? size, String? color}) {
    // Check if item already exists
    final existingIndex = _items.indexWhere((item) =>
        item.product.id == product.id &&
        item.size == size &&
        item.color == color);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(
        id: DateTime.now().millisecondsSinceEpoch, // Local ID
        product: product,
        quantity: quantity,
        size: size,
        color: color,
      ));
    }

    _saveCartToLocal();
    notifyListeners();
  }

  // Fetch cart from server (when user is logged in)
  Future<void> fetchCartFromServer() async {
    final token = await _getToken();
    if (token == null) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/cart'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> cartItemsJson = data['cart_items'] ?? [];

        _items = cartItemsJson
            .map((json) => CartItem(
                  id: json['id'],
                  product: Product.fromJson(json['product']),
                  quantity: json['quantity'],
                  size: json['size'],
                  color: json['color'],
                ))
            .toList();

        _error = '';
      } else {
        _error = 'Failed to load cart';
      }
    } catch (e) {
      _error = 'Network error: Please check your connection';
      print('Error fetching cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update quantity
  Future<void> updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity <= 0) {
      removeFromCart(item);
      return;
    }

    final token = await _getToken();

    if (token != null && item.id > 1000000) {
      // Server item (has real ID)
      await _updateServerQuantity(item, newQuantity);
    } else {
      // Local item
      item.quantity = newQuantity;
      _saveCartToLocal();
      notifyListeners();
    }
  }

  // Update quantity on server
  Future<void> _updateServerQuantity(CartItem item, int newQuantity) async {
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse('$_baseUrl/cart/${item.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'quantity': newQuantity}),
      );

      if (response.statusCode == 200) {
        item.quantity = newQuantity;
        notifyListeners();
      } else {
        _error = 'Failed to update quantity';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Network error: Please check your connection';
      notifyListeners();
    }
  }

  // Remove from cart
  Future<void> removeFromCart(CartItem item) async {
    final token = await _getToken();

    if (token != null && item.id > 1000000) {
      // Server item
      await _removeFromServer(item);
    } else {
      // Local item
      _items.removeWhere((cartItem) => cartItem.id == item.id);
      _saveCartToLocal();
      notifyListeners();
    }
  }

  // Remove from server
  Future<void> _removeFromServer(CartItem item) async {
    try {
      final token = await _getToken();
      final response = await http.delete(
        Uri.parse('$_baseUrl/cart/${item.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _items.removeWhere((cartItem) => cartItem.id == item.id);
        notifyListeners();
      } else {
        _error = 'Failed to remove item';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Network error: Please check your connection';
      notifyListeners();
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    final token = await _getToken();

    if (token != null) {
      // Clear server cart
      try {
        await http.delete(
          Uri.parse('$_baseUrl/cart'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
      } catch (e) {
        print('Error clearing server cart: $e');
      }
    }

    // Clear local cart
    _items.clear();
    _saveCartToLocal();
    notifyListeners();
  }

  // Save cart to local storage
  Future<void> _saveCartToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = _items.map((item) => item.toJson()).toList();
    await prefs.setString('cart', jsonEncode(cartJson));
  }

  // Load cart from local storage
  Future<void> _loadCartFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString('cart');

      if (cartString != null) {
        final List<dynamic> cartJson = jsonDecode(cartString);
        _items = cartJson.map((json) => CartItem.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading cart from local: $e');
    }
  }

  // Sync local cart to server (when user logs in)
  Future<void> syncCartToServer() async {
    final token = await _getToken();
    if (token == null || _items.isEmpty) return;

    for (final item in _items) {
      if (item.id < 1000000) {
        // Local item (needs to be synced)
        await _addToServerCart(
          item.product,
          quantity: item.quantity,
          size: item.size,
          color: item.color,
        );
      }
    }

    // After syncing, fetch fresh cart from server
    await fetchCartFromServer();
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }
}
