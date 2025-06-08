// lib/widgets/network_status_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/network_provider.dart';

/// Simple network status indicator for app bar
class NetworkStatusIndicator extends StatelessWidget {
  final bool showText;
  final bool showOnlyWhenOffline;
  final double iconSize;

  const NetworkStatusIndicator({
    super.key,
    this.showText = false,
    this.showOnlyWhenOffline = false,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkProvider>(
      builder: (context, networkProvider, child) {
        // Don't show if showOnlyWhenOffline is true and we're connected
        if (showOnlyWhenOffline && networkProvider.isConnected) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () => _showNetworkDetails(context, networkProvider),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: !networkProvider.isConnected
                  ? Colors.red.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: !networkProvider.isConnected
                  ? Border.all(color: Colors.red.withOpacity(0.3), width: 1)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    networkProvider.getNetworkIcon(),
                    key: ValueKey(networkProvider.connectionType),
                    color: networkProvider.getNetworkColor(),
                    size: iconSize,
                  ),
                ),
                if (showText) ...[
                  const SizedBox(width: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      networkProvider.connectionStatusText,
                      key: ValueKey(networkProvider.connectionStatusText),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: networkProvider.getNetworkColor(),
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

  void _showNetworkDetails(
      BuildContext context, NetworkProvider networkProvider) {
    showDialog(
      context: context,
      builder: (context) =>
          NetworkDetailsDialog(networkProvider: networkProvider),
    );
  }
}

/// Compact network indicator (only shows when offline)
class CompactNetworkIndicator extends StatelessWidget {
  const CompactNetworkIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkProvider>(
      builder: (context, networkProvider, child) {
        if (networkProvider.isConnected) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                networkProvider.getNetworkIcon(),
                color: networkProvider.getNetworkColor(),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Offline',
                style: TextStyle(
                  fontSize: 12,
                  color: networkProvider.getNetworkColor(),
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

/// Network status banner (shows at top when connection changes)
class NetworkStatusBanner extends StatelessWidget {
  const NetworkStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkProvider>(
      builder: (context, networkProvider, child) {
        if (!networkProvider.showConnectionMessage) {
          return const SizedBox.shrink();
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          color: networkProvider.isConnected
              ? Colors.green.shade100
              : Colors.red.shade100,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                networkProvider.getNetworkIcon(),
                color: networkProvider.getNetworkColor(),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  networkProvider.connectionMessage,
                  style: TextStyle(
                    color: networkProvider.isConnected
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                onPressed: networkProvider.dismissConnectionMessage,
                icon: Icon(
                  Icons.close,
                  size: 18,
                  color: networkProvider.isConnected
                      ? Colors.green.shade800
                      : Colors.red.shade800,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Detailed network information dialog
class NetworkDetailsDialog extends StatelessWidget {
  final NetworkProvider networkProvider;

  const NetworkDetailsDialog({
    super.key,
    required this.networkProvider,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            networkProvider.getNetworkIcon(),
            color: networkProvider.getNetworkColor(),
          ),
          const SizedBox(width: 12),
          const Text('Network Status'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
            'Connection',
            networkProvider.connectionStatusText,
            networkProvider.getNetworkColor(),
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Status',
            networkProvider.isConnected ? 'Connected' : 'Disconnected',
            networkProvider.isConnected ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Signal Strength',
            '${networkProvider.signalStrength}%',
            _getSignalColor(networkProvider.signalStrength),
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Last Updated',
            _formatTime(networkProvider.networkInfo?.lastChecked),
            Colors.grey,
          ),
          if (!networkProvider.isConnected) ...[
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
                  Icon(Icons.info_outline,
                      color: Colors.orange.shade600, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Some features may be limited in offline mode.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (networkProvider.dataUsageWarning != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.data_usage, color: Colors.blue.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      networkProvider.dataUsageWarning!,
                      style: const TextStyle(fontSize: 12),
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
        ElevatedButton(
          onPressed: () async {
            await networkProvider.refreshNetworkStatus();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Network status refreshed'),
                  backgroundColor: Color(0xFF8B4513),
                  duration: Duration(seconds: 1),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B4513),
          ),
          child: const Text(
            'Refresh',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
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

  Color _getSignalColor(int strength) {
    if (strength >= 70) return Colors.green;
    if (strength >= 40) return Colors.orange;
    return Colors.red;
  }

  String _formatTime(DateTime? time) {
    if (time == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// Network warning widget for offline mode
class NetworkWarningWidget extends StatelessWidget {
  final VoidCallback? onRefresh;
  final VoidCallback? onDismiss;

  const NetworkWarningWidget({
    super.key,
    this.onRefresh,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkProvider>(
      builder: (context, networkProvider, child) {
        if (networkProvider.isConnected) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.shade600,
                Colors.red.shade600,
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
                  Icon(
                    networkProvider.getNetworkIcon(),
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'No Internet Connection',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          networkProvider.offlineMessage,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onDismiss != null)
                    IconButton(
                      onPressed: onDismiss,
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          onRefresh ?? networkProvider.refreshNetworkStatus,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'Retry Connection',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
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
