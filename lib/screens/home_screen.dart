import 'package:flutter/material.dart';
import '../widgets/collection_card.dart';
import '../widgets/signature_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero Section
          Container(
            height: 400,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8B4513), Color(0xFFA0522D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black26,
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'SUMMER COLLECTION 2025',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'ÉLÉGANCE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 8,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Where timeless sophistication meets contemporary artistry.\nDiscover pieces that define luxury.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: const Text(
                          'DISCOVER COLLECTION',
                          style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Collections Section
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Text(
                  'Collections',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Curated with precision, designed for those who appreciate the finest details',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: CollectionCard(
                        title: 'Women',
                        subtitle: 'HAUTE COUTURE',
                        imageUrl:
                            'https://images.unsplash.com/photo-1596462324594-b4dd8afbb4dd?w=400',
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CollectionCard(
                        title: 'Men',
                        subtitle: 'SARTORIAL EXCELLENCE',
                        imageUrl:
                            'https://images.unsplash.com/photo-1617127365659-c47fa864d8bc?w=400',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Private Sale Section
          Container(
            color: const Color(0xFF2C3E50),
            padding: const EdgeInsets.all(48),
            child: Column(
              children: [
                const Text(
                  'EXCLUSIVE OFFER',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Private Sale Event',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Access to limited editions and exclusive pieces. By invitation only.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: Color(0xFF8B4513)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'VIEW COLLECTION',
                    style: TextStyle(
                      color: Color(0xFF8B4513),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Signature Pieces Section
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Text(
                  'Signature Pieces',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Each piece tells a story of craftsmanship, heritage, and uncompromising attention to detail',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: SignatureCard(
                        title: 'Leather Goods',
                        subtitle: 'ARTISANAL CRAFT',
                        imageUrl:
                            'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=300',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SignatureCard(
                        title: 'Fragrances',
                        subtitle: 'SIGNATURE SCENTS',
                        imageUrl:
                            'https://images.unsplash.com/photo-1557170334-a9632e77c6e4?w=300',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SignatureCard(
                        title: 'Accessories',
                        subtitle: 'STATEMENT PIECES',
                        imageUrl:
                            'https://images.unsplash.com/photo-1602751584552-8ba73aad10e1?w=300',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
