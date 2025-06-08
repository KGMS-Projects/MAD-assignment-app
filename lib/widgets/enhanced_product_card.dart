// lib/widgets/enhanced_product_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/products_provider.dart';
import '../providers/cart_provider.dart';
import '../screens/product_detail_screen.dart';

class EnhancedProductCard extends StatelessWidget {
  final Product product;

  const EnhancedProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProductsProvider, CartProvider>(
      builder: (context, productsProvider, cartProvider, child) {
        final isFavorite = productsProvider.isFavorite(product);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced Product Image with better error handling
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8)),
                          color: Colors.grey[100],
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8)),
                          child: EnhancedNetworkImage(
                            imageUrl: product.imageUrl,
                            productName: product.name,
                          ),
                        ),
                      ),

                      // Stock Status Badge
                      if (product.stockQuantity <= 0)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'OUT OF STOCK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      else if (product.stockQuantity <= 5)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ONLY ${product.stockQuantity} LEFT',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      // Wishlist Button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                              size: 20,
                            ),
                            onPressed: () {
                              productsProvider.toggleFavorite(product);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isFavorite
                                        ? 'Removed from favorites'
                                        : 'Added to favorites!',
                                  ),
                                  backgroundColor: const Color(0xFF8B4513),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Quick Add to Cart Button
                      if (product.stockQuantity > 0)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B4513).withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: cartProvider.isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.add_shopping_cart,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                              onPressed: cartProvider.isLoading
                                  ? null
                                  : () async {
                                      await cartProvider.addToCart(product);

                                      if (context.mounted) {
                                        if (cartProvider.error.isNotEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(cartProvider.error),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          cartProvider.clearError();
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  '${product.name} added to cart!'),
                                              backgroundColor:
                                                  const Color(0xFF8B4513),
                                              duration:
                                                  const Duration(seconds: 1),
                                            ),
                                          );
                                        }
                                      }
                                    },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Product Info
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF8B4513),
                            fontSize: 10,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              product.price,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF8B4513),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: product.stockQuantity > 0
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: product.stockQuantity > 0
                                      ? Colors.green
                                      : Colors.red,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                product.stockQuantity > 0
                                    ? '${product.stockQuantity} left'
                                    : 'Out of stock',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: product.stockQuantity > 0
                                      ? Colors.green[700]
                                      : Colors.red[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Enhanced Network Image Widget with debugging
class EnhancedNetworkImage extends StatefulWidget {
  final String imageUrl;
  final String productName;

  const EnhancedNetworkImage({
    super.key,
    required this.imageUrl,
    required this.productName,
  });

  @override
  State<EnhancedNetworkImage> createState() => _EnhancedNetworkImageState();
}

class _EnhancedNetworkImageState extends State<EnhancedNetworkImage> {
  bool _imageError = false;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    // Debug: Print the image URL we're trying to load
    print('🖼️ Loading image: ${widget.imageUrl}');

    return Image.network(
      widget.imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          // Image loaded successfully
          if (_isLoading) {
            setState(() {
              _isLoading = false;
            });
          }
          return child;
        } else {
          // Image is loading
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey[100],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
                    strokeWidth: 2,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
      errorBuilder: (context, error, stackTrace) {
        // Image failed to load
        print('❌ Image load error for ${widget.imageUrl}: $error');

        if (!_imageError) {
          setState(() {
            _imageError = true;
          });
        }

        return Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFF8B4513).withOpacity(0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                size: 40,
                color: const Color(0xFF8B4513).withOpacity(0.5),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  widget.productName,
                  style: TextStyle(
                    fontSize: 10,
                    color: const Color(0xFF8B4513).withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Image not available',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
