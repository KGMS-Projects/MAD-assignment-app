// screens/men_screen.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../widgets/product_card.dart';

class MenScreen extends StatefulWidget {
  const MenScreen({super.key});

  @override
  State<MenScreen> createState() => _MenScreenState();
}

class _MenScreenState extends State<MenScreen> {
  List<Product> clothingProducts = [];
  List<Product> shoesProducts = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchMenProducts();
  }

  Future<void> fetchMenProducts() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final allProducts = await ApiService.fetchProducts();

      // Filter for men's products only - be very specific
      final menProducts = allProducts.where((product) {
        final category = product.category.toLowerCase();
        return category == 'men' || category == 'male';
      }).toList();

      // Separate clothing and shoes based on product names
      final clothing = menProducts.where((product) {
        final name = product.name.toLowerCase();
        return name.contains('shirt') ||
            name.contains('hoodie') ||
            name.contains('shorts') ||
            name.contains('pants') ||
            name.contains('jeans');
      }).toList();

      final shoes = menProducts.where((product) {
        final name = product.name.toLowerCase();
        return name.contains('loafer') ||
            name.contains('boot') ||
            name.contains('sneaker') ||
            name.contains('trainer');
      }).toList();

      setState(() {
        clothingProducts = clothing;
        shoesProducts = shoes;
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
    await fetchMenProducts();
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
                      'https://images.unsplash.com/photo-1617127365659-c47fa864d8bc?w=800'),
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
                        'MEN\'S COLLECTION',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Style & Sophistication',
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
                      'Loading men\'s products...',
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
                      'Failed to load products',
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
                      onPressed: fetchMenProducts,
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
              // Men's Clothing Section
              if (clothingProducts.isNotEmpty) ...[
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
                            'Men\'s Clothing',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8B4513),
                            ),
                          ),
                          Text(
                            '${clothingProducts.length} items',
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
                        itemCount: clothingProducts.length,
                        itemBuilder: (context, index) {
                          return ProductCard(product: clothingProducts[index]);
                        },
                      ),
                    ],
                  ),
                ),
              ],

              // Men's Shoes Section
              if (shoesProducts.isNotEmpty) ...[
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
                            'Men\'s Shoes',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8B4513),
                            ),
                          ),
                          Text(
                            '${shoesProducts.length} items',
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
                        itemCount: shoesProducts.length,
                        itemBuilder: (context, index) {
                          return ProductCard(product: shoesProducts[index]);
                        },
                      ),
                    ],
                  ),
                ),
              ],

              // Empty State
              if (clothingProducts.isEmpty && shoesProducts.isEmpty)
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
                        'No men\'s products available',
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
