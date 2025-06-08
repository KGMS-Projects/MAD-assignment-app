// lib/providers/network_provider.dart (FIXED VERSION)
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/network_service.dart';

class NetworkProvider extends ChangeNotifier {
  // Private variables to store network state
  NetworkInfo? _networkInfo;
  bool _isMonitoring = false;
  StreamSubscription<NetworkInfo>? _networkSubscription;
  DateTime? _lastConnectionTime;
  bool _showConnectionMessage = false;

  // Getters to access network information
  NetworkInfo? get networkInfo => _networkInfo;
  bool get isMonitoring => _isMonitoring;
  bool get isConnected => _networkInfo?.isConnected ?? false;
  bool get hasInternet => NetworkService.hasInternetConnection;
  bool get isWiFi => NetworkService.isConnectedToWiFi;
  bool get isMobile => NetworkService.isConnectedToMobile;
  String get connectionMessage => NetworkService.getConnectionMessage();
  bool get showConnectionMessage => _showConnectionMessage;

  // Get connection type for display
  NetworkConnectionType get connectionType =>
      _networkInfo?.connectionType ?? NetworkConnectionType.none;

  // Get connection quality
  NetworkQuality get connectionQuality =>
      _networkInfo?.quality ?? NetworkQuality.none;

  // Get connection status text
  String get connectionStatusText {
    if (_networkInfo == null) return 'Checking...';
    return _networkInfo!.displayName;
  }

  // Constructor - automatically initialize when created
  NetworkProvider() {
    _initializeNetworkMonitoring();
  }

  /// Initialize network monitoring
  Future<void> _initializeNetworkMonitoring() async {
    if (_isMonitoring) return;

    try {
      await NetworkService.initialize();
      _isMonitoring = true;

      // Listen to network changes
      _networkSubscription = NetworkService.networkStream?.listen(
        (networkInfo) {
          final wasConnected = _networkInfo?.isConnected ?? false;
          final isNowConnected = networkInfo.isConnected;

          _networkInfo = networkInfo;

          // Show connection message when status changes
          if (wasConnected != isNowConnected) {
            _handleConnectionChange(wasConnected, isNowConnected);
          }

          notifyListeners();
        },
        onError: (error) {
          debugPrint('Network provider error: $error');
        },
      );

      // Get initial network status
      final initialInfo = await NetworkService.checkConnectivity();
      _networkInfo = initialInfo;
      notifyListeners();

      debugPrint('✅ Network monitoring initialized');
    } catch (e) {
      debugPrint('❌ Error initializing network monitoring: $e');
    }
  }

  /// Handle connection changes and show appropriate messages
  void _handleConnectionChange(bool wasConnected, bool isNowConnected) {
    _lastConnectionTime = DateTime.now();

    if (!wasConnected && isNowConnected) {
      // Connection restored
      _showConnectionMessage = true;
      _hideConnectionMessageAfterDelay();
      debugPrint('🌐 Connection restored: ${_networkInfo?.displayName}');
    } else if (wasConnected && !isNowConnected) {
      // Connection lost
      _showConnectionMessage = true;
      debugPrint('📵 Connection lost');
    }
  }

  /// Hide connection message after a delay
  void _hideConnectionMessageAfterDelay() {
    Timer(const Duration(seconds: 3), () {
      _showConnectionMessage = false;
      notifyListeners();
    });
  }

  /// Manually refresh network status
  Future<void> refreshNetworkStatus() async {
    try {
      await NetworkService.refreshNetworkStatus();
      final refreshedInfo = NetworkService.currentNetworkInfo;
      if (refreshedInfo != null) {
        _networkInfo = refreshedInfo;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing network status: $e');
    }
  }

  /// Get network icon based on connection type and quality
  IconData getNetworkIcon() {
    if (_networkInfo == null || !_networkInfo!.isConnected) {
      return Icons.signal_wifi_off;
    }

    switch (_networkInfo!.connectionType) {
      case NetworkConnectionType.wifi:
        switch (_networkInfo!.quality) {
          case NetworkQuality.good:
            return Icons.wifi;
          case NetworkQuality.poor:
            return Icons.wifi_1_bar;
          case NetworkQuality.none:
            return Icons.wifi_off;
        }
      case NetworkConnectionType.mobile:
        switch (_networkInfo!.quality) {
          case NetworkQuality.good:
            return Icons.signal_cellular_4_bar; // ✅ FIXED
          case NetworkQuality.poor:
            return Icons.signal_cellular_0_bar; // Changed to valid icon
          case NetworkQuality.none:
            return Icons.signal_cellular_off; // ✅ FIXED
        }
      case NetworkConnectionType.ethernet:
        return Icons.settings_ethernet; // ✅ FIXED
      case NetworkConnectionType.none:
        return Icons.signal_wifi_off;
    }
  }

  /// Get network color based on connection quality
  Color getNetworkColor() {
    if (_networkInfo == null || !_networkInfo!.isConnected) {
      return Colors.red;
    }

    switch (_networkInfo!.quality) {
      case NetworkQuality.good:
        return Colors.green;
      case NetworkQuality.poor:
        return Colors.orange;
      case NetworkQuality.none:
        return Colors.red;
    }
  }

  /// Check if should show offline mode warning
  bool get shouldShowOfflineWarning {
    return !isConnected && _networkInfo != null;
  }

  /// Get offline mode message
  String get offlineMessage {
    if (isConnected) return '';

    switch (connectionType) {
      case NetworkConnectionType.wifi:
        return 'WiFi connected but no internet access. Check your connection.';
      case NetworkConnectionType.mobile:
        return 'Mobile data connected but no internet access. Check your plan.';
      case NetworkConnectionType.ethernet:
        return 'Ethernet connected but no internet access.';
      case NetworkConnectionType.none:
        return 'No internet connection. Using offline mode.';
    }
  }

  /// Get network signal strength (0-100)
  int get signalStrength {
    if (_networkInfo == null || !_networkInfo!.isConnected) {
      return 0;
    }

    switch (_networkInfo!.quality) {
      case NetworkQuality.good:
        return 85;
      case NetworkQuality.poor:
        return 35;
      case NetworkQuality.none:
        return 0;
    }
  }

  /// Check if network is suitable for heavy operations (like downloading)
  bool get isNetworkGoodForHeavyOperations {
    return isConnected &&
        connectionQuality == NetworkQuality.good &&
        (isWiFi || isMobile);
  }

  /// Get data usage warning message
  String? get dataUsageWarning {
    if (isMobile && connectionQuality == NetworkQuality.poor) {
      return 'Using mobile data with poor signal. High data usage may occur.';
    }
    return null;
  }

  /// Check if it's been a while since last connection
  bool get hasBeenOfflineForLong {
    if (isConnected || _lastConnectionTime == null) return false;

    final timeSinceLastConnection =
        DateTime.now().difference(_lastConnectionTime!);
    return timeSinceLastConnection.inMinutes > 5;
  }

  /// Dismiss connection message manually
  void dismissConnectionMessage() {
    _showConnectionMessage = false;
    notifyListeners();
  }

  /// Force a network check (useful for pull-to-refresh)
  Future<bool> checkNetworkStatus() async {
    try {
      final networkInfo = await NetworkService.checkConnectivity();
      _networkInfo = networkInfo;
      notifyListeners();
      return networkInfo.isConnected;
    } catch (e) {
      debugPrint('Error checking network status: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _networkSubscription?.cancel();
    NetworkService.dispose();
    super.dispose();
  }
}
