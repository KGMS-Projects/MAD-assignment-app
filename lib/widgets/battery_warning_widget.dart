// lib/widgets/battery_warning_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/battery_provider.dart';
import '../providers/cart_provider.dart';

class BatteryWarningWidget extends StatelessWidget {
  final VoidCallback? onSaveCart;
  final VoidCallback? onDismiss;

  const BatteryWarningWidget({
    super.key,
    this.onSaveCart,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<BatteryProvider, CartProvider>(
      builder: (context, batteryProvider, cartProvider, child) {
        // Don't show if battery is fine or cart is empty
        if (!batteryProvider.shouldShowWarning || cartProvider.items.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                batteryProvider.isCriticallyLow
                    ? Colors.red.shade600
                    : Colors.orange.shade600,
                batteryProvider.isCriticallyLow
                    ? Colors.red.shade400
                    : Colors.orange.shade400,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      batteryProvider.getBatteryIcon(),
                      key: ValueKey(batteryProvider.batteryLevel),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          batteryProvider.isCriticallyLow
                              ? 'Critical Battery Warning!'
                              : 'Low Battery Warning',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Battery: ${batteryProvider.batteryLevel}%',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      batteryProvider.markWarningShown();
                      onDismiss?.call();
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                batteryProvider.isCriticallyLow
                    ? 'Your battery is critically low! Your cart with ${cartProvider.itemCount} items may be lost if your device shuts down.'
                    : 'Your battery is low. Save your cart with ${cartProvider.itemCount} items to avoid losing them.',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        // Mark warning as shown
                        batteryProvider.markWarningShown();

                        // Show confirmation (cart is already saved via SharedPreferences)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  'Cart saved! ${cartProvider.itemCount} items are safe.',
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );

                        onSaveCart?.call();
                      },
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text(
                        'Cart Saved!',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        batteryProvider.markWarningShown();
                        Navigator.pushNamed(context, '/cart');
                      },
                      icon: const Icon(Icons.shopping_cart_checkout),
                      label: const Text('Checkout Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: batteryProvider.isCriticallyLow
                            ? Colors.red.shade600
                            : Colors.orange.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
