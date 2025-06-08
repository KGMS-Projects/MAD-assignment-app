// lib/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/products_provider.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String selectedSize = 'M';
  String selectedColor = 'Default';
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product.name,
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          Consumer<ProductsProvider>(
            builder: (context, products, child) {
              final isWishlisted = products.isFavorite(widget.product);
              return IconButton(
                icon: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: isWishlisted ? Colors.red : null,
                ),
                onPressed: () {
                  products.toggleFavorite(widget.product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isWishlisted
                          ? 'Removed from favorites'
                          : 'Added to favorites'),
                      backgroundColor: const Color(0xFF8B4513),
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share functionality coming soon!'),
                  backgroundColor: Color(0xFF8B4513),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Hero Animation
            Hero(
              tag: 'product-${widget.product.id}',
              child: Container(
                height: 400,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.product.imageUrl),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      // Handle image loading error
                    },
                  ),
                ),
                child: widget.product.imageUrl.contains('placeholder')
                    ? Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 100,
                          color: Colors.grey,
                        ),
                      )
                    : Stack(
                        children: [
                          // Stock status overlay
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: widget.product.stockQuantity > 0
                                    ? Colors.green.withOpacity(0.9)
                                    : Colors.red.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.product.stockQuantity > 0
                                    ? '${widget.product.stockQuantity} in stock'
                                    : 'Out of stock',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and Product Name
                  Text(
                    widget.product.category.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF8B4513),
                      fontSize: 14,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.product.price,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B4513),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description.isNotEmpty
                        ? widget.product.description
                        : 'Crafted with meticulous attention to detail, this exquisite piece embodies the perfect fusion of contemporary design and timeless elegance. Made from the finest materials with superior craftsmanship that reflects our commitment to luxury and quality.',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Size Selection
                  const Text(
                    'Size',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: ['XS', 'S', 'M', 'L', 'XL'].map((size) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              selectedSize = size;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            side: BorderSide(
                              color: selectedSize == size
                                  ? const Color(0xFF8B4513)
                                  : Colors.grey,
                            ),
                            backgroundColor: selectedSize == size
                                ? const Color(0xFF8B4513)
                                : Colors.transparent,
                          ),
                          child: Text(
                            size,
                            style: TextStyle(
                              color: selectedSize == size
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Color Selection
                  const Text(
                    'Color',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children:
                        ['Default', 'Black', 'Brown', 'Navy'].map((color) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              selectedColor = color;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            side: BorderSide(
                              color: selectedColor == color
                                  ? const Color(0xFF8B4513)
                                  : Colors.grey,
                            ),
                            backgroundColor: selectedColor == color
                                ? const Color(0xFF8B4513)
                                : Colors.transparent,
                          ),
                          child: Text(
                            color,
                            style: TextStyle(
                              color: selectedColor == color
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Quantity Selection
                  Row(
                    children: [
                      const Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: quantity > 1
                                  ? () => setState(() => quantity--)
                                  : null,
                              icon: const Icon(Icons.remove),
                              iconSize: 20,
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                quantity.toString(),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (quantity < widget.product.stockQuantity) {
                                  setState(() => quantity++);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Only ${widget.product.stockQuantity} items available'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.add),
                              iconSize: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Additional Product Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Product Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('• Premium quality materials'),
                        const Text('• Handcrafted with attention to detail'),
                        const Text('• Comes with authenticity certificate'),
                        const Text('• 30-day return policy'),
                        const Text('• Free shipping on orders over \$500'),
                        const SizedBox(height: 8),
                        Text(
                          '• Stock available: ${widget.product.stockQuantity} units',
                          style: TextStyle(
                            color: widget.product.stockQuantity > 10
                                ? Colors.green
                                : widget.product.stockQuantity > 0
                                    ? Colors.orange
                                    : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Consumer<CartProvider>(
          builder: (context, cart, child) {
            return Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context
                          .read<ProductsProvider>()
                          .toggleFavorite(widget.product);
                      final isNowFavorite = context
                          .read<ProductsProvider>()
                          .isFavorite(widget.product);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isNowFavorite
                                ? 'Added to favorites!'
                                : 'Removed from favorites',
                          ),
                          backgroundColor: const Color(0xFF8B4513),
                        ),
                      );
                    },
                    icon: Consumer<ProductsProvider>(
                      builder: (context, products, child) {
                        final isFavorite = products.isFavorite(widget.product);
                        return Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color:
                              isFavorite ? Colors.red : const Color(0xFF8B4513),
                        );
                      },
                    ),
                    label: const Text(
                      'WISHLIST',
                      style: TextStyle(
                        color: Color(0xFF8B4513),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF8B4513)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.product.stockQuantity > 0 &&
                            !cart.isLoading
                        ? () async {
                            await cart.addToCart(
                              widget.product,
                              quantity: quantity,
                              size: selectedSize,
                              color: selectedColor != 'Default'
                                  ? selectedColor
                                  : null,
                            );

                            if (mounted) {
                              if (cart.error.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(cart.error),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                cart.clearError();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${widget.product.name} added to cart! (Size: $selectedSize, Qty: $quantity)',
                                    ),
                                    backgroundColor: const Color(0xFF8B4513),
                                    action: SnackBarAction(
                                      label: 'VIEW CART',
                                      textColor: Colors.white,
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/cart');
                                      },
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        : null,
                    icon: cart.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.shopping_bag_outlined),
                    label: Text(
                      cart.isLoading
                          ? 'ADDING...'
                          : widget.product.stockQuantity > 0
                              ? 'ADD TO CART'
                              : 'OUT OF STOCK',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.product.stockQuantity > 0
                          ? const Color(0xFF8B4513)
                          : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
