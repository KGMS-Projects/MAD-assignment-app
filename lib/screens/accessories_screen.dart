// screens/accessories_screen.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../widgets/product_card.dart';

class AccessoriesScreen extends StatefulWidget {
  const AccessoriesScreen({super.key});

  @override
  State<AccessoriesScreen> createState() => _AccessoriesScreenState();
}

class _AccessoriesScreenState extends State<AccessoriesScreen> {
  List<Product> bagsPouchesProducts = [];
  List<Product> perfumesProducts = [];
  List<Product> beltsProducts = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchAccessoriesProducts();
  }

  Future<void> fetchAccessoriesProducts() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final allProducts = await ApiService.fetchProducts();

      // Filter for accessories products only (category_id = 3 in your database)
      final accessoriesProducts = allProducts.where((product) {
        final category = product.category.toLowerCase();
        return category == 'accessories' || category == 'accessory';
      }).toList();

      // Separate by subcategories
      // Bags & Pouches (subcategory_id = 8 - Volet)
      final bagsPouches = accessoriesProducts.where((product) {
        final name = product.name.toLowerCase();
        return name.contains('pouch') ||
            name.contains('bag') ||
            name.contains('trunk') ||
            name.contains('christopher');
      }).toList();

      // Perfumes (subcategory_id = 6)
      final perfumes = accessoriesProducts.where((product) {
        final name = product.name.toLowerCase();
        return name.contains('imagination') ||
            name.contains('attrape') ||
            name.contains('elves') ||
            name.contains('spell') ||
            name.contains('perfume') ||
            name.contains('fragrance');
      }).toList();

      // Belts (subcategory_id = 7)
      final belts = accessoriesProducts.where((product) {
        final name = product.name.toLowerCase();
        return name.contains('belt') ||
            name.contains('flower') ||
            name.contains('dimension') ||
            name.contains('initiales');
      }).toList();

      setState(() {
        bagsPouchesProducts = bagsPouches;
        perfumesProducts = perfumes;
        beltsProducts = belts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _refreshProducts() async {
    await fetchAccessoriesProducts();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshProducts,
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
                      'https://images.unsplash.com/photo-1602751584552-8ba73aad10e1?w=800'),
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
                        'LUXURY ACCESSORIES',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Élégance',
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
            if (isLoading)
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
                      'Loading luxury accessories...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )

            // Error State
            else if (errorMessage.isNotEmpty)
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
                      'Failed to load accessories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: fetchAccessoriesProducts,
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
              // Bags & Pouches Section
              if (bagsPouchesProducts.isNotEmpty) ...[
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Bags & Pouches',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8B4513),
                            ),
                          ),
                          Text(
                            '${bagsPouchesProducts.length} items',
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
                        itemCount: bagsPouchesProducts.length,
                        itemBuilder: (context, index) {
                          return ProductCard(
                              product: bagsPouchesProducts[index]);
                        },
                      ),
                    ],
                  ),
                ),
              ],

              // Perfumes Section
              if (perfumesProducts.isNotEmpty) ...[
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
                            'Perfumes',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8B4513),
                            ),
                          ),
                          Text(
                            '${perfumesProducts.length} items',
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
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: perfumesProducts.length,
                        itemBuilder: (context, index) {
                          return ProductCard(product: perfumesProducts[index]);
                        },
                      ),
                    ],
                  ),
                ),
              ],

              // Belts Section
              if (beltsProducts.isNotEmpty) ...[
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
                            'Belts',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8B4513),
                            ),
                          ),
                          Text(
                            '${beltsProducts.length} items',
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
                          childAspectRatio: 0.9,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: beltsProducts.length,
                        itemBuilder: (context, index) {
                          return ProductCard(product: beltsProducts[index]);
                        },
                      ),
                    ],
                  ),
                ),
              ],

              // Empty State
              if (bagsPouchesProducts.isEmpty &&
                  perfumesProducts.isEmpty &&
                  beltsProducts.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(50),
                  child: Column(
                    children: [
                      Icon(
                        Icons.diamond_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No accessories available',
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
  }
}
