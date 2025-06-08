// lib/widgets/battery_status_indicator.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:battery_plus/battery_plus.dart';
import '../providers/battery_provider.dart';

class BatteryStatusIndicator extends StatelessWidget {
  final bool showPercentage;
  final bool showOnlyWhenLow;
  final double iconSize;

  const BatteryStatusIndicator({
    super.key,
    this.showPercentage = true,
    this.showOnlyWhenLow = false,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<BatteryProvider>(
      builder: (context, batteryProvider, child) {
        // Don't show if showOnlyWhenLow is true and battery is fine
        if (showOnlyWhenLow && !batteryProvider.isBatteryLow) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () => _showBatteryDetails(context, batteryProvider),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: batteryProvider.isBatteryLow
                  ? batteryProvider.getBatteryColor().withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: batteryProvider.isBatteryLow
                  ? Border.all(
                      color: batteryProvider.getBatteryColor().withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    batteryProvider.getBatteryIcon(),
                    key: ValueKey(batteryProvider.batteryLevel),
                    color: batteryProvider.getBatteryColor(),
                    size: iconSize,
                  ),
                ),
                if (showPercentage) ...[
                  const SizedBox(width: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      '${batteryProvider.batteryLevel}%',
                      key: ValueKey(batteryProvider.batteryLevel),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: batteryProvider.getBatteryColor(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBatteryDetails(
      BuildContext context, BatteryProvider batteryProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              batteryProvider.getBatteryIcon(),
              color: batteryProvider.getBatteryColor(),
            ),
            const SizedBox(width: 12),
            const Text('Battery Status'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              'Battery Level',
              '${batteryProvider.batteryLevel}%',
              batteryProvider.getBatteryColor(),
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Status',
              _getBatteryStateText(batteryProvider.batteryState),
              batteryProvider.batteryState == BatteryState.charging
                  ? Colors.green
                  : Colors.grey,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Warning Level',
              _getSimpleWarningText(
                  batteryProvider.batteryLevel, batteryProvider.batteryState),
              _getSimpleWarningColor(
                  batteryProvider.batteryLevel, batteryProvider.batteryState),
            ),
            if (batteryProvider.isBatteryLow) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning,
                        color: Colors.orange.shade600, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Consider charging your device to avoid losing your cart.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (batteryProvider.isBatteryLow)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/cart');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B4513),
              ),
              child: const Text(
                'View Cart',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getBatteryStateText(BatteryState state) {
    switch (state) {
      case BatteryState.charging:
        return 'Charging';
      case BatteryState.discharging:
        return 'Discharging';
      case BatteryState.full:
        return 'Full';
      case BatteryState.connectedNotCharging:
        return 'Connected';
      default:
        return 'Unknown';
    }
  }

  // Simplified warning level without external enum
  String _getSimpleWarningText(int batteryLevel, BatteryState state) {
    if (state == BatteryState.charging) {
      return 'Normal (Charging)';
    }

    if (batteryLevel <= 10) {
      return 'Critical';
    } else if (batteryLevel <= 20) {
      return 'Low';
    } else if (batteryLevel <= 30) {
      return 'Medium';
    } else {
      return 'Normal';
    }
  }

  Color _getSimpleWarningColor(int batteryLevel, BatteryState state) {
    if (state == BatteryState.charging) {
      return Colors.green;
    }

    if (batteryLevel <= 10) {
      return Colors.red.shade700;
    } else if (batteryLevel <= 20) {
      return Colors.red;
    } else if (batteryLevel <= 30) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}

// Compact version for app bars
class CompactBatteryIndicator extends StatelessWidget {
  const CompactBatteryIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BatteryProvider>(
      builder: (context, batteryProvider, child) {
        if (!batteryProvider.isBatteryLow) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                batteryProvider.getBatteryIcon(),
                color: batteryProvider.getBatteryColor(),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${batteryProvider.batteryLevel}%',
                style: TextStyle(
                  fontSize: 12,
                  color: batteryProvider.getBatteryColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
