// lib/models/product.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';

class Product {
  final int id;
  final String name;
  final String price;
  final String category;
  final String imageUrl;
  final String description;
  final int stockQuantity;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.description,
    required this.stockQuantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Debug: Print the raw JSON to see what we're getting
    if (kDebugMode) {
      print('=== PRODUCT JSON DEBUG ===');
      print('Product ID: ${json['id']}');
      print('Product Name: ${json['name']}');
      print(
          'Raw Image Data: ${json['images'] ?? json['image'] ?? json['image_url']}');
      print('========================');
    }

    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Product',
      price:
          '\$${double.tryParse(json['price'].toString())?.toStringAsFixed(2) ?? '0.00'}',
      category: json['category']?['name'] ??
          json['subcategory']?['name'] ??
          json['category_name'] ??
          'GENERAL',
      imageUrl: _getImageUrl(json),
      description: json['description'] ?? 'No description available',
      stockQuantity: json['stock_quantity'] ?? 0,
    );
  }

  // Enhanced image URL method with better debugging and fallbacks
  static String _getImageUrl(Map<String, dynamic> json) {
    try {
      // Try to get image from multiple possible fields
      dynamic imageData = json['images'] ??
          json['image'] ??
          json['image_url'] ??
          json['photo'] ??
          json['picture'];

      String imagePath = '';

      // Handle different image data formats
      if (imageData is List && imageData.isNotEmpty) {
        // Handle array of images - take the first one
        imagePath = imageData[0].toString();
      } else if (imageData is String && imageData.isNotEmpty) {
        // Handle string image data
        if (imageData.startsWith('[') && imageData.endsWith(']')) {
          // It's a JSON string array
          try {
            List<dynamic> parsed = jsonDecode(imageData);
            if (parsed.isNotEmpty) {
              imagePath = parsed[0].toString();
            }
          } catch (e) {
            // If parsing fails, use the string as-is
            imagePath = imageData;
          }
        } else {
          // It's a direct string path
          imagePath = imageData;
        }
      }

      // Clean up the image path
      imagePath = imagePath.trim();

      // Debug: Print what we found
      if (kDebugMode) {
        print('Processed Image Path: $imagePath');
      }

      // If no valid image path found, return placeholder
      if (imagePath.isEmpty ||
          imagePath.toLowerCase().contains('placeholder') ||
          imagePath.toLowerCase().contains('null')) {
        const fallbackUrl =
            'https://via.placeholder.com/300x300/8B4513/FFFFFF?text=Pearl+%26+Prestige';
        if (kDebugMode) {
          print('Using fallback image: $fallbackUrl');
        }
        return fallbackUrl;
      }

      // If already a full URL, return as-is
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        if (kDebugMode) {
          print('Using full URL: $imagePath');
        }
        return imagePath;
      }

      // Build the full URL - try different base URLs
      String finalUrl = _buildImageUrl(imagePath);

      if (kDebugMode) {
        print('Final Image URL: $finalUrl');
      }

      return finalUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error processing image URL: $e');
      }
      return 'https://via.placeholder.com/300x300/8B4513/FFFFFF?text=Pearl+%26+Prestige';
    }
  }

  // Build image URL with multiple fallback options
  static String _buildImageUrl(String imagePath) {
    // Remove leading slash if present
    if (imagePath.startsWith('/')) {
      imagePath = imagePath.substring(1);
    }

    // Try different base URL patterns
    List<String> baseUrls = [
      'https://pearlprestige.shop/', // Your main domain
      'https://pearlprestige.shop/public/images/products', // Laravel storage
      'https://pearlprestige.shop/public/', // Public folder
      'http://10.0.2.2:8000/', // Local development
      'http://localhost:8000/', // Alternative local
    ];

    // For now, return the first option
    // You can modify this based on your server setup
    String finalUrl = '${baseUrls[0]}$imagePath';

    return finalUrl;
  }
}

// Helper function to test image URLs
class ImageUrlTester {
  static Future<bool> testImageUrl(String url) async {
    try {
      // You can implement actual URL testing here if needed
      return url.isNotEmpty &&
          (url.startsWith('http://') || url.startsWith('https://'));
    } catch (e) {
      return false;
    }
  }
}
