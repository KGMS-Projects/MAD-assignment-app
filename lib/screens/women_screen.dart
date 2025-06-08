// lib/screens/women_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../widgets/product_card.dart';

class WomenScreen extends StatefulWidget {
  const WomenScreen({super.key});

  @override
  State<WomenScreen> createState() => _WomenScreenState();
}

class _WomenScreenState extends State<WomenScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch products when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductsProvider>(
      builder: (context, productsProvider, child) {
        // Filter women's products
        final womenProducts = productsProvider.womenProducts;

        // Separate by subcategory
        final clothing = womenProducts.where((product) {
          final name = product.name.toLowerCase();
          return name.contains('dress') ||
              name.contains('jeans') ||
              name.contains('shirt') ||
              name.contains('skirt') ||
              name.contains('polo') ||
              name.contains('clothing');
        }).toList();

        final bags = womenProducts.where((product) {
          final name = product.name.toLowerCase();
          return name.contains('bag') ||
              name.contains('backpack') ||
              name.contains('trunk') ||
              name.contains('neverfull') ||
              name.contains('coussin');
        }).toList();

        return RefreshIndicator(
          onRefresh: () async {
            await productsProvider.refreshProducts();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Header
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://images.unsplash.com/photo-1596462324594-b4dd8afbb4dd?w=800'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'WOMEN\'S COLLECTION',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Fashion & Style',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Loading State
                if (productsProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(50),
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading women\'s products...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )

                // Error State
                else if (productsProvider.error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(50),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Failed to load products',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          productsProvider.error,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            productsProvider.clearError();
                            productsProvider.fetchProducts();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B4513),
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )

                // Products sections
                else ...[
                  // Search and Filter Bar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search women\'s products...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Color(0xFF8B4513)),
                              ),
                            ),
                            onSubmitted: (query) {
                              if (query.trim().isNotEmpty) {
                                productsProvider.searchProducts(query.trim());
                              } else {
                                productsProvider.fetchProducts();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            productsProvider.refreshProducts();
                          },
                          icon: const Icon(Icons.refresh),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF8B4513),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Women's Clothing Section
                  if (clothing.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Women\'s Clothing',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF8B4513),
                                ),
                              ),
                              Text(
                                '${clothing.length} items',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: clothing.length,
                            itemBuilder: (context, index) {
                              return ProductCard(product: clothing[index]);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Women's Bags Section
                  if (bags.isNotEmpty) ...[
                    const SizedBox(height: 48),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Women\'s Bags',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF8B4513),
                                ),
                              ),
                              Text(
                                '${bags.length} items',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: bags.length,
                            itemBuilder: (context, index) {
                              return ProductCard(product: bags[index]);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],

                  // All Women's Products Section (if no subcategory filtering)
                  if (clothing.isEmpty &&
                      bags.isEmpty &&
                      womenProducts.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'All Women\'s Products',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF8B4513),
                                ),
                              ),
                              Text(
                                '${womenProducts.length} items',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: womenProducts.length,
                            itemBuilder: (context, index) {
                              return ProductCard(product: womenProducts[index]);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Empty State
                  if (womenProducts.isEmpty && !productsProvider.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(50),
                      child: Column(
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No women\'s products available',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Check back soon for new arrivals',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 32),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
